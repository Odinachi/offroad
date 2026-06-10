import 'dart:typed_data';

class ChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  String content;
  final DateTime ts;
  bool pinned;
  bool liked;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.ts,
    this.pinned = false,
    this.liked = false,
    this.imageBytes,
  });
}
