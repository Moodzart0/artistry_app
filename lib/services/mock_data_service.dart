import '../features/auth/domain/user_profile.dart';
import '../features/feed/domain/post_model.dart';
import '../features/messaging/domain/conversation_model.dart';
import '../features/messaging/domain/message_model.dart';

/// Provides mock data for UI development before Supabase integration.
class MockDataService {
  MockDataService._();

  // ── Mock Users ───────────────────────────────────────────────

  static const List<UserProfile> users = [
    UserProfile(
      id: 'user-001',
      username: 'luna_art',
      displayName: 'Luna Artista',
      bio:
          'Digital illustrator & concept artist. Love fantasy worlds and character design.',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      coverImageUrl: 'https://picsum.photos/seed/cover1/800/300',
      isVerified: true,
      isArtistPro: true,
      followersCount: 12400,
      followingCount: 340,
      postsCount: 287,
    ),
    UserProfile(
      id: 'user-002',
      username: 'pixel_master',
      displayName: 'Marcus Chen',
      bio: 'Pixel art enthusiast. Retro game aesthetics.',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      isVerified: false,
      followersCount: 5600,
      followingCount: 210,
      postsCount: 143,
    ),
    UserProfile(
      id: 'user-003',
      username: 'watercolor_dreams',
      displayName: 'Sophia Rivers',
      bio:
          'Traditional meets digital. Watercolor-inspired digital paintings.',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      isVerified: true,
      followersCount: 23100,
      followingCount: 89,
      postsCount: 412,
    ),
    UserProfile(
      id: 'user-004',
      username: 'sketch_daily',
      displayName: 'Alex Noir',
      bio: 'One sketch a day keeps the creative block away.',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
      followersCount: 890,
      followingCount: 456,
      postsCount: 365,
    ),
    UserProfile(
      id: 'user-005',
      username: 'neon_brush',
      displayName: 'Kai Tanaka',
      bio: 'Cyberpunk & sci-fi art. Commissions open.',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      isVerified: true,
      isArtistPro: true,
      followersCount: 45200,
      followingCount: 120,
      postsCount: 198,
    ),
    UserProfile(
      id: 'user-006',
      username: 'flora_ink',
      displayName: 'Emma Bloom',
      bio: 'Botanical illustration | Nature-inspired art',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      followersCount: 7800,
      followingCount: 300,
      postsCount: 220,
    ),
    UserProfile(
      id: 'user-007',
      username: 'comic_panel',
      displayName: 'Jake Morrison',
      bio: 'Comic artist. Working on my graphic novel.',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      followersCount: 3400,
      followingCount: 178,
      postsCount: 95,
    ),
    UserProfile(
      id: 'user-008',
      username: 'abstract_soul',
      displayName: 'Priya Sharma',
      bio: 'Abstract expressionism in the digital realm.',
      avatarUrl: 'https://i.pravatar.cc/150?img=16',
      isVerified: true,
      followersCount: 18900,
      followingCount: 67,
      postsCount: 310,
    ),
  ];

  // ── Mock Posts ────────────────────────────────────────────────

