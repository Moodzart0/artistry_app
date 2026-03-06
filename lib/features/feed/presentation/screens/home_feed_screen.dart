import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/mock_data_service.dart';
import '../../domain/post_model.dart';
import '../widgets/post_card.dart';

/// Home feed screen showing a scrollable list of artwork posts.
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late List<PostModel> _posts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _posts = List.from(MockDataService.posts);
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _posts = List.from(MockDataService.posts);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Notifications screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: _posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return PostCard(
                          post: post,
                          onLike: () {
                            // TODO: Connect to backend
                          },
                          onComment: () {
                            _showCommentsSheet(context, post);
                          },
                          onProfileTap: () {
                            // TODO: Navigate to profile
                          },
                          onTimelapseTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Timelapse playback coming in Phase 4!'),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.art_track,
              size: 80, color: AppColors.onSurfaceVariant.withAlpha(128)),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow artists to see their work here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Comments (${post.commentsCount})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 5,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final mockUser = MockDataService.users[index % MockDataService.users.length];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundImage: mockUser.avatarUrl != null
                          ? NetworkImage(mockUser.avatarUrl!)
                          : null,
                    ),
                    title: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: '${mockUser.username} ',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          TextSpan(
                            text: 'Amazing work! Love the colors and composition. Keep it up!',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${index + 1}h ago',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.favorite_border, size: 16),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                top: 8,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
