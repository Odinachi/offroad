import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/theme.dart';

class HomeScreen extends StatefulWidget {
  final Function(String, [Map<String, dynamic>]) onNavigate;
  final bool isDark;

  const HomeScreen({super.key, required this.onNavigate, required this.isDark});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _downloadController;
  late Animation<double> _downloadProgress;

  final List<Map<String, dynamic>> _quickActions = [
    {
      'id': 'text-assistant',
      'icon': LucideIcons.type,
      'label': 'AI Text Assistant',
      'accent': const Color(0xFF818CF8),
      'darkBg': const Color(0xFF12123A),
    },
    {
      'id': 'pic-to-text',
      'icon': LucideIcons.camera,
      'label': 'Pic-to-Text',
      'accent': const Color(0xFFA78BFA),
      'darkBg': const Color(0xFF16103A),
    },
    {
      'id': 'web-search',
      'icon': LucideIcons.globe,
      'label': 'Web Search',
      'accent': const Color(0xFF38BDF8),
      'darkBg': const Color(0xFF051C2C),
    },
    {
      'id': 'ai-image',
      'icon': LucideIcons.image,
      'label': 'AI Image',
      'accent': const Color(0xFFF472B6),
      'darkBg': const Color(0xFF2D0A20),
    },
    {
      'id': 'voice-to-text',
      'icon': LucideIcons.mic,
      'label': 'Voice-to-Text',
      'accent': const Color(0xFF34D399),
      'darkBg': const Color(0xFF022016),
    },
    {
      'id': 'doc-analysis',
      'icon': LucideIcons.fileText,
      'label': 'Doc Analysis',
      'accent': const Color(0xFFFBBF24),
      'darkBg': const Color(0xFF201800),
    },
    {
      'id': 'url-summary',
      'icon': LucideIcons.link2,
      'label': 'URL Summary',
      'accent': const Color(0xFFC084FC),
      'darkBg': const Color(0xFF180A32),
    },
    {
      'id': 'write-song',
      'icon': LucideIcons.music,
      'label': 'Write Song',
      'accent': const Color(0xFFFB923C),
      'darkBg': const Color(0xFF1E0A00),
    },
    {
      'id': 'translate',
      'icon': LucideIcons.languages,
      'label': 'Translate',
      'accent': const Color(0xFF60A5FA),
      'darkBg': const Color(0xFF061428),
    },
    {
      'id': 'explain-code',
      'icon': LucideIcons.code2,
      'label': 'Explain Code',
      'accent': const Color(0xFF4ADE80),
      'darkBg': const Color(0xFF021808),
    },
    {
      'id': 'pdf-summarizer',
      'icon': LucideIcons.fileSearch,
      'label': 'PDF Summarizer',
      'accent': const Color(0xFFE879F9),
      'darkBg': const Color(0xFF220A2C),
    },
    {
      'id': 'brainstorm',
      'icon': LucideIcons.lightbulb,
      'label': 'Brainstorm Ideas',
      'accent': const Color(0xFFF97316),
      'darkBg': const Color(0xFF1E0800),
    },
    {
      'id': 'email-writer',
      'icon': LucideIcons.mail,
      'label': 'Email Writer',
      'accent': const Color(0xFF38BDF8),
      'darkBg': const Color(0xFF04141E),
    },
    {
      'id': 'coding-assistant',
      'icon': LucideIcons.terminal,
      'label': 'AI Coding Assistant',
      'accent': const Color(0xFF818CF8),
      'darkBg': const Color(0xFF0C0C2A),
    },
    {
      'id': 'ai-notes',
      'icon': LucideIcons.stickyNote,
      'label': 'AI Notes',
      'accent': const Color(0xFFFCD34D),
      'darkBg': const Color(0xFF1C1400),
    },
    {
      'id': 'resume-analyzer',
      'icon': LucideIcons.fileCheck,
      'label': 'Resume Analyzer',
      'accent': const Color(0xFFA78BFA),
      'darkBg': const Color(0xFF14063C),
    },
  ];

  final List<Map<String, dynamic>> _models = [
    {
      'name': 'Llama 3.2 3B',
      'tag': 'General',
      'size': '2.0 GB',
      'active': true,
    },
    {'name': 'Phi-3 Mini', 'tag': 'Coding', 'size': '1.8 GB', 'active': false},
    {'name': 'Gemma 2B', 'tag': 'Creative', 'size': '1.4 GB', 'active': false},
  ];

