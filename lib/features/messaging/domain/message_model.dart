import 'package:equatable/equatable.dart';

/// Represents a single message in a conversation.
class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.imageUrl,
    this.messageType = 'text',
    this.isMe = false,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final String? imageUrl;
  final String messageType;
  final bool isMe;
  final bool isRead;
  final DateTime? createdAt;

  factory MessageModel.fromJson(Map<String, dynamic> json,
      {bool isMe = false}) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      messageType: (json['message_type'] as String?) ?? 'text',
      isMe: isMe,
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, conversationId, senderId, content];
}
