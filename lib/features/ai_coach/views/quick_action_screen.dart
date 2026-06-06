import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/theme.dart';

class QuickActionScreen extends StatefulWidget {
  final Function(String, [Map<String, dynamic>]) onNavigate;
  final bool isDark;
  final String action;
  final String label;

  const QuickActionScreen({
    super.key,
    required this.onNavigate,
    required this.isDark,
    required this.action,
    required this.label,
  });

  @override
  State<QuickActionScreen> createState() => _QuickActionScreenState();
}

class _QuickActionScreenState extends State<QuickActionScreen> {
  String _input = "";
  String _response = "";
  bool _loading = false;
  int _dots = 0;
  Timer? _dotsTimer;

  final _textController = TextEditingController();

  final Map<String, IconData> _iconMap = {
    "text-assistant": LucideIcons.type,
    "pic-to-text": LucideIcons.camera,
    "web-search": LucideIcons.globe,
    "ai-image": LucideIcons.image,
    "voice-to-text": LucideIcons.mic,
    "doc-analysis": LucideIcons.fileText,
    "url-summary": LucideIcons.link2,
    "write-song": LucideIcons.music,
    "translate": LucideIcons.languages,
    "explain-code": LucideIcons.code2,
    "pdf-summarizer": LucideIcons.fileSearch,
    "brainstorm": LucideIcons.lightbulb,
    "email-writer": LucideIcons.mail,
    "coding-assistant": LucideIcons.terminal,
    "ai-notes": LucideIcons.stickyNote,
    "resume-analyzer": LucideIcons.fileCheck,
  };

  final Map<String, Map<String, dynamic>> _configs = {
    "text-assistant": {
      "accent": const Color(0xFF818CF8),
      "dark": const Color(0xFF12123A),
      "desc": "Craft, edit, and perfect any text with AI assistance.",
      "placeholder": "What would you like to write or edit?",
      "chips": [
        "Cover letter for senior dev role",
        "Edit this paragraph to sound polished",
        "Write a product announcement",
      ],
    },
    "pic-to-text": {
      "accent": const Color(0xFFA78BFA),
      "dark": const Color(0xFF16103A),
      "desc": "Extract and understand text from any image instantly.",
      "placeholder": "Upload an image or describe what to extract...",
      "chips": [
        "Extract text from business card",
        "Describe what's in this image",
        "OCR this handwritten note",
      ],
    },
    "web-search": {
      "accent": const Color(0xFF38BDF8),
      "dark": const Color(0xFF051C2C),
      "desc": "AI-powered research with intelligent summaries.",
      "placeholder": "What do you want to research?",
      "chips": [
        "Best React frameworks in 2026",
        "Latest breakthroughs in quantum AI",
        "Summarize recent SpaceX launches",
      ],
    },
    "ai-image": {
      "accent": const Color(0xFFF472B6),
      "dark": const Color(0xFF2D0A20),
      "desc": "Generate stunning visuals from text descriptions.",
      "placeholder": "Describe the image you want to create...",
      "chips": [
        "Futuristic city at sunset, cyberpunk",
        "Photorealistic robot in a library",
        "Abstract indigo geometric art",
      ],
    },
    "voice-to-text": {
      "accent": const Color(0xFF34D399),
      "dark": const Color(0xFF022016),
      "desc": "Convert speech to accurate text instantly.",
      "placeholder": "Tap mic to record or describe your audio...",
      "chips": [
        "Transcribe my voice note",
        "Convert meeting recording to minutes",
        "Translate spoken French to English",
      ],
    },
    "doc-analysis": {
      "accent": const Color(0xFFFBBF24),
      "dark": const Color(0xFF1E1200),
      "desc": "Deep analysis of any document or file.",
      "placeholder": "Upload a document or describe what to analyze...",
      "chips": [
        "Find key action items in this report",
        "Extract main conclusions from contract",
        "Summarize this 50-page whitepaper",
      ],
    },
    "url-summary": {
      "accent": const Color(0xFFC084FC),
      "dark": const Color(0xFF180A32),
      "desc": "Instantly summarize any webpage or article.",
      "placeholder": "Paste a URL to summarize...",
      "chips": [
        "https://example.com/article",
        "Summarize this research paper URL",
        "Extract key insights from this blog",
      ],
    },
    "write-song": {
      "accent": const Color(0xFFFB923C),
      "dark": const Color(0xFF1E0A00),
      "desc": "Create original lyrics with rhythm and soul.",
      "placeholder": "Describe the song you want...",
      "chips": [
        "Pop song about late-night coding",
        "Melancholic acoustic ballad",
        "Hip-hop about overcoming rejection",
      ],
    },
    "translate": {
      "accent": const Color(0xFF60A5FA),
      "dark": const Color(0xFF061428),
      "desc": "Translate between 100+ languages in seconds.",
      "placeholder": "Enter text and target language...",
      "chips": [
        "Translate to French: Good morning",
        "'I love building software' in Japanese",
        "'Thank you so much' in Arabic",
      ],
    },
    "explain-code": {
      "accent": const Color(0xFF4ADE80),
      "dark": const Color(0xFF021808),
      "desc": "Understand any code with crystal-clear explanations.",
      "placeholder": "Paste code or ask a coding question...",
      "chips": [
        "What does this async/await do?",
        "Explain time complexity of quicksort",
        "Why does this React hook re-render?",
      ],
    },
    "pdf-summarizer": {
      "accent": const Color(0xFFE879F9),
      "dark": const Color(0xFF220A2C),
      "desc": "Summarize lengthy PDFs in seconds.",
      "placeholder": "Upload PDF or describe what to summarize...",
      "chips": [
        "Summarize this 80-page research PDF",
        "Extract key findings from this report",
        "Create bullet points from this manual",
      ],
    },
    "brainstorm": {
      "accent": const Color(0xFFF97316),
      "dark": const Color(0xFF1E0800),
      "desc": "Generate creative ideas on demand.",
      "placeholder": "What do you want to brainstorm?",
      "chips": [
        "10 SaaS ideas for remote teams",
        "Creative names for AI productivity app",
        "Marketing angles for a health startup",
      ],
    },
    "email-writer": {
      "accent": const Color(0xFF38BDF8),
      "dark": const Color(0xFF04141E),
      "desc": "Write perfect professional emails.",
      "placeholder": "Describe the email you need...",
      "chips": [
        "Reschedule meeting professionally",
        "Follow-up after job interview",
        "Politely decline a vendor proposal",
      ],
    },
    "coding-assistant": {
      "accent": const Color(0xFF818CF8),
      "dark": const Color(0xFF0C0C2A),
      "desc": "Your AI pair programmer for any language.",
      "placeholder": "Describe what you want to build or fix...",
      "chips": [
        "React component for user profile card",
        "Python CSV parser with pandas",
        "Fix this TypeScript generic error",
      ],
    },
    "ai-notes": {
      "accent": const Color(0xFFFCD34D),
      "dark": const Color(0xFF1C1400),
      "desc": "AI-powered structured note-taking.",
      "placeholder": "Start your note or paste rough ideas...",
      "chips": [
        "Organize my meeting notes into actions",
        "Create study plan for TypeScript",
        "Structure these brainstorm ideas",
      ],
    },
    "resume-analyzer": {
      "accent": const Color(0xFFA78BFA),
      "dark": const Color(0xFF14063C),
      "desc": "Optimize your resume to land more interviews.",
      "placeholder": "Paste your resume or job description...",
      "chips": [
        "Analyze resume for senior engineer role",
        "What skills am I missing for this job?",
        "Rewrite my experience bullets stronger",
      ],
    },
  };

