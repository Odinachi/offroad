import 'package:flutter/material.dart';
import 'package:jemenai/features/ai/views/chat_screen.dart';
import 'package:jemenai/features/ai/views/swipeable_chat_item.dart';
import 'package:jemenai/shared/navigator/app_route_string.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:jemenai/services/db_service.dart';
import 'package:jemenai/features/ai/model/ai_model.dart';
import '../../../shared/theme.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final List<Map<String, dynamic>> _chats = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 15;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChats();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadChats();
    }
  }

  Future<void> _loadChats() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final sessions = await DatabaseService().getSessions(
        limit: _limit,
        offset: _offset,
      );
      setState(() {
        if (sessions.isEmpty) {
          _hasMore = false;
        } else {
          _chats.addAll(sessions);
          _offset += _limit;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  void _confirmDelete(BuildContext context, Map<String, dynamic> chat, int index) {
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
                    _chats.removeAt(index);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;
    final cardBg = jc.card;
    final border = jc.border;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: foreColor),
      ),
      body: SafeArea(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                      'All your past chats',
                      style: JemenaiTheme.fontBody(
                        fontSize: 12,
                        color: mutedFore,
                      ),
                    ),
                  ],
                ),
              ),

              // Chats List
              Expanded(
                child:
                    _chats.isEmpty && !_isLoading
                        ? Center(
                          child: Text(
                            'No conversations yet.',
                            style: TextStyle(color: mutedFore),
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          itemCount: _chats.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _chats.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final chat = _chats[index];
                            final isPinned =
                                false; // Add pin functionality later if needed

                            return SwipeableChatItem(
                              onDelete: () => _confirmDelete(context, chat, index),
                              bottomMargin: 10.0,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: InkWell(
                                  onTap: () {
                                    final modelName =
                                        chat['modelName'] as String?;
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: border),
                                      boxShadow: JemenaiTheme.shadowCard(isDark),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (isPinned) ...[
                                              Text(
                                                '📌',
                                                style: JemenaiTheme.fontBody(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                            ],
                                            Expanded(
                                              child: Text(
                                                chat['title'] as String? ??
                                                    'New Chat',
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
                                              _timeAgo(chat['updatedAt'] as int),
                                              style: JemenaiTheme.fontBody(
                                                fontSize: 11,
                                                color: mutedFore,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          chat['modelName'] as String? ??
                                              'Unknown',
                                          style: JemenaiTheme.fontBody(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.75),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
