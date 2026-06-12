import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jemenai/features/ai/model/ai_model.dart';
import 'package:jemenai/features/ai/views/chat_screen.dart';
import 'package:jemenai/features/ai/views/swipeable_chat_item.dart';
import 'package:jemenai/services/db_service.dart';
import 'package:jemenai/shared/assets.dart';
import 'package:jemenai/shared/navigator/app_route_string.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:jemenai/features/ai/view_models/model_download_cubit.dart';
import '../../../shared/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.callback});

  final Function(int page)? callback;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _askController = TextEditingController();

  @override
  void dispose() {
    _askController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _quickActions = [
    {
      'id': 'text-assistant',
      'icon': Icons.title,
      'label': 'AI Text Assistant',
      'accent': const Color(0xFF818CF8),
      'darkBg': const Color(0xFF12123A),
    },
    {
      'id': 'pic-to-text',
      'icon': Icons.camera_alt,
      'label': 'Pic-to-Text',
      'accent': const Color(0xFFA78BFA),
      'darkBg': const Color(0xFF16103A),
    },

    {
      'id': 'voice-to-text',
      'icon': Icons.mic,
      'label': 'Voice-to-Text',
      'accent': const Color(0xFF34D399),
      'darkBg': const Color(0xFF022016),
    },

    {
      'id': 'write-song',
      'icon': Icons.music_note,
      'label': 'Write Song',
      'accent': const Color(0xFFFB923C),
      'darkBg': const Color(0xFF1E0A00),
    },

    {
      'id': 'brainstorm',
      'icon': Icons.lightbulb_outline,
      'label': 'Brainstorm Ideas',
      'accent': const Color(0xFFF97316),
      'darkBg': const Color(0xFF1E0800),
    },
    {
      'id': 'email-writer',
      'icon': Icons.mail_outline,
      'label': 'Email Writer',
      'accent': const Color(0xFF38BDF8),
      'darkBg': const Color(0xFF04141E),
    },
  ];

  final List<String> _prompts = [
    'Explain quantum computing simply',
    'Write a professional cold email',

    'Summarize this research paper',
  ];

  final List<Map<String, dynamic>> _recentChats = [];
  bool _isLoadingChats = false;
  bool _hasMoreChats = true;
  int _chatOffset = 0;
  final int _chatLimit = 5;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
  }

  Future<void> _loadRecentChats() async {
    if (_isLoadingChats || !_hasMoreChats) return;
    setState(() => _isLoadingChats = true);
    try {
      final sessions = await DatabaseService().getSessions(
        limit: _chatLimit,
        offset: _chatOffset,
      );
      setState(() {
        if (sessions.isEmpty) {
          _hasMoreChats = false;
        } else {
          _recentChats.addAll(sessions);
          _chatOffset += _chatLimit;
        }
        _isLoadingChats = false;
      });
    } catch (e) {
      setState(() => _isLoadingChats = false);
    }
  }

  String _timeAgo(int timestamp) {
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;
    final cardBg = jc.card;
    final border = jc.border;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Header
            _buildHeroHeader(
              theme,
              isDark,
              foreColor,
              mutedFore,
              cardBg,
              border,
            ),

            // Suggested Prompts
            _buildSuggestedPrompts(theme, isDark, foreColor, cardBg, border),

            // Quick Actions Grid
            _buildQuickActions(isDark, foreColor, mutedFore),

            // Recent Chats
            _buildRecentChats(
              theme,
              isDark,
              foreColor,
              mutedFore,
              cardBg,
              border,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(
    ThemeData theme,
    bool isDark,
    Color foreColor,
    Color mutedFore,
    Color cardBg,
    Color border,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting().toUpperCase(),
                    style: JemenaiTheme.fontBody(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: mutedFore,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Alex Wilson',
                    style: JemenaiTheme.fontDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: foreColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Ask Anything search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: border),
              boxShadow: JemenaiTheme.shadowCard(isDark),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: JemenaiTheme.gradBrand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Assets.svg.appLogo.svg(color: AppColors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _askController,
                    decoration: InputDecoration(
                      filled: false,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Ask anything...',
                      hintStyle: JemenaiTheme.fontBody(
                        fontSize: 14,
                        color: mutedFore,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: JemenaiTheme.fontBody(
                      fontSize: 14,
                      color: foreColor,
                    ),
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _showModelSelectionModal(context, value.trim());
                      }
                    },
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        AppRouter.push(AppRouteString.voice);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.jColors.secondaryFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.mic, color: mutedFore, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showModelSelectionModal(BuildContext context, String query) async {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;
    final cardBg = jc.card;
    final border = jc.border;

    final a = await showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return BlocBuilder<ModelDownloadCubit, ModelDownloadState>(
          builder: (context, state) {
            final cubit = context.read<ModelDownloadCubit>();
            final textModels =
                models
                    .where((m) => m.inputModalities.contains(AIModality.text))
                    .where(
                      (m) =>
                          cubit.statusFor(m.id).phase ==
                          DownloadPhase.installed,
                    )
                    .toList();

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select AI Model',
                      style: JemenaiTheme.fontDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: foreColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a model to process your request',
                      style: JemenaiTheme.fontBody(
                        fontSize: 12,
                        color: mutedFore,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (textModels.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No models downloaded yet.\nPlease download a model to start chatting.',
                          style: JemenaiTheme.fontBody(
                            fontSize: 14,
                            color: mutedFore,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: textModels.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final model = textModels[index];
                            final status = cubit.statusFor(model.id);
                            final isInstalled =
                                status.phase == DownloadPhase.installed;
                            return _buildModelOption(
                              context,
                              model: model,
                              query: query,
                              isInstalled: isInstalled,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: AppColors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        AppRouter.pop(true);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_download_outlined,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Explore & Download More Models',
                              style: JemenaiTheme.fontBody(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (a == true) {
      widget.callback?.call(1);
    }
  }

  Widget _buildModelOption(
    BuildContext context, {
    required AIModel model,
    required String query,
    required bool isInstalled,
  }) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (isInstalled) {
          _askController.clear();
          AppRouter.push(
            AppRouteString.chat,
            args: ChatScreenArg(modelName: model.name, initialPrompt: query),
          );
        } else {
          // Navigate to storage to download
          AppRouter.push(AppRouteString.dashboard, args: {'index': 1});
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: jc.muted,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: jc.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  model.image != null
                      ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(model.image!.path),
                      )
                      : Icon(
                        Icons.auto_awesome,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        model.name,
                        style: JemenaiTheme.fontBody(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: foreColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· ${model.maker}',
                        style: JemenaiTheme.fontBody(
                          fontSize: 11,
                          color: mutedFore,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    model.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: JemenaiTheme.fontBody(
                      fontSize: 11,
                      color: jc.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isInstalled)
                  Icon(
                    Icons.download_for_offline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, Color foreColor, Color mutedFore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Actions',
                style: JemenaiTheme.fontDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: foreColor,
                ),
              ),
              Text(
                '${_quickActions.length} tools',
                style: JemenaiTheme.fontBody(fontSize: 11, color: mutedFore),
              ),
            ],
          ),
        ),

        // Grid of tools
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 68,
          ),
          itemCount: _quickActions.length,
          itemBuilder: (context, index) {
            final action = _quickActions[index];
            final accent = action['accent'] as Color;
            final darkBg = action['darkBg'] as Color;
            final icon = action['icon'] as IconData;
            final label = action['label'] as String;

            return InkWell(
              onTap: () {
                final cubit = context.read<ModelDownloadCubit>();
                final bool needsVision =
                    action['id'] == 'pic-to-text' ||
                    action['id'] == 'doc-analysis';
                final bool needsAudio = action['id'] == 'voice-to-text';

                final matchingModels =
                    models.where((m) {
                      if (needsVision &&
                          !m.inputModalities.contains(AIModality.image))
                        return false;
                      if (needsAudio &&
                          !m.inputModalities.contains(AIModality.audio))
                        return false;
                      return m.inputModalities.contains(AIModality.text);
                    }).toList();

                final downloadedModel =
                    matchingModels
                        .where(
                          (m) =>
                              cubit.statusFor(m.id).phase ==
                              DownloadPhase.installed,
                        )
                        .firstOrNull;

                if (downloadedModel != null) {
                  AppRouter.push(
                    AppRouteString.chat,
                    args: ChatScreenArg(
                      modelName: downloadedModel.name,
                      initialPrompt: 'Help me with $label',
                    ),
                  );
                } else {
                  // No model installed for this, prompt to store
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please download a model that supports $label first.',
                      ),
                      action: SnackBarAction(
                        label: 'Store',
                        onPressed: () {
                          AppRouter.push(
                            AppRouteString.dashboard,
                            args: {'index': 1},
                          );
                        },
                      ),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? darkBg : accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isDark ? darkBg : accent.withOpacity(0.12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: JemenaiTheme.fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark
                                  ? Colors.white.withOpacity(0.88)
                                  : foreColor,
                          lineHeight: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSuggestedPrompts(
    ThemeData theme,
    bool isDark,
    Color foreColor,
    Color cardBg,
    Color border,
  ) {
    final jc = theme.jColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Try asking...',
                style: JemenaiTheme.fontDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: foreColor,
                ),
              ),
            ],
          ),
        ),

        // List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children:
                _prompts.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => _showModelSelectionModal(context, p),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: border),
                          boxShadow: JemenaiTheme.shadowCard(isDark),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                p,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: JemenaiTheme.fontBody(
                                  fontSize: 13,
                                  color: jc.mutedForeground,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_outward,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    Map<String, dynamic> chat,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            'Delete Chat',
            style: JemenaiTheme.fontDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this conversation? This action cannot be undone.',
            style: JemenaiTheme.fontBody(
              fontSize: 14,
              color: theme.jColors.mutedForeground,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: JemenaiTheme.fontBody(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await DatabaseService().deleteSession(chat['id']);
                  setState(() {
                    _recentChats.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Conversation deleted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete conversation: $e'),
                    ),
                  );
                }
              },
              child: Text(
                'Delete',
                style: JemenaiTheme.fontBody(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentChats(
    ThemeData theme,
    bool isDark,
    Color foreColor,
    Color mutedFore,
    Color cardBg,
    Color border,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: mutedFore),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Chats',
                    style: JemenaiTheme.fontDisplay(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: foreColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => AppRouter.push(AppRouteString.chatsList),
                child: Text(
                  'View all',
                  style: JemenaiTheme.fontBody(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: List.generate(_recentChats.length, (index) {
              final chat = _recentChats[index];
              return SwipeableChatItem(
                onDelete: () => _confirmDelete(context, chat, index),
                bottomMargin: 8.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      final modelName = chat['modelName'] as String?;
                      final modelExists = models.any(
                        (m) => m.name == modelName,
                      );
                      if (!modelExists) {
                        AppRouter.showMessage(
                          "This chat's model no longer exists and it can't be accessed.",
                        );
                        return;
                      }
                      AppRouter.push(
                        AppRouteString.chat,
                        args: ChatScreenArg(
                          sessionId: chat['id'],
                          modelName: chat['modelName'],
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                        boxShadow: JemenaiTheme.shadowCard(isDark),
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
                                  chat['title'] as String? ?? 'New Chat',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: JemenaiTheme.fontBody(
                                    fontSize: 13,
                                    color: foreColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _timeAgo(chat['updatedAt'] as int),
                                  style: JemenaiTheme.fontBody(
                                    fontSize: 11,
                                    color: mutedFore,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: mutedFore,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
