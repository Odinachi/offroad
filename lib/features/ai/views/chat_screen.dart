import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:jemenai/shared/navigator/app_route_string.dart';
import '../../../shared/theme.dart';
import '../model/ai_model.dart';

class ChatScreen extends StatefulWidget {
  final String? modelName;
  final String? initialPrompt;
  final bool isTab;

  const ChatScreen({
    super.key,
    this.modelName,
    this.initialPrompt,
    this.isTab = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Message {
  final String id;
  final String role; // 'user' or 'assistant'
  String content;
  final DateTime ts;
  bool pinned;
  bool liked;

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.ts,
    this.pinned = false,
    this.liked = false,
  });
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late String _model;
  bool _showModels = false;
  bool _typing = false;
  bool _streaming = false;
  String _streamText = "";

  final List<Message> _messages = [];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _streamTimer;
  bool _showAttachments = false;

  AIModel get _currentAIModel =>
      models.firstWhere((m) => m.name == _model, orElse: () => models.first);

  final List<String> _modelsList = ["Llama 3.2 3B", "Phi-3 Mini", "Mistral 7B"];

  final List<String> _predefinedResponses = [
    "I'm Offroad, running entirely on your device with **complete privacy**.\n\nYour conversations are processed locally — nothing is ever sent to external servers. Here's what I can help with:\n\n```\n• Writing & editing\n• Code generation & debugging  \n• Research & analysis\n• Creative brainstorming\n• Translation & explanation\n```\n\nWhat would you like to explore?",
    "Here's a clean solution:\n\n```javascript\nconst debounce = (fn, delay) => {\n  let timer;\n  return (...args) => {\n    clearTimeout(timer);\n    timer = setTimeout(() => fn(...args), delay);\n  };\n};\n\n// Usage\nconst onSearch = debounce(query => {\n  console.log('Searching:', query);\n}, 300);\n```\n\nThis delays execution until the user stops typing for 300ms — perfect for search inputs and resize handlers.",
    "**Quantum computing** leverages quantum mechanics to solve problems that stump classical computers.\n\n**The key concepts:**\n\n- **Qubits** — Unlike bits (0 or 1), qubits exist in *superposition* — both states simultaneously\n- **Entanglement** — Linked qubits share state instantaneously across any distance\n- **Interference** — Algorithms amplify correct answers and cancel wrong ones\n\n**Real-world impact:** Drug discovery, cryptography, climate modeling, and financial optimization could be millions of times faster than today.",
    "Here's a professional email draft:\n\n---\n\nSubject: Rescheduling Our Meeting — [New Time Options]\n\nHi [Name],\n\nI hope this finds you well. I need to reschedule our meeting originally planned for [Date/Time].\n\n**Available windows:**\n- [Option 1]\n- [Option 2]  \n- [Option 3]\n\nPlease let me know which works best, or suggest an alternative. I apologize for any inconvenience.\n\nBest regards,\n[Your Name]",
  ];

  @override
  void initState() {
    super.initState();
    _model = widget.modelName ?? "Llama 3.2 3B";

    // Add initial greeting message
    _messages.add(
      Message(
        id: "init",
        role: "assistant",
        content: _predefinedResponses[0],
        ts: DateTime.now(),
      ),
    );

    // Handle initial prompt redirect
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _send(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _streamResponse(String text, String id) {
    setState(() {
      _streaming = true;
      _streamText = "";
    });

    int pos = 0;
    _streamTimer = Timer.periodic(const Duration(milliseconds: 24), (timer) {
      pos += (math.Random().nextInt(3) + 2); // Stream 2 to 4 chars
      if (pos >= text.length) {
        timer.cancel();
        setState(() {
          _messages.add(
            Message(
              id: id,
              role: "assistant",
              content: text,
              ts: DateTime.now(),
            ),
          );
          _streamText = "";
          _streaming = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          _streamText = text.substring(0, pos);
        });
        _scrollToBottom();
      }
    });
  }

  void _send([String? overrideText]) {
    final text = (overrideText ?? _inputController.text).trim();
    if (text.isEmpty || _typing || _streaming) return;

    _inputController.clear();
    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: "user",
          content: text,
          ts: DateTime.now(),
        ),
      );
      _typing = true;
    });
    _scrollToBottom();

