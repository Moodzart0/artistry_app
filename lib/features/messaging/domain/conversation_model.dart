import 'package:equatable/equatable.dart';

import '../../auth/domain/user_profile.dart';

/// Represents a DM conversation in the conversation list.
class ConversationModel extends Equatable {
  const ConversationModel({
    required this.id,
    required this.participant,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final UserProfile participant;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  factory ConversationModel.fromJson(Map<String, dynamic> json,
      {required UserProfile participant}) {
    return ConversationModel(
      id: json['id'] as String,
      participant: participant,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: (json['unread_count'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, lastMessage, unreadCount];
}
