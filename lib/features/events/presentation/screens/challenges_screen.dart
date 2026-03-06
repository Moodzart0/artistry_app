import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/events_repository.dart';
import '../../domain/challenge_model.dart';

/// Screen for browsing drawing challenges.
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  final EventsRepository _repository = EventsRepository();
  late TabController _tabController;
  List<ChallengeModel> _challenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChallenges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);
    final challenges = await _repository.getChallenges();
    if (mounted) {
      setState(() {
        _challenges = challenges;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChallengeList(_challenges
                        .where((c) =>
                            c.status == ChallengeStatus.active ||
                            c.status == ChallengeStatus.voting)
                        .toList()),
                    _buildChallengeList(_challenges
                        .where(
                            (c) => c.status == ChallengeStatus.upcoming)
                        .toList()),
                    _buildChallengeList(_challenges
                        .where((c) => c.status == ChallengeStatus.ended)
                        .toList()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildChallengeList(List<ChallengeModel> challenges) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No challenges here yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          return _ChallengeCard(
            challenge: challenges[index],
            onTap: () => _openChallenge(context, challenges[index]),
          );
        },
      ),
    );
  }

  void _openChallenge(BuildContext context, ChallengeModel challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(challenge: challenge),
      ),
    );
  }
}

/// Card widget for displaying a challenge.
class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.onTap,
  });

  final ChallengeModel challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradientColors(challenge.status),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _StatusBadge(status: challenge.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.theme,
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.description,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _iconInfo(Icons.people_outline,
                          '${challenge.entriesCount} entries'),
                      const SizedBox(width: 16),
                      if (challenge.timeRemaining != null)
                        _iconInfo(Icons.timer_outlined,
                            _formatDuration(challenge.timeRemaining!)),
                      if (challenge.prizeDescription != null) ...[
                        const SizedBox(width: 16),
                        _iconInfo(Icons.emoji_events_outlined, 'Prize'),
                      ],
                    ],
                  ),
                  if (challenge.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: challenge.tags
                          .take(4)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('#$tag',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary)),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  List<Color> _gradientColors(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return [AppColors.primary, const Color(0xFF7C4DFF)];
      case ChallengeStatus.voting:
        return [const Color(0xFFFF9800), const Color(0xFFFF5722)];
      case ChallengeStatus.upcoming:
        return [const Color(0xFF26C6DA), const Color(0xFF00ACC1)];
      case ChallengeStatus.ended:
        return [Colors.grey.shade600, Colors.grey.shade500];
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays}d left';
    if (duration.inHours > 0) return '${duration.inHours}h left';
    return '${duration.inMinutes}m left';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ChallengeStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  String get _label {
    switch (status) {
      case ChallengeStatus.active:
        return 'ACTIVE';
      case ChallengeStatus.voting:
        return 'VOTING';
      case ChallengeStatus.upcoming:
        return 'SOON';
      case ChallengeStatus.ended:
        return 'ENDED';
    }
  }
}

/// Detail screen for a specific challenge.
class ChallengeDetailScreen extends StatefulWidget {
  const ChallengeDetailScreen({super.key, required this.challenge});

  final ChallengeModel challenge;

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final EventsRepository _repository = EventsRepository();
  List<ChallengeEntryModel> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries =
        await _repository.getChallengeEntries(widget.challenge.id);
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;

    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, const Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.theme,
                      style: TextStyle(
                          color: Colors.white.withAlpha(200), fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(challenge.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(challenge.description,
                      style: TextStyle(
                          color: Colors.white.withAlpha(230), fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statChip(Icons.people, '${challenge.entriesCount} entries'),
                      const SizedBox(width: 12),
                      if (challenge.timeRemaining != null)
                        _statChip(Icons.timer, _formatTimeRemaining(challenge.timeRemaining!)),
                    ],
                  ),
                ],
              ),
            ),

            // Rules
            if (challenge.rules.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rules',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(challenge.rules,
                        style: const TextStyle(fontSize: 13, height: 1.5)),
                  ],
                ),
              ),

            // Prize
            if (challenge.prizeDescription != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events,
                          color: Color(0xFFFF8F00), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prize',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            Text(challenge.prizeDescription!,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Divider(height: 32),

            // Entries
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Entries (${_entries.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )),

            if (!_isLoading && _entries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No entries yet. Be the first!',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),

            if (!_isLoading)
              ..._entries.map((entry) => _EntryTile(entry: entry)),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: challenge.isActive
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Submit your entry from the workspace!')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Submit Entry'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _statChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays} days left';
    if (duration.inHours > 0) return '${duration.inHours} hours left';
    return '${duration.inMinutes} min left';
  }
}

/// Entry tile widget.
class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final ChallengeEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withAlpha(30),
        child: entry.rank != null
            ? Text('#${entry.rank}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 13))
            : Text(entry.username[0].toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary)),
      ),
      title: Text(entry.title.isNotEmpty ? entry.title : 'Untitled',
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('by ${entry.username}',
          style: const TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, size: 16, color: AppColors.error),
          const SizedBox(width: 4),
          Text('${entry.votesCount}',
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
