import 'dart:typed_data';

import 'package:jemenai/services/chat_engine.dart';

class ChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  String content;
  final DateTime ts;
  bool pinned;
  bool liked;
  final Uint8List? imageBytes;

  /// The model's reasoning trace, when reasoning mode produced one.
  String? thinking;

  bool get isUser => role == 'user';

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.ts,
    this.pinned = false,
    this.liked = false,
    this.imageBytes,
    this.thinking,
  });

  factory ChatMessage.fromRow(Map<String, dynamic> row) {
    return ChatMessage(
      id: row['id'] as String,
      role: row['role'] as String,
      // Also repairs replies saved before normalizeReply existed.
      content:
          row['role'] == 'assistant'
              ? ChatEngine.normalizeReply(row['content'] as String? ?? '')
              : row['content'] as String? ?? '',
      thinking: row['thinking'] as String?,
      ts: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
    );
  }
}