    // Simulate thinking delay
    final thinkingDelay = Duration(
      milliseconds: 900 + math.Random().nextInt(600),
    );
    Future.delayed(thinkingDelay, () {
      if (!mounted) return;
      setState(() {
        _typing = false;
      });

      final lowercaseQuery = text.toLowerCase();
      String responseText = _predefinedResponses[0];
      if (lowercaseQuery.contains("code") ||
          lowercaseQuery.contains("function") ||
          lowercaseQuery.contains("debug")) {
        responseText = _predefinedResponses[1];
      } else if (lowercaseQuery.contains("quantum") ||
          lowercaseQuery.contains("explain")) {
        responseText = _predefinedResponses[2];
      } else if (lowercaseQuery.contains("email") ||
          lowercaseQuery.contains("write")) {
        responseText = _predefinedResponses[3];
      }

      _streamResponse(
        responseText,
        (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final foreColor = theme.colorScheme.onSurface;
    final border = jc.border;
    final cardBg = jc.card;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(bottom: BorderSide(color: border)),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // Back button (hidden if tab)
                if (!widget.isTab)
                  IconButton(
                    onPressed: () => AppRouter.pop(),
                    icon: Icon(Icons.arrow_back_ios_new, color: foreColor),
                  )
                else
                  const SizedBox(width: 16),

                // Model Dropdown toggle
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _showModels = !_showModels),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: JemenaiTheme.gradBrand,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _model,
                                  style: JemenaiTheme.fontDisplay(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: foreColor,
                                  ),
                                ),
                                Text(
                                  'On-device · Private',
                                  style: JemenaiTheme.fontBody(
                                    fontSize: 10,
                                    color: jc.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _showModels
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: jc.mutedForeground,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_horiz, size: 18, color: foreColor),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Message List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount:
                      _messages.length +
                      (_typing ? 1 : 0) +
                      (_streaming ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _messages.length) {
                      return _buildMessageBubble(_messages[index]);
                    } else if (_typing && index == _messages.length) {
                      return _buildTypingDots();
                    } else {
                      return _buildStreamingBubble();
                    }
                  },
                ),
              ),

