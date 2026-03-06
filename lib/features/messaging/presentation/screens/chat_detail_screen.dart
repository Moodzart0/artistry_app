import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../services/mock_data_service.dart';
import '../../domain/conversation_model.dart';
import '../../domain/message_model.dart';

/// Chat detail screen showing messages in a conversation.
class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.conversation,
  });

  final ConversationModel conversation;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late List<MessageModel> _messages;

  @override
  void initState() {
    super.initState();
    _messages = MockDataService.getMessages(widget.conversation.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        MessageModel(
          id: 'msg-new-${_messages.length}',
          conversationId: widget.conversation.id,
          senderId: 'current-user',
          content: text,
          isMe: true,
          createdAt: DateTime.now(),
        ),
      );
    });
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.conversation.participant;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: participant.avatarUrl != null
                  ? CachedNetworkImageProvider(participant.avatarUrl!)
                  : null,
              child: participant.avatarUrl == null
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          participant.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (participant.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            size: 14, color: AppColors.primary),
                      ],
                    ],
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages list ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showDate = index == 0 ||
                    _shouldShowDate(
                        _messages[index - 1].createdAt, message.createdAt);

                return Column(
                  children: [
                    if (showDate && message.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          _formatDate(message.createdAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    _MessageBubble(message: message),
                  ],
                );
              },
            ),
          ),

          // ── Input bar ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {},
                  color: AppColors.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.brush_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Drawing messages coming in Phase 3!'),
                      ),
                    );
                  },
                  color: AppColors.primary,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _sendMessage,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDate(DateTime? prev, DateTime? current) {
    if (prev == null || current == null) return false;
    return prev.day != current.day ||
        prev.month != current.month ||
        prev.year != current.year;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// A single message bubble.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe
                ? const Radius.circular(18)
                : const Radius.circular(4),
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : null,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.createdAt?.timeAgo ?? '',
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? Colors.white.withAlpha(179)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
