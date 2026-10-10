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
import 'package:jemenai/shared/ui_helpers.dart';
import 'package:jemenai/shared/widgets/model_avatar.dart';
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

  // `draft` pre-fills the chat input for the user to finish; nothing is sent
  // until they tap send.
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
      'needs': AIModality.image,
      'draft': 'Extract all the text in this image.',
      'pickImage': true,
    },
    {
      'id': 'voice-to-text',
      'icon': Icons.mic,
      'label': 'Voice-to-Text',
      'accent': const Color(0xFF34D399),
      'darkBg': const Color(0xFF022016),
      'needs': AIModality.audio,
    },
    {
      'id': 'write-song',
      'icon': Icons.music_note,
      'label': 'Write Song',
      'accent': const Color(0xFFFB923C),
      'darkBg': const Color(0xFF1E0A00),
      'draft': 'Write a song with two verses and a chorus about ',
    },
    {
      'id': 'brainstorm',
      'icon': Icons.lightbulb_outline,
      'label': 'Brainstorm Ideas',
      'accent': const Color(0xFFF97316),
      'darkBg': const Color(0xFF1E0800),
      'draft': 'Brainstorm 10 creative ideas for ',
    },
    {
      'id': 'email-writer',
      'icon': Icons.mail_outline,
      'label': 'Email Writer',
      'accent': const Color(0xFF38BDF8),
      'darkBg': const Color(0xFF04141E),
      'draft': 'Write a short, professional email to ',
    },
  ];

  final List<String> _prompts = [
    'Explain quantum computing simply',
    'Write a professional cold email',
    'Plan a relaxed 3-day trip to Lisbon',
  ];

  final List<Map<String, dynamic>> _recentChats = [];
  bool _isLoadingChats = false;
  final int _chatLimit = 5;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
  }

  Future<void> _loadRecentChats() async {
    if (_isLoadingChats) return;
    setState(() => _isLoadingChats = true);
    try {
      final sessions = await DatabaseService().getSessions(limit: _chatLimit);
      if (!mounted) return;
      setState(() {
        _recentChats
          ..clear()
          ..addAll(sessions);
      });
    } catch (e) {
      debugPrint('Failed to load recent chats: $e');
    } finally {
      if (mounted) setState(() => _isLoadingChats = false);
    }
  }

  /// Opens a screen and refreshes Recent Chats when the user comes back,
  /// since that screen may have created, renamed or deleted conversations.
  Future<void> _openAndRefresh(String route, {Object? args}) async {
    await AppRouter.push(route, args: args);
    if (mounted) await _loadRecentChats();
  }

  String _timeAgo(int timestamp) =>
      timeAgo(DateTime.fromMillisecondsSinceEpoch(timestamp));

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

            // First-run nudge: nothing works until a model is on the device.
            BlocBuilder<ModelDownloadCubit, ModelDownloadState>(
              builder: (context, state) {
                if (state is! ModelDownloadUpdated ||
                    state.statuses.values.any(
                      (s) => s.phase == DownloadPhase.installed,
                    )) {
                  return const SizedBox.shrink();
                }
                return _buildGetStartedCard(theme);
              },
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
                    _getGreeting(),
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
                  padding: const EdgeInsets.all(3),
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
                    textInputAction: TextInputAction.send,
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
                      onTap: () => _openAndRefresh(AppRouteString.voice),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.jColors.secondaryFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.graphic_eq,
                          color: mutedFore,
                          size: 14,
                          semanticLabel: 'Voice mode',
                        ),
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

  Widget _buildGetStartedCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.callback?.call(1),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: JemenaiTheme.gradBrand,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.download_for_offline,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download your first model',
                        style: JemenaiTheme.fontDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Qwen2.5 0.5B is just 500 MB, needs no account, and runs on almost any phone.',
                        style: JemenaiTheme.fontBody(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
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
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
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
          _openAndRefresh(
            AppRouteString.chat,
            args: ChatScreenArg(modelName: model.name, initialPrompt: query),
          );
        } else {
          AppRouter.openDashboardTab(AppRouter.modelsTab);
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
            ModelAvatar(model: model, size: 40, radius: 12),
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
                final needs = action['needs'] as AIModality?;
                final downloadedModel =
                    models
                        .where(
                          (m) =>
                              needs == null ||
                              m.inputModalities.contains(needs),
                        )
                        .where(
                          (m) =>
                              cubit.statusFor(m.id).phase ==
                              DownloadPhase.installed,
                        )
                        .firstOrNull;

                if (downloadedModel != null) {
                  _openAndRefresh(
                    AppRouteString.chat,
                    args: ChatScreenArg(
                      modelName: downloadedModel.name,
                      draft: action['draft'] as String?,
                      pickImage: action['pickImage'] == true,
                    ),
                  );
                } else {
                  final kind = switch (needs) {
                    AIModality.image => 'an image-capable model',
                    AIModality.audio => 'an audio-capable model',
                    _ => 'a model',
                  };
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        // Actions make SnackBars sticky by default.
                        persist: false,
                        content: Text(
                          '$label needs $kind. Download one first.',
                        ),
                        action: SnackBarAction(
                          label: 'Store',
                          onPressed:
                              () => AppRouter.openDashboardTab(
                                AppRouter.modelsTab,
                              ),
                        ),
                      ),
                    );
                }
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? darkBg : accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isDark ? darkBg : accent.withValues(alpha: 0.12),
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
                        color: accent.withValues(alpha: 0.15),
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
                                  ? Colors.white.withValues(alpha: 0.88)
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

  Future<void> _confirmDelete(Map<String, dynamic> chat) async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete Chat',
      message:
          'Are you sure you want to delete this conversation? This action cannot be undone.',
    );
    if (!confirmed) return;
    try {
      await DatabaseService().deleteSession(chat['id'] as String);
      if (!mounted) return;
      setState(() => _recentChats.removeWhere((c) => c['id'] == chat['id']));
      AppRouter.showMessage('Conversation deleted');
      _loadRecentChats();
    } catch (e) {
      AppRouter.showMessage('Failed to delete conversation: $e');
    }
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
                onTap: () => _openAndRefresh(AppRouteString.chatsList),
                borderRadius: BorderRadius.circular(8),
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

        if (_recentChats.isEmpty && !_isLoadingChats)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Icon(Icons.forum_outlined, size: 18, color: mutedFore),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your conversations will appear here. They never leave this device.',
                      style: JemenaiTheme.fontBody(
                        fontSize: 12,
                        color: mutedFore,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: List.generate(_recentChats.length, (index) {
              final chat = _recentChats[index];
              final chatModel = findModelByName(chat['modelName'] as String?);
              return SwipeableChatItem(
                key: ValueKey(chat['id']),
                onDelete: () => _confirmDelete(chat),
                bottomMargin: 8.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      if (chatModel == null) {
                        AppRouter.showMessage(
                          "This chat's model is no longer available.",
                        );
                        return;
                      }
                      _openAndRefresh(
                        AppRouteString.chat,
                        args: ChatScreenArg(
                          sessionId: chat['id'] as String,
                          modelName: chatModel.name,
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
                          if (chatModel != null)
                            ModelAvatar(model: chatModel, size: 32)
                          else
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
                                  [
                                    if (chat['modelName'] != null)
                                      chat['modelName'],
                                    _timeAgo(chat['updatedAt'] as int),
                                  ].join(' · '),
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