  static final List<PostModel> posts = [
    PostModel(
      id: 'post-001',
      userId: 'user-001',
      user: users[0],
      caption:
          'My latest fantasy character commission! Spent 12 hours on this piece. What do you think? #fantasy #characterdesign',
      imageUrl: 'https://picsum.photos/seed/art1/600/800',
      thumbnailUrl: 'https://picsum.photos/seed/art1/300/400',
      hasTimelapse: true,
      tags: ['fantasy', 'characterdesign', 'commission'],
      likesCount: 342,
      commentsCount: 28,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PostModel(
      id: 'post-002',
      userId: 'user-003',
      user: users[2],
      caption:
          'Morning light study. Trying to capture that golden hour glow digitally.',
      imageUrl: 'https://picsum.photos/seed/art2/800/600',
      thumbnailUrl: 'https://picsum.photos/seed/art2/400/300',
      hasTimelapse: true,
      tags: ['landscape', 'lightstudy', 'watercolor'],
      likesCount: 891,
      commentsCount: 56,
      isLiked: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    PostModel(
      id: 'post-003',
      userId: 'user-005',
      user: users[4],
      caption:
          'Neon City 2087. Part of my cyberpunk series. Full timelapse available!',
      imageUrl: 'https://picsum.photos/seed/art3/600/600',
      thumbnailUrl: 'https://picsum.photos/seed/art3/300/300',
      hasTimelapse: true,
      tags: ['cyberpunk', 'scifi', 'neonart'],
      likesCount: 2103,
      commentsCount: 134,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    PostModel(
      id: 'post-004',
      userId: 'user-002',
      user: users[1],
      caption: 'Pixel art dungeon tileset. Free to use for game jams!',
      imageUrl: 'https://picsum.photos/seed/art4/500/500',
      thumbnailUrl: 'https://picsum.photos/seed/art4/250/250',
      hasTimelapse: false,
      tags: ['pixelart', 'gamedev', 'tileset'],
      likesCount: 456,
      commentsCount: 42,
      isLiked: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PostModel(
      id: 'post-005',
      userId: 'user-004',
      user: users[3],
      caption: 'Day 247 of daily sketches. Coffee shop people watching.',
      imageUrl: 'https://picsum.photos/seed/art5/600/800',
      thumbnailUrl: 'https://picsum.photos/seed/art5/300/400',
      hasTimelapse: false,
      tags: ['sketch', 'dailysketch', 'people'],
      likesCount: 123,
      commentsCount: 15,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    PostModel(
      id: 'post-006',
      userId: 'user-006',
      user: users[5],
      caption: 'Orchid study with layered brushwork. New brush pack coming soon!',
      imageUrl: 'https://picsum.photos/seed/art6/700/900',
      thumbnailUrl: 'https://picsum.photos/seed/art6/350/450',
      hasTimelapse: true,
      tags: ['botanical', 'flowers', 'brushwork'],
      likesCount: 678,
      commentsCount: 47,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PostModel(
      id: 'post-007',
      userId: 'user-008',
      user: users[7],
      caption:
          'Emotions in color. Abstract piece exploring the feeling of nostalgia.',
      imageUrl: 'https://picsum.photos/seed/art7/800/800',
      thumbnailUrl: 'https://picsum.photos/seed/art7/400/400',
      hasTimelapse: true,
      tags: ['abstract', 'expressionism', 'emotions'],
      likesCount: 1560,
      commentsCount: 89,
      isLiked: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
    ),
    PostModel(
      id: 'post-008',
      userId: 'user-007',
      user: users[6],
      caption: 'Page 42 of my graphic novel. The confrontation scene.',
      imageUrl: 'https://picsum.photos/seed/art8/600/900',
      thumbnailUrl: 'https://picsum.photos/seed/art8/300/450',
      hasTimelapse: false,
      tags: ['comic', 'graphicnovel', 'sequential'],
      likesCount: 234,
      commentsCount: 31,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // ── Mock Conversations ───────────────────────────────────────

  static final List<ConversationModel> conversations = [
    ConversationModel(
      id: 'conv-001',
      participant: users[2],
      lastMessage: 'Thanks for the feedback on my latest piece!',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 2,
    ),
    ConversationModel(
      id: 'conv-002',
      participant: users[4],
      lastMessage: 'Are you joining the collab session tonight?',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
    ),
    ConversationModel(
      id: 'conv-003',
      participant: users[0],
      lastMessage: 'I love your new character design!',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 1,
    ),
    ConversationModel(
      id: 'conv-004',
      participant: users[1],
      lastMessage: 'Check out this pixel art tutorial I found',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
    ),
    ConversationModel(
      id: 'conv-005',
      participant: users[5],
      lastMessage: 'Your botanical series is incredible!',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
    ),
  ];

  // ── Mock Messages for a conversation ─────────────────────────

  static List<MessageModel> getMessages(String conversationId) {
    final now = DateTime.now();
    return [
      MessageModel(
        id: 'msg-001',
        conversationId: conversationId,
        senderId: 'user-003',
        content: 'Hey! I just saw your latest piece on the feed.',
        isMe: false,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
      ),
      MessageModel(
        id: 'msg-002',
        conversationId: conversationId,
        senderId: 'current-user',
        content: 'Thank you! I spent a lot of time on the lighting.',
        isMe: true,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 25)),
      ),
      MessageModel(
        id: 'msg-003',
        conversationId: conversationId,
        senderId: 'user-003',
        content:
            'The lighting really makes the whole piece come alive. What brushes did you use?',
        isMe: false,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 20)),
      ),
      MessageModel(
        id: 'msg-004',
        conversationId: conversationId,
        senderId: 'current-user',
        content:
            'I used a combination of soft airbrush for the ambient light and a textured brush for the highlights.',
        isMe: true,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      MessageModel(
        id: 'msg-005',
        conversationId: conversationId,
        senderId: 'user-003',
        content:
            'That sounds great! Would you consider doing a tutorial on your lighting technique?',
        isMe: false,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
      ),
      MessageModel(
        id: 'msg-006',
        conversationId: conversationId,
        senderId: 'current-user',
        content:
            'Actually, I recorded a timelapse of the whole process! I\'ll post it soon.',
        isMe: true,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
      ),
      MessageModel(
        id: 'msg-007',
        conversationId: conversationId,
        senderId: 'user-003',
        content: 'Thanks for the feedback on my latest piece!',
        isMe: false,
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
    ];
  }

  // ── Explore categories ───────────────────────────────────────

  static const List<String> exploreCategories = [
    'All',
    'Trending',
    'Digital Painting',
    'Pixel Art',
    'Character Design',
    'Landscape',
    'Abstract',
    'Comic Art',
    'Concept Art',
    'Fan Art',
    'Botanical',
    'Animation',
  ];
}
