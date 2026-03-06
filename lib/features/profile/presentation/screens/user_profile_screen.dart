import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../services/mock_data_service.dart';
import '../../../auth/domain/user_profile.dart';
import '../../../feed/domain/post_model.dart';

/// User profile screen showing header, stats, and post grid.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    this.userId,
    this.isCurrentUser = true,
  });

  final String? userId;
  final bool isCurrentUser;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProfile _user;
  late List<PostModel> _userPosts;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Use mock data — in production, fetch from Supabase
    _user = MockDataService.users[0];
    _userPosts = MockDataService.posts
        .where((p) => p.userId == _user.id)
        .toList();
    // If not enough posts for this user, show all as sample
    if (_userPosts.isEmpty) {
      _userPosts = MockDataService.posts;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _user.username,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (widget.isCurrentUser)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                _showSettingsSheet(context);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabBar: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.play_circle_outline)),
                    Tab(icon: Icon(Icons.bookmark_border)),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostGrid(),
            _buildTimelapseGrid(),
            _buildSavedGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar and stats row ────────────────────────
          Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _user.avatarUrl != null
                      ? CachedNetworkImageProvider(_user.avatarUrl!)
                      : null,
                  child: _user.avatarUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              const SizedBox(width: 24),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                        _user.postsCount.compact, 'Posts'),
                    _buildStatColumn(
                        _user.followersCount.compact, 'Followers'),
                    _buildStatColumn(
                        _user.followingCount.compact, 'Following'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Name and badges ─────────────────────────────
          Row(
            children: [
              Text(
                _user.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (_user.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 18, color: AppColors.primary),
              ],
              if (_user.isArtistPro) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // ── Bio ─────────────────────────────────────────
          if (_user.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _user.bio,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

          // ── Action buttons ──────────────────────────────
          if (widget.isCurrentUser)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to edit profile
                },
                child: const Text('Edit Profile'),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _isFollowing
                      ? OutlinedButton(
                          onPressed: () =>
                              setState(() => _isFollowing = false),
                          child: const Text('Following'),
                        )
                      : ElevatedButton(
                          onPressed: () =>
                              setState(() => _isFollowing = true),
                          child: const Text('Follow'),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to DM
                    },
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return GestureDetector(
          onTap: () {
            // TODO: Navigate to post detail
          },
          child: CachedNetworkImage(
            imageUrl: post.thumbnailUrl ?? post.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: AppColors.surfaceVariant),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.broken_image),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelapseGrid() {
    final timelapsePosts =
        _userPosts.where((p) => p.hasTimelapse).toList();
    if (timelapsePosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline,
                size: 48,
                color: AppColors.onSurfaceVariant.withAlpha(128)),
            const SizedBox(height: 12),
            Text(
              'No timelapses yet',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: timelapsePosts.length,
      itemBuilder: (context, index) {
        final post = timelapsePosts[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: post.thumbnailUrl ?? post.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.surfaceVariant),
            ),
            const Center(
              child: Icon(Icons.play_circle_fill,
                  color: Colors.white, size: 36),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavedGrid() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border,
              size: 48, color: AppColors.onSurfaceVariant.withAlpha(128)),
          const SizedBox(height: 12),
          Text(
            'No saved posts yet',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sign Out',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Sign out via auth provider
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Delegate for pinning the TabBar in the NestedScrollView.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.tabBar});

  final TabBar tabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