              // Bottom Input Bar
              _buildInputBar(cardBg, border, foreColor),
            ],
          ),

          // Models Picker Overlay
          if (_showModels) _buildModelsPickerOverlay(cardBg, border, foreColor),
        ],
      ),
    );
  }

  Widget _buildModelsPickerOverlay(
    Color cardBg,
    Color border,
    Color foreColor,
  ) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      top: 4,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
          boxShadow: JemenaiTheme.shadowFloat(isDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              _modelsList.map((m) {
                final isSelected = m == _model;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _model = m;
                      _showModels = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient:
                                isDark
                                    ? JemenaiTheme.gradSubtleDark
                                    : JemenaiTheme.gradSubtleLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m,
                                style: JemenaiTheme.fontBody(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: foreColor,
                                ),
                              ),
                              Text(
                                'On-device',
                                style: JemenaiTheme.fontBody(
                                  fontSize: 10,
                                  color: jc.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.done_all,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message msg) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final isUser = msg.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // Assistant Avatar
              if (!isUser)
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8, top: 4),
                  decoration: BoxDecoration(
                    color: jc.card,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      _currentAIModel.image != null
                          ? _currentAIModel.image!.image(
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            decoration: const BoxDecoration(
                              gradient: JemenaiTheme.gradBrand,
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                ),

              // Message Content Bubble
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isUser ? theme.colorScheme.primary : jc.secondaryFill,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft:
                          isUser
                              ? const Radius.circular(20)
                              : const Radius.circular(4),
                      bottomRight:
                          isUser
                              ? const Radius.circular(4)
                              : const Radius.circular(20),
                    ),
                  ),
                  child: MarkdownBodyText(
                    content: msg.content,
                    isUser: isUser,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),

          // Actions row
          Padding(
            padding: EdgeInsets.only(
              top: 6.0,
              left: isUser ? 0 : 42.0,
              right: isUser ? 6.0 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${msg.ts.hour.toString().padLeft(2, '0')}:${msg.ts.minute.toString().padLeft(2, '0')}',
                  style: JemenaiTheme.fontBody(
                    fontSize: 10,
                    color: jc.mutedForeground,
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 8),
                  _buildBubbleAction(Icons.content_copy, () {
                    Clipboard.setData(ClipboardData(text: msg.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }),

                  _buildBubbleAction(Icons.volume_up, () {}),
                  _buildBubbleAction(Icons.delete_outline, () {
                    setState(() {
                      _messages.removeWhere((element) => element.id == msg.id);
                    });
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleAction(
    IconData icon,
    VoidCallback onTap, {
    Color? activeColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 13,
            color: activeColor ?? theme.jColors.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingDots() {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assistant Avatar
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, top: 4),
            decoration: BoxDecoration(
              color: jc.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child:
                _currentAIModel.image != null
                    ? _currentAIModel.image!.image(
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                    )
                    : Container(
                      decoration: const BoxDecoration(
                        gradient: JemenaiTheme.gradBrand,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
          ),

          // Typing Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: jc.secondaryFill,
              borderRadius: BorderRadius.circular(
                20,
              ).copyWith(bottomLeft: const Radius.circular(4)),
            ),
            child: SizedBox(
              width: 36,
              height: 12,
              child: TypingBouncingDots(isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamingBubble() {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assistant Avatar
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, top: 4),
            decoration: BoxDecoration(
              color: jc.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child:
                _currentAIModel.image != null
                    ? _currentAIModel.image!.image(
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                    )
                    : Container(
                      decoration: const BoxDecoration(
                        gradient: JemenaiTheme.gradBrand,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
          ),

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: jc.secondaryFill,
                borderRadius: BorderRadius.circular(
                  20,
                ).copyWith(bottomLeft: const Radius.circular(4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: MarkdownBodyText(
                      content: _streamText,
                      isUser: false,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Blinking cursor
                  const BlinkingCursor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(Color cardBg, Color border, Color foreColor) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final mutedFore = jc.mutedForeground;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final extraPadding = (widget.isTab && !keyboardOpen) ? 80.0 : 0.0;
    final hasInput = _inputController.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + extraPadding),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachments row
                  Row(
                    children: [
                      _buildInputMediaBtn(
                        _showAttachments ? Icons.close : Icons.add,
                        mutedFore,
                        onTap: () {
                          setState(() {
                            _showAttachments = !_showAttachments;
                          });
                        },
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              _showAttachments
                                  ? [
                                    _buildInputMediaBtn(Icons.image, mutedFore),
                                    _buildInputMediaBtn(
                                      Icons.attach_file,
                                      mutedFore,
                                    ),
                                    _buildInputMediaBtn(
                                      Icons.camera_alt,
                                      mutedFore,
                                    ),
                                  ]
                                  : [],
                        ),
                      ),
                    ],
                  ),

                  // Text Box
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        controller: _inputController,

                        keyboardType: TextInputType.multiline,
                        style: JemenaiTheme.fontBody(
                          fontSize: 14,
                          color: foreColor,
                        ),

                        onChanged: (text) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Message OffRoad...',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          filled: false,
                          hintStyle: JemenaiTheme.fontBody(
                            fontSize: 14,
                            color: mutedFore,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  // Mic & Send
                  Row(
                    children: [
                      _buildInputMediaBtn(
                        Icons.mic,
                        mutedFore,
                        onTap: () {
                          AppRouter.push(AppRouteString.voice);
                        },
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap:
                            hasInput && !_typing && !_streaming
                                ? () => _send()
                                : null,
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient:
                                hasInput && !_typing && !_streaming
                                    ? JemenaiTheme.gradBrand
                                    : null,
                            color:
                                hasInput && !_typing && !_streaming
                                    ? null
                                    : jc.secondaryFill,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_upward,
                            size: 16,
                            color:
                                hasInput && !_typing && !_streaming
                                    ? Colors.white
                                    : mutedFore,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'On-device · Private · No internet required',
              style: JemenaiTheme.fontBody(
                fontSize: 10,
                color: mutedFore.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputMediaBtn(
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// Bouncing typing dots animation
class TypingBouncingDots extends StatefulWidget {
  final bool isDark;
  const TypingBouncingDots({super.key, required this.isDark});

  @override
  State<TypingBouncingDots> createState() => _TypingBouncingDotsState();
}

class _TypingBouncingDotsState extends State<TypingBouncingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: -6.0).animate(
        CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
      );
    });

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[index].value),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// Flashing Cursor Indicator
class BlinkingCursor extends StatefulWidget {
  const BlinkingCursor({super.key});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _cursorController,
      child: Container(
        width: 2,
        height: 15,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// Markdown parser widget representing the React component MdText
class MarkdownBodyText extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isDark;

  const MarkdownBodyText({
    super.key,
    required this.content,
    required this.isUser,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final textStyleColor = isUser ? Colors.white : theme.colorScheme.onSurface;

    // Basic Tokenizer mimicking the React splitter
    // regex splits: code blocks ```...```, bold **...**, italics *...*, and dividers ---...---
    final parts = content.split(
      RegExp(r'(```[\s\S]*?```|\*\*[\s\S]*?\*\*|\*[^*]+\*|---[\s\S]*?---)'),
    );

    List<Widget> spans = [];

    for (var part in parts) {
      if (part.isEmpty) continue;

      if (part.startsWith('```') && part.endsWith('```')) {
        // Code Block
        final inner = part.substring(3, part.length - 3);
        final lines = inner.split('\n');
        String lang = "code";
        String code = inner;
        if (lines.isNotEmpty &&
            lines[0].trim().isNotEmpty &&
            !lines[0].contains(' ')) {
          lang = lines[0].trim();
          code = lines.sublist(1).join('\n');
        }
        spans.add(_buildCodeBlock(code, lang));
      } else if (part.startsWith('**') && part.endsWith('**')) {
        // Bold Text
        final text = part.substring(2, part.length - 2);
        spans.add(
          Text(
            text,
            style: JemenaiTheme.fontBody(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textStyleColor,
              lineHeight: 1.45,
            ),
          ),
        );
      } else if (part.startsWith('*') && part.endsWith('*')) {
        // Italic Text
        final text = part.substring(1, part.length - 1);
        spans.add(
          Text(
            text,
            style: JemenaiTheme.fontBody(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: textStyleColor,
              lineHeight: 1.45,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (part.startsWith('---') && part.endsWith('---')) {
        // Section divider block
        final text = part.substring(3, part.length - 3).trim();
        spans.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: jc.secondaryFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: jc.border),
            ),
            child: Text(
              text,
              style: JemenaiTheme.fontBody(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        );
      } else {
        // Regular string with line split checks for lists
        final lines = part.split('\n');
        List<Widget> listWidgets = [];

        for (var line in lines) {
          if (line.isEmpty) {
            listWidgets.add(const SizedBox(height: 4));
            continue;
          }

          if (line.startsWith('- ') || line.startsWith('• ')) {
            // Unordered List item
            final itemText = line.substring(2);
            listWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color:
                            isUser ? Colors.white70 : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        itemText,
                        style: JemenaiTheme.fontBody(
                          fontSize: 14,
                          color: textStyleColor,
                          lineHeight: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // General paragraph line
            listWidgets.add(
              Text(
                line,
                style: JemenaiTheme.fontBody(
                  fontSize: 14,
                  color: textStyleColor,
                  lineHeight: 1.45,
                ),
              ),
            );
          }
        }

        spans.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listWidgets,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: spans,
    );
  }

  Widget _buildCodeBlock(String code, String lang) {
    bool copied = false;
    return StatefulBuilder(
      builder: (context, setBlockState) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top copy bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang,
                      style: JemenaiTheme.fontBody(
                        fontSize: 11,
                        color: const Color(0xFF4ADE80),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        setBlockState(() => copied = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (context.mounted) {
                            setBlockState(() => copied = false);
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            copied ? Icons.done_all : Icons.content_copy,
                            size: 13,
                            color:
                                copied
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFF71717A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            copied ? 'Copied!' : 'Copy',
                            style: JemenaiTheme.fontBody(
                              fontSize: 11,
                              color:
                                  copied
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFF71717A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Code pre block
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    code,
                    style: JemenaiTheme.fontBody(
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