  final List<String> _prompts = [
    'Explain quantum computing simply',
    'Write a professional cold email',
    'Debug my Python script',
    'Summarize this research paper',
  ];

  final List<Map<String, dynamic>> _trending = [
    {
      'label': 'Code Debugger',
      'icon': LucideIcons.code2,
      'uses': '2.1M',
      'accent': const Color(0xFF818CF8),
    },
    {
      'label': 'Essay Writer',
      'icon': LucideIcons.type,
      'uses': '1.8M',
      'accent': const Color(0xFFA78BFA),
    },
    {
      'label': 'Image Creator',
      'icon': LucideIcons.image,
      'uses': '1.5M',
      'accent': const Color(0xFFF472B6),
    },
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

  @override
  void initState() {
    super.initState();
    _downloadController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _downloadProgress = Tween<double>(begin: 0.64, end: 0.72).animate(
      CurvedAnimation(parent: _downloadController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _downloadController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final foreColor = JemenaiTheme.foreground(widget.isDark);
    final mutedFore = JemenaiTheme.mutedForeground(widget.isDark);
    final cardBg = JemenaiTheme.card(widget.isDark);
    final border = JemenaiTheme.border(widget.isDark);

    return Container(
      color: JemenaiTheme.background(widget.isDark),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Header
            _buildHeroHeader(foreColor, mutedFore),

            // Download Progress Strip
            _buildDownloadProgress(cardBg, border, foreColor, mutedFore),

            // Active Models
            _buildActiveModels(foreColor, mutedFore, cardBg, border),

            // Quick Actions Grid
            _buildQuickActions(foreColor, mutedFore),

            // Suggested Prompts
            _buildSuggestedPrompts(foreColor, cardBg, border),

            // Trending
            _buildTrending(foreColor, mutedFore, cardBg, border),

            // Recent Chats
            _buildRecentChats(foreColor, mutedFore, cardBg, border),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(Color foreColor, Color mutedFore) {
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
              InkWell(
                onTap: () => widget.onNavigate('chat', {}),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: JemenaiTheme.gradBrand,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: JemenaiTheme.glowSm(widget.isDark),
                  ),
                  child: const Icon(
                    LucideIcons.plus,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Ask Anything search bar
          InkWell(
            onTap: () => widget.onNavigate('chat', {}),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: JemenaiTheme.card(widget.isDark),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: JemenaiTheme.border(widget.isDark)),
                boxShadow: JemenaiTheme.shadowCard(widget.isDark),
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
                      LucideIcons.sparkles,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ask anything...',
                      style: JemenaiTheme.fontBody(
                        fontSize: 14,
                        color: mutedFore,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => widget.onNavigate('voice', {}),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: JemenaiTheme.secondary(widget.isDark),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.mic,
                            color: mutedFore,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: JemenaiTheme.secondary(widget.isDark),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.search,
                          color: mutedFore,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadProgress(
    Color cardBg,
    Color border,
    Color foreColor,
    Color mutedFore,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: border),
          boxShadow: JemenaiTheme.shadowCard(widget.isDark),
        ),
        child: Row(
          children: [
            // Pulsing Green dot
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF4ADE80),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mistral 7B',
                        style: JemenaiTheme.fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: foreColor,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _downloadProgress,
                        builder: (context, child) {
                          final p = _downloadProgress.value * 100;
                          return Text(
                            '${p.toStringAsFixed(0)}% · 12.4 MB/s',
                            style: JemenaiTheme.fontBody(
                              fontSize: 11,
                              color: mutedFore,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      height: 6,
                      color: JemenaiTheme.secondary(widget.isDark),
                      child: AnimatedBuilder(
                        animation: _downloadProgress,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _downloadProgress.value,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: JemenaiTheme.gradBrand,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '4m left',
              style: JemenaiTheme.fontBody(fontSize: 11, color: mutedFore),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveModels(
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
              Text(
                'Active Models',
                style: JemenaiTheme.fontDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: foreColor,
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigate('models', {}),
                child: Row(
                  children: [
                    Text(
                      'All models',
                      style: JemenaiTheme.fontBody(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: JemenaiTheme.primary(widget.isDark),
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 14,
                      color: JemenaiTheme.primary(widget.isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal List
        SizedBox(
          height: 104,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ..._models.map((model) {
                final active = model['active'] as bool;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: InkWell(
                    onTap:
                        () =>
                            widget.onNavigate('chat', {'model': model['name']}),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 128,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              active
                                  ? JemenaiTheme.jmIndigo(widget.isDark)
                                  : border,
                        ),
                        boxShadow:
                            active
                                ? JemenaiTheme.glowSm(widget.isDark)
                                : JemenaiTheme.shadowCard(widget.isDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient:
                                      active ? JemenaiTheme.gradBrand : null,
                                  color:
                                      active
                                          ? null
                                          : JemenaiTheme.secondary(
                                            widget.isDark,
                                          ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  LucideIcons.zap,
                                  size: 14,
                                  color: active ? Colors.white : mutedFore,
                                ),
                              ),
                              if (active)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4ADE80),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            model['name'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: JemenaiTheme.fontBody(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: foreColor,
                            ),
                          ),
                          Text(
                            model['size'] as String,
                            style: JemenaiTheme.fontBody(
                              fontSize: 11,
                              color: mutedFore,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // More Models Card
              InkWell(
                onTap: () => widget.onNavigate('models', {}),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: JemenaiTheme.secondary(widget.isDark),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: border,
                      style:
                          BorderStyle
                              .none, // simulates React border dashed or borderless bg
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.download, size: 18, color: mutedFore),
                      const SizedBox(height: 6),
                      Text(
                        'More models',
                        textAlign: TextAlign.center,
                        style: JemenaiTheme.fontBody(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: mutedFore,
                          lineHeight: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(Color foreColor, Color mutedFore) {
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
              onTap:
                  () => widget.onNavigate('quickaction', {
                    'action': action['id'],
                    'label': label,
                  }),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isDark ? darkBg : accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: widget.isDark ? darkBg : accent.withOpacity(0.12),
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
                              widget.isDark
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

  Widget _buildSuggestedPrompts(Color foreColor, Color cardBg, Color border) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                size: 16,
                color: JemenaiTheme.primary(widget.isDark),
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
                      onTap: () => widget.onNavigate('chat', {'prompt': p}),
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
                          boxShadow: JemenaiTheme.shadowCard(widget.isDark),
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
                                  color: JemenaiTheme.mutedForeground(
                                    widget.isDark,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              LucideIcons.arrowUpRight,
                              size: 14,
                              color: JemenaiTheme.primary(widget.isDark),
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

  Widget _buildTrending(
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
            children: [
              Icon(
                LucideIcons.trendingUp,
                size: 16,
                color: JemenaiTheme.primary(widget.isDark),
              ),
              const SizedBox(width: 8),
              Text(
                'Trending',
                style: JemenaiTheme.fontDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: foreColor,
                ),
              ),
            ],
          ),
        ),

        // Horizontal List
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _trending.length,
            itemBuilder: (context, index) {
              final trend = _trending[index];
              final icon = trend['icon'] as IconData;

              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: InkWell(
                  onTap: () => widget.onNavigate('chat', {}),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: border),
                      boxShadow: JemenaiTheme.shadowCard(widget.isDark),
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
                          child: Icon(icon, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              trend['label'] as String,
                              style: JemenaiTheme.fontBody(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: foreColor,
                              ),
                            ),
                            Text(
                              '${trend['uses'] as String} uses',
                              style: JemenaiTheme.fontBody(
                                fontSize: 10,
                                color: mutedFore,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentChats(
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
                  Icon(LucideIcons.clock, size: 16, color: mutedFore),
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
                onTap: () => widget.onNavigate('chats', {}),
                child: Text(
                  'View all',
                  style: JemenaiTheme.fontBody(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: JemenaiTheme.primary(widget.isDark),
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
                      onTap: () => widget.onNavigate('chat', {}),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: border),
                          boxShadow: JemenaiTheme.shadowCard(widget.isDark),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient:
                                    widget.isDark
                                        ? JemenaiTheme.gradSubtleDark
                                        : JemenaiTheme.gradSubtleLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                LucideIcons.sparkles,
                                size: 14,
                                color: JemenaiTheme.primary(widget.isDark),
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
                              LucideIcons.chevronRight,
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
