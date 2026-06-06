import 'package:flutter/material.dart';
import '../theme.dart';

class ChatsListScreen extends StatelessWidget {
  final Function(String, [Map<String, dynamic>]) onNavigate;
  final bool isDark;

  ChatsListScreen({super.key, required this.onNavigate, required this.isDark});

  final List<Map<String, dynamic>> _chats = [
    {
      'id': 1,
      't': "Explain React hooks in depth",
      'model': "Llama 3.2",
      'when': "2m ago",
      'pinned': true,
      'preview':
          "Let me break down React hooks with clear, practical examples...",
    },
    {
      'id': 2,
      't': "Business proposal for AI startup",
      'model': "Phi-3 Mini",
      'when': "1h ago",
      'pinned': false,
      'preview':
          "Here's a comprehensive proposal framework tailored to your...",
    },
    {
      'id': 3,
      't': "Python data analysis script",
      'model': "Llama 3.2",
      'when': "3h ago",
      'pinned': false,
      'preview': "I'll create a clean pandas + matplotlib pipeline for you...",
    },
    {
      'id': 4,
      't': "Translate paragraphs to French",
      'model': "Mistral 7B",
      'when': "Yesterday",
      'pinned': false,
      'preview': "Voici les traductions demandées avec contexte naturel...",
    },
    {
      'id': 5,
      't': "Debug TypeScript generic error",
      'model': "Phi-3 Mini",
      'when': "2d ago",
      'pinned': false,
      'preview':
          "The issue is a type mismatch in your generic constraint at line...",
    },
    {
      'id': 6,
      't': "Poem about the ocean at midnight",
      'model': "Gemma 2B",
      'when': "3d ago",
      'pinned': false,
      'preview': "Waves of data, infinite and deep, silver moonlight softly...",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final foreColor = JemenaiTheme.foreground(isDark);
    final mutedFore = JemenaiTheme.mutedForeground(isDark);
    final cardBg = JemenaiTheme.card(isDark);
    final border = JemenaiTheme.border(isDark);

    return Container(
      color: JemenaiTheme.background(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversations',
                  style: JemenaiTheme.fontDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: foreColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_chats.length} conversations',
                  style: JemenaiTheme.fontBody(fontSize: 12, color: mutedFore),
                ),
              ],
            ),
          ),

          // Chats List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                final pinned = chat['pinned'] as bool;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () => onNavigate('chat', {}),
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
                        boxShadow: JemenaiTheme.shadowCard(isDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (pinned) ...[
                                Text(
                                  '📌',
                                  style: JemenaiTheme.fontBody(fontSize: 12),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  chat['t'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: JemenaiTheme.fontBody(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: foreColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                chat['when'] as String,
                                style: JemenaiTheme.fontBody(
                                  fontSize: 11,
                                  color: mutedFore,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            chat['preview'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: JemenaiTheme.fontBody(
                              fontSize: 12,
                              color: mutedFore,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chat['model'] as String,
                            style: JemenaiTheme.fontBody(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: JemenaiTheme.primary(
                                isDark,
                              ).withOpacity(0.75),
                            ),
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
      ),
    );
  }
}