  String _demoResponse(String query) {
    return 'I\'ve processed your request: **"$query"**\n\nRunning **on-device** with Llama 3.2 · Complete privacy\n\n**Analysis complete.** Here are the key insights:\n\n- The request has been fully understood and contextualized\n- Processing happened entirely within your device — zero data sent externally\n- Results are generated using the locally downloaded model\n- Response time: under 800ms on-device\n\n**Recommendation:** This task is well-suited for the on-device AI. For longer documents or complex multi-step analysis, consider the Mistral 7B model for higher accuracy.\n\nWould you like me to refine this or go deeper on any aspect?';
  }

  void _submit([String? overrideText]) {
    final q = (overrideText ?? _textController.text).trim();
    if (q.isEmpty || _loading) return;

    _textController.clear();
    setState(() {
      _input = q;
      _loading = true;
      _response = "";
      _dots = 0;
    });

    _dotsTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted) return;
      setState(() {
        _dots = (_dots + 1) % 4;
      });
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      _dotsTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _response = _demoResponse(q);
      });
    });
  }

  @override
  void dispose() {
    _dotsTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _configs[widget.action] ?? _configs["text-assistant"]!;
    final accent = cfg['accent'] as Color;
    final darkBg = cfg['dark'] as Color;
    final icon = _iconMap[widget.action] ?? LucideIcons.type;

    final foreColor = JemenaiTheme.foreground(widget.isDark);
    final mutedFore = JemenaiTheme.mutedForeground(widget.isDark);
    final cardBg = JemenaiTheme.card(widget.isDark);
    final border = JemenaiTheme.border(widget.isDark);

    return Scaffold(
      backgroundColor: JemenaiTheme.background(widget.isDark),
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
                IconButton(
                  onPressed: () => widget.onNavigate('home', {}),
                  icon: Icon(LucideIcons.chevronLeft, color: foreColor),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.isDark ? darkBg : accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        style: JemenaiTheme.fontDisplay(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: foreColor,
                        ),
                      ),
                      Text(
                        cfg['desc'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: JemenaiTheme.fontBody(
                          fontSize: 10,
                          color: mutedFore,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Body Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildBodyContent(
                cfg,
                accent,
                darkBg,
                icon,
                foreColor,
                mutedFore,
                cardBg,
                border,
              ),
            ),
          ),

          // Bottom Input
          _buildBottomInputBar(cfg, cardBg, border, foreColor),
        ],
      ),
    );
  }

  Widget _buildBodyContent(
    Map<String, dynamic> cfg,
    Color accent,
    Color darkBg,
    IconData icon,
    Color foreColor,
    Color mutedFore,
    Color cardBg,
    Color border,
  ) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 80),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: JemenaiTheme.gradBrand,
                borderRadius: BorderRadius.circular(50),
                boxShadow: JemenaiTheme.glowMd(widget.isDark),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Processing on device${"." * _dots}',
              style: JemenaiTheme.fontBody(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: foreColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Private · Offline · Instant',
              style: JemenaiTheme.fontBody(fontSize: 11, color: mutedFore),
            ),
          ],
        ),
      );
    }

    if (_response.isNotEmpty) {
      // Show query echo + response
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User query bubble
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              decoration: BoxDecoration(
                gradient: JemenaiTheme.gradBrand,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                _input,
                style: JemenaiTheme.fontBody(
                  fontSize: 13.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Assistant response bubble
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8, top: 4),
                decoration: BoxDecoration(
                  gradient: JemenaiTheme.gradBrand,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(color: border),
                    boxShadow: JemenaiTheme.shadowCard(widget.isDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _parseResponseText(_response, foreColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Response Actions
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _response = "";
                      _input = "";
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: JemenaiTheme.secondary(widget.isDark),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.rotateCcw, size: 14, color: mutedFore),
                        const SizedBox(width: 6),
                        Text(
                          'Try another',
                          style: JemenaiTheme.fontBody(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: mutedFore,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => widget.onNavigate('chat', {'prompt': _input}),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: JemenaiTheme.gradBrand,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: JemenaiTheme.glowSm(widget.isDark),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Open in Chat',
                          style: JemenaiTheme.fontBody(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          LucideIcons.share2,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Default Hero screen
    final chips = cfg['chips'] as List<String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Logo Block
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.isDark ? darkBg : accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: accent, size: 36),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          widget.label,
          textAlign: TextAlign.center,
          style: JemenaiTheme.fontDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: foreColor,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            cfg['desc'] as String,
            textAlign: TextAlign.center,
            style: JemenaiTheme.fontBody(
              fontSize: 13,
              color: JemenaiTheme.mutedForeground(widget.isDark),
              lineHeight: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Suggestions
        Text(
          'TRY THESE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: mutedFore,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        Column(
          children:
              chips.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () => _submit(c),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: border),
                        boxShadow: JemenaiTheme.shadowCard(widget.isDark),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.sparkles, size: 14, color: accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              c,
                              style: JemenaiTheme.fontBody(
                                fontSize: 12.5,
                                color: JemenaiTheme.mutedForeground(
                                  widget.isDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  List<Widget> _parseResponseText(String text, Color textColor) {
    final parts = text.split(RegExp(r'(\*\*[\s\S]*?\*\*)'));
    List<Widget> children = [];

    for (var part in parts) {
      if (part.isEmpty) continue;
      if (part.startsWith('**') && part.endsWith('**')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              part.substring(2, part.length - 2),
              style: JemenaiTheme.fontBody(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              part,
              style: JemenaiTheme.fontBody(
                fontSize: 13.5,
                color: textColor,
                lineHeight: 1.45,
              ),
            ),
          ),
        );
      }
    }
    return children;
  }

  Widget _buildBottomInputBar(
    Map<String, dynamic> cfg,
    Color cardBg,
    Color border,
    Color foreColor,
  ) {
    final mutedFore = JemenaiTheme.mutedForeground(widget.isDark);
    final hasInput = _textController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: JemenaiTheme.background(widget.isDark),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(LucideIcons.paperclip, size: 16, color: mutedFore),
                style: IconButton.styleFrom(padding: EdgeInsets.zero),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    style: JemenaiTheme.fontBody(
                      fontSize: 14,
                      color: foreColor,
                    ),
                    onChanged: (text) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: cfg['placeholder'] as String,
                      hintStyle: JemenaiTheme.fontBody(
                        fontSize: 13,
                        color: mutedFore,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(LucideIcons.mic, size: 16, color: mutedFore),
                style: IconButton.styleFrom(padding: EdgeInsets.zero),
              ),
              InkWell(
                onTap: hasInput && !_loading ? () => _submit() : null,
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient:
                        hasInput && !_loading ? JemenaiTheme.gradBrand : null,
                    color:
                        hasInput && !_loading
                            ? null
                            : JemenaiTheme.secondary(widget.isDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.arrowUp,
                    size: 16,
                    color: hasInput && !_loading ? Colors.white : mutedFore,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
