import 'package:flutter/material.dart';
import 'package:jemenai/shared/navigator/app_route_string.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:jemenai/features/dashboard/views/dashboard.dart';
import '../../../shared/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      'id': 'ai-image',
      'icon': Icons.image,
      'label': 'AI Image',
      'accent': const Color(0xFFF472B6),
      'darkBg': const Color(0xFF2D0A20),
    },
    {
      'id': 'voice-to-text',
      'icon': Icons.mic,
      'label': 'Voice-to-Text',
      'accent': const Color(0xFF34D399),
      'darkBg': const Color(0xFF022016),
    },
    {
      'id': 'doc-analysis',
      'icon': Icons.description,
      'label': 'Doc Analysis',
      'accent': const Color(0xFFFBBF24),
      'darkBg': const Color(0xFF201800),
    },

    {
      'id': 'write-song',
      'icon': Icons.music_note,
      'label': 'Write Song',
      'accent': const Color(0xFFFB923C),
      'darkBg': const Color(0xFF1E0A00),
    },
    {
      'id': 'translate',
      'icon': Icons.translate,
      'label': 'Translate',
      'accent': const Color(0xFF60A5FA),
      'darkBg': const Color(0xFF061428),
    },
    {
      'id': 'explain-code',
      'icon': Icons.code,
      'label': 'Explain Code',
      'accent': const Color(0xFF4ADE80),
      'darkBg': const Color(0xFF021808),
    },
    {
      'id': 'pdf-summarizer',
      'icon': Icons.find_in_page,
      'label': 'PDF Summarizer',
      'accent': const Color(0xFFE879F9),
      'darkBg': const Color(0xFF220A2C),
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

    {
      'id': 'resume-analyzer',
      'icon': Icons.assignment_turned_in,
      'label': 'Resume Analyzer',
      'accent': const Color(0xFFA78BFA),
      'darkBg': const Color(0xFF14063C),
    },
  ];

  final List<String> _prompts = [
    'Explain quantum computing simply',
    'Write a professional cold email',

    'Summarize this research paper',
  ];

  final List<Map<String, dynamic>> _recentChats = [
    {'t': 'Explain React hooks in depth', 'm': 'Llama 3.2', 'when': '2m ago'},
    {
      't': 'Write a business proposal for...',
      'm': 'Phi-3 Mini',
      'when': '1h ago',
    },
    {
      't': 'Python script for data analysis',
      'm': 'Llama 3.2',
      'when': '3h ago',
    },
  ];

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
                  decoration: BoxDecoration(
                    gradient: JemenaiTheme.gradBrand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 14,
                  ),
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

  void _showModelSelectionModal(BuildContext context, String query) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;
    final cardBg = jc.card;
    final border = jc.border;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
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
                  style: JemenaiTheme.fontBody(fontSize: 12, color: mutedFore),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildModelOption(
                  context,
                  name: 'Llama 3.2 3B',
                  specialty: 'General Assistant',
                  description: 'Versatile and perfect for everyday tasks.',
                  maker: 'Meta',
                  size: '2.0 GB',
                  speed: 'Fast',
                  icon: Icons.auto_awesome,
                  query: query,
                ),
                const SizedBox(height: 10),
                _buildModelOption(
                  context,
                  name: 'Phi-3 Mini',
                  specialty: 'Coding & Reasoning',
                  description: 'Exceptional for logic and math tasks.',
                  maker: 'Microsoft',
                  size: '1.8 GB',
                  speed: 'Fast',
                  icon: Icons.code,
                  query: query,
                  customColor: theme.colorScheme.tertiary,
                ),
                const SizedBox(height: 10),
                _buildModelOption(
                  context,
                  name: 'Mistral 7B',
                  specialty: 'Advanced Reasoning',
                  description: 'Superior multilingual capabilities.',
                  maker: 'Mistral',
                  size: '4.1 GB',
                  speed: 'Medium',
                  icon: Icons.psychology,
                  query: query,
                  customColor: Colors.pinkAccent,
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
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
  }

  Widget _buildModelOption(
    BuildContext context, {
    required String name,
    required String specialty,
    required String description,
    required String maker,
    required String size,
    required String speed,
    required IconData icon,
    required String query,
    Color? customColor,
  }) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _askController.clear();
        AppRouter.push(
          AppRouteString.chat,
          args: {'modelName': name, 'prompt': query},
        );
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
                gradient: customColor == null ? JemenaiTheme.gradBrand : null,
                color: customColor?.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: customColor ?? Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: JemenaiTheme.fontBody(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: foreColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· $maker',
                        style: JemenaiTheme.fontBody(
                          fontSize: 11,
                          color: mutedFore,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: jc.secondaryFill,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    size,
                    style: JemenaiTheme.fontBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: mutedFore,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        speed == 'Fast'
                            ? const Color(0xFF022016)
                            : const Color(0xFF1C1400),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          speed == 'Fast'
                              ? const Color(0xFF4ADE80).withOpacity(0.18)
                              : const Color(0xFFFBBF24).withOpacity(0.18),
                    ),
                  ),
                  child: Text(
                    speed,
                    style: JemenaiTheme.fontBody(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color:
                          speed == 'Fast'
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFFFBBF24),
                    ),
                  ),
                ),
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
              onTap: () {},
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
                      onTap:
                          () => AppRouter.push(
                            AppRouteString.chat,
                            args: {'prompt': p},
                          ),
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
            children:
                _recentChats.map((chat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => AppRouter.push(AppRouteString.chat),
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
                                    chat['t'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: JemenaiTheme.fontBody(
                                      fontSize: 13,
                                      color: foreColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${chat['m'] as String} · ${chat['when'] as String}',
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
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
