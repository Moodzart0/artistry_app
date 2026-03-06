import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../domain/challenge_model.dart';
import '../domain/collab_session_model.dart';
import '../domain/live_event_model.dart';

/// Repository for events-related data (live sessions, challenges, collab).
/// Provides both Supabase integration and mock data for development.
class EventsRepository {
  EventsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ── Live Events ──────────────────────────────────────────────

  /// Fetches live and upcoming drawing sessions.
  Future<List<LiveEventModel>> getLiveEvents() async {
    try {
      final response = await _client
          .from(SupabaseConstants.collabSessionsTable)
          .select()
          .inFilter('status', ['live', 'scheduled'])
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((e) => LiveEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching live events: $e');
      return _mockLiveEvents();
    }
  }

  /// Creates a new live session.
  Future<LiveEventModel?> createLiveEvent({
    required String title,
    String description = '',
    DateTime? scheduledAt,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = {
        'host_id': userId,
        'title': title,
        'description': description,
        'status': scheduledAt != null ? 'scheduled' : 'live',
        if (scheduledAt != null)
          'scheduled_at': scheduledAt.toIso8601String(),
        if (scheduledAt == null)
          'started_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(SupabaseConstants.collabSessionsTable)
          .insert(data)
          .select()
          .single();

      return LiveEventModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating live event: $e');
      return null;
    }
  }

  // ── Challenges ───────────────────────────────────────────────

  /// Fetches challenges filtered by status.
  Future<List<ChallengeModel>> getChallenges({
    ChallengeStatus? status,
  }) async {
    try {
      var query = _client
          .from(SupabaseConstants.challengesTable)
          .select();

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((e) => ChallengeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching challenges: $e');
      return _mockChallenges();
    }
  }

  /// Fetches entries for a specific challenge.
  Future<List<ChallengeEntryModel>> getChallengeEntries(
      String challengeId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.challengeEntriesTable)
          .select()
          .eq('challenge_id', challengeId)
          .order('votes_count', ascending: false);

      return (response as List)
          .map((e) =>
              ChallengeEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching challenge entries: $e');
      return _mockChallengeEntries(challengeId);
    }
  }

  /// Submits an entry to a challenge.
  Future<ChallengeEntryModel?> submitChallengeEntry({
    required String challengeId,
    required String title,
    String description = '',
    String? imageUrl,
    String? postId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = {
        'challenge_id': challengeId,
        'user_id': userId,
        'title': title,
        'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        if (postId != null) 'post_id': postId,
      };

      final response = await _client
          .from(SupabaseConstants.challengeEntriesTable)
          .insert(data)
          .select()
          .single();

      return ChallengeEntryModel.fromJson(response);
    } catch (e) {
      debugPrint('Error submitting challenge entry: $e');
      return null;
    }
  }

  // ── Collab Sessions ──────────────────────────────────────────

  /// Fetches active collaborative drawing sessions.
  Future<List<CollabSessionModel>> getCollabSessions() async {
    try {
      final response = await _client
          .from(SupabaseConstants.collabSessionsTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((e) =>
              CollabSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching collab sessions: $e');
      return _mockCollabSessions();
    }
  }

  /// Creates a new collaborative drawing session.
  Future<CollabSessionModel?> createCollabSession({
    required String title,
    String description = '',
    int maxParticipants = 8,
    bool isPublic = true,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = {
        'host_id': userId,
        'title': title,
        'description': description,
        'max_participants': maxParticipants,
        'is_public': isPublic,
        'is_active': true,
      };

      final response = await _client
          .from(SupabaseConstants.collabSessionsTable)
          .insert(data)
          .select()
          .single();

      return CollabSessionModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating collab session: $e');
      return null;
    }
  }

  // ── Mock Data ────────────────────────────────────────────────

  List<LiveEventModel> _mockLiveEvents() {
    return [
      LiveEventModel(
        id: 'live-1',
        hostId: 'user-1',
        hostUsername: 'ArtistPro',
        hostAvatarUrl: '',
        title: 'Painting a Fantasy Landscape',
        description: 'Join me as I paint a mystical forest scene!',
        status: LiveEventStatus.live,
        viewerCount: 234,
        tags: ['landscape', 'fantasy', 'digital'],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      LiveEventModel(
        id: 'live-2',
        hostId: 'user-2',
        hostUsername: 'SketchQueen',
        hostAvatarUrl: '',
        title: 'Character Design Session',
        description: 'Designing original characters for my comic series.',
        status: LiveEventStatus.live,
        viewerCount: 156,
        tags: ['character', 'design', 'comic'],
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      LiveEventModel(
        id: 'live-3',
        hostId: 'user-3',
        hostUsername: 'ColorMaster',
        hostAvatarUrl: '',
        title: 'Advanced Color Theory Workshop',
        description: 'Learn about complementary colors and mood in art.',
        status: LiveEventStatus.scheduled,
        viewerCount: 0,
        scheduledAt: DateTime.now().add(const Duration(hours: 3)),
        tags: ['workshop', 'color', 'theory'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LiveEventModel(
        id: 'live-4',
        hostId: 'user-4',
        hostUsername: 'InkWizard',
        hostAvatarUrl: '',
        title: 'Speed Painting Challenge',
        description: '30-minute landscape speed paint — can I finish in time?',
        status: LiveEventStatus.scheduled,
        viewerCount: 0,
        scheduledAt: DateTime.now().add(const Duration(hours: 6)),
        tags: ['speed', 'challenge', 'landscape'],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  List<ChallengeModel> _mockChallenges() {
    return [
      ChallengeModel(
        id: 'challenge-1',
        title: 'Neon Nights',
        description:
            'Create artwork inspired by neon-lit cityscapes. Glow it up!',
        theme: 'Neon / Cyberpunk',
        status: ChallengeStatus.active,
        creatorUsername: 'ArtistryTeam',
        rules:
            '1. Original artwork only\n2. Must include neon elements\n3. Any style welcome',
        prizeDescription: 'Featured on the Explore page + PRO badge for 1 month',
        entriesCount: 47,
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        tags: ['neon', 'cyberpunk', 'city'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ChallengeModel(
        id: 'challenge-2',
        title: 'Mythical Creatures',
        description: 'Design your own mythical creature from any folklore.',
        theme: 'Mythology',
        status: ChallengeStatus.active,
        creatorUsername: 'DragonArtist',
        rules:
            '1. Must be inspired by real mythology\n2. Include creature name and origin',
        entriesCount: 23,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        tags: ['mythology', 'creatures', 'fantasy'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ChallengeModel(
        id: 'challenge-3',
        title: 'One Color Challenge',
        description: 'Create a masterpiece using only shades of one color.',
        theme: 'Monochrome',
        status: ChallengeStatus.upcoming,
        creatorUsername: 'ColorMaster',
        rules: '1. Single hue only\n2. Shading and tints allowed',
        entriesCount: 0,
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 9)),
        tags: ['monochrome', 'color', 'minimalist'],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      ChallengeModel(
        id: 'challenge-4',
        title: 'Pixel Perfect',
        description: 'Best pixel art wins! 64x64 canvas max.',
        theme: 'Pixel Art',
        status: ChallengeStatus.voting,
        creatorUsername: 'RetroPixel',
        entriesCount: 89,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 3)),
        votingEndDate: DateTime.now().add(const Duration(days: 1)),
        tags: ['pixel', 'retro', '8bit'],
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ];
  }

  List<ChallengeEntryModel> _mockChallengeEntries(String challengeId) {
    return [
      ChallengeEntryModel(
        id: 'entry-1',
        challengeId: challengeId,
        userId: 'user-1',
        username: 'ArtistPro',
        title: 'Neon Dragon',
        description: 'A dragon made of neon lights.',
        votesCount: 42,
        rank: 1,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ChallengeEntryModel(
        id: 'entry-2',
        challengeId: challengeId,
        userId: 'user-2',
        username: 'SketchQueen',
        title: 'City of Dreams',
        description: 'Futuristic cityscape at night.',
        votesCount: 38,
        rank: 2,
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ChallengeEntryModel(
        id: 'entry-3',
        challengeId: challengeId,
        userId: 'user-3',
        username: 'ColorMaster',
        title: 'Electric Garden',
        description: 'Flowers that glow in the dark.',
        votesCount: 31,
        rank: 3,
        submittedAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ];
  }

  List<CollabSessionModel> _mockCollabSessions() {
    return [
      CollabSessionModel(
        id: 'collab-1',
        hostId: 'user-1',
        hostUsername: 'ArtistPro',
        title: 'Community Mural',
        description: 'Let\'s create a beautiful mural together!',
        maxParticipants: 8,
        participants: [
          const CollabParticipant(
            userId: 'user-1',
            username: 'ArtistPro',
            cursorColor: 0xFF2196F3,
            isActive: true,
          ),
          const CollabParticipant(
            userId: 'user-2',
            username: 'SketchQueen',
            cursorColor: 0xFFE91E63,
            isActive: true,
          ),
          const CollabParticipant(
            userId: 'user-5',
            username: 'WatercolorWiz',
            cursorColor: 0xFF4CAF50,
            isActive: true,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      CollabSessionModel(
        id: 'collab-2',
        hostId: 'user-3',
        hostUsername: 'ColorMaster',
        title: 'Art Jam - Abstract Vibes',
        description: 'Free-form abstract art session. All welcome!',
        maxParticipants: 4,
        participants: [
          const CollabParticipant(
            userId: 'user-3',
            username: 'ColorMaster',
            cursorColor: 0xFFFF9800,
            isActive: true,
          ),
          const CollabParticipant(
            userId: 'user-6',
            username: 'AbstractAce',
            cursorColor: 0xFF9C27B0,
            isActive: true,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      CollabSessionModel(
        id: 'collab-3',
        hostId: 'user-4',
        hostUsername: 'InkWizard',
        title: 'Exquisite Corpse Game',
        description: 'Each person draws a section without seeing the others!',
        maxParticipants: 6,
        isPublic: true,
        participants: [
          const CollabParticipant(
            userId: 'user-4',
            username: 'InkWizard',
            cursorColor: 0xFF607D8B,
            isActive: true,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}
