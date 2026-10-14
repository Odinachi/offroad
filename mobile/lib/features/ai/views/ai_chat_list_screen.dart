import 'package:flutter/material.dart';
import 'package:jemenai/features/ai/views/chat_screen.dart';
import 'package:jemenai/features/ai/views/swipeable_chat_item.dart';
import 'package:jemenai/shared/navigator/app_route_string.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:jemenai/services/db_service.dart';
import 'package:jemenai/features/ai/model/ai_model.dart';
import 'package:jemenai/shared/ui_helpers.dart';
import 'package:jemenai/shared/widgets/model_avatar.dart';
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

  Future<void> _loadChats({bool reset = false}) async {
    if (_isLoading || (!_hasMore && !reset)) return;
    setState(() => _isLoading = true);
    try {
      final sessions = await DatabaseService().getSessions(
        limit: _limit,
        // Offset by what's on screen, so deletions don't skip rows.
        offset: reset ? 0 : _chats.length,
      );
      if (!mounted) return;
      setState(() {
        if (reset) _chats.clear();
        _chats.addAll(sessions);
        _hasMore = sessions.length == _limit;
      });
    } catch (e) {
      debugPrint('Failed to load chats: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      setState(() => _chats.removeWhere((c) => c['id'] == chat['id']));
      AppRouter.showMessage('Conversation deleted');
    } catch (e) {
      AppRouter.showMessage('Failed to delete conversation: $e');
    }
  }

  Future<void> _open(Map<String, dynamic> chat, AIModel? model) async {
    if (model == null) {
      AppRouter.showMessage("This chat's model is no longer available.");
      return;
    }
    await AppRouter.push(
      AppRouteString.chat,
      args: ChatScreenArg(
        sessionId: chat['id'] as String,
        modelName: model.name,
      ),
    );
    if (mounted) await _loadChats(reset: true);
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
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.forum_outlined,
                                  size: 40,
                                  color: mutedFore,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No conversations yet',
                                  style: JemenaiTheme.fontDisplay(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: foreColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Chats you start are saved privately on this device.',
                                  textAlign: TextAlign.center,
                                  style: JemenaiTheme.fontBody(
                                    fontSize: 12,
                                    color: mutedFore,
                                  ),
                                ),
                              ],
                            ),
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
                            final chatModel = findModelByName(
                              chat['modelName'] as String?,
                            );

                            return SwipeableChatItem(
                              key: ValueKey(chat['id']),
                              onDelete: () => _confirmDelete(chat),
                              bottomMargin: 10.0,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: InkWell(
                                  onTap: () => _open(chat, chatModel),
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
                                      boxShadow: JemenaiTheme.shadowCard(
                                        isDark,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (chatModel != null) ...[
                                              ModelAvatar(
                                                model: chatModel,
                                                size: 20,
                                                radius: 6,
                                              ),
                                              const SizedBox(width: 8),
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
                                              timeAgo(
                                                DateTime.fromMillisecondsSinceEpoch(
                                                  chat['updatedAt'] as int,
                                                ),
                                              ),
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
                                                .withValues(alpha: 0.75),
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
