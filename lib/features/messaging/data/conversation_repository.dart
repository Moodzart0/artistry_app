import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase_service.dart';
import '../../auth/domain/user_profile.dart';
import '../domain/conversation_model.dart';
import '../domain/message_model.dart';

/// Repository for messaging operations, connecting to the Supabase backend.
class ConversationRepository {
  ConversationRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all conversations for the current user.
  Future<List<ConversationModel>> getConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('conversation_participants')
        .select('conversation_id, conversations(*)')
        .eq('user_id', userId);

    final conversations = <ConversationModel>[];
    for (final item in response as List) {
      final convJson = item['conversations'] as Map<String, dynamic>?;
      if (convJson == null) continue;

      // Find the other participant
      final participants = await _client
          .from('conversation_participants')
          .select('user_id, profiles(*)')
          .eq('conversation_id', convJson['id'])
          .neq('user_id', userId);

      if (participants.isEmpty) continue;

      final otherParticipant = participants.first;
      final profileJson =
          otherParticipant['profiles'] as Map<String, dynamic>?;
      if (profileJson == null) continue;

      final participant = UserProfile.fromJson(profileJson);

      // Get the latest message
      final lastMsgResponse = await _client
          .from('messages')
          .select()
          .eq('conversation_id', convJson['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      conversations.add(ConversationModel(
        id: convJson['id'] as String,
        participant: participant,
        lastMessage: lastMsgResponse?['content'] as String?,
        lastMessageAt: lastMsgResponse?['created_at'] != null
            ? DateTime.parse(lastMsgResponse!['created_at'] as String)
            : null,
      ));
    }

    return conversations;
  }

  /// Fetches messages for a specific conversation.
  Future<List<MessageModel>> getMessages(String conversationId,
      {int limit = 50, int offset = 0}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) {
      return MessageModel.fromJson(json,
          isMe: json['sender_id'] == userId);
    }).toList();
  }

  /// Sends a message in a conversation.
  Future<MessageModel?> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': userId,
          'content': content,
          'message_type': messageType,
        })
        .select()
        .single();

    return MessageModel.fromJson(response, isMe: true);
  }
}

/// Provider for ConversationRepository.
final conversationRepositoryProvider =
    Provider<ConversationRepository>((ref) {
  return ConversationRepository(ref.watch(supabaseClientProvider));
});
