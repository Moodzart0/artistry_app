import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/post_model.dart';

/// A single post card displayed in the home feed.
class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onProfileTap,
    this.onTimelapseTap,
  });

  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onProfileTap;
  final VoidCallback? onTimelapseTap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
    _isBookmarked = widget.post.isBookmarked;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    widget.onLike?.call();
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    widget.onBookmark?.call();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final user = post.user;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onProfileTap,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: user?.avatarUrl != null
                        ? CachedNetworkImageProvider(user!.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null
                        ? const Icon(Icons.person, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user?.displayName ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (user?.isVerified == true) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '@${user?.username ?? 'unknown'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                  iconSize: 20,
                ),
              ],
            ),
          ),

          // ── Image ──────────────────────────────────────────
          GestureDetector(
            onDoubleTap: _toggleLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 400,
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 400,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.broken_image, size: 48),
                  ),
                ),
                // Timelapse badge
                if (post.hasTimelapse)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: widget.onTimelapseTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(153),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_fill,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Timelapse',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Action buttons ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? AppColors.accent : null,
                  ),
                  onPressed: _toggleLike,
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: widget.onComment,
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: widget.onShare,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _isBookmarked ? AppColors.primary : null,
                  ),
                  onPressed: _toggleBookmark,
                ),
              ],
            ),
          ),

          // ── Likes count ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '${_likesCount.compact} likes',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ── Caption ────────────────────────────────────────
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: RichText(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: '${user?.username ?? 'unknown'} ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: post.caption),
                  ],
                ),
              ),
            ),

          // ── Comments link ──────────────────────────────────
          if (post.commentsCount > 0)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: GestureDetector(
                onTap: widget.onComment,
                child: Text(
                  'View all ${post.commentsCount} comments',
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          // ── Timestamp ──────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(
              post.createdAt?.timeAgo ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}
