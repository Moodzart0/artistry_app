import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/events_repository.dart';
import '../../domain/live_event_model.dart';

/// Screen for browsing live and upcoming drawing sessions.
class LiveEventsScreen extends StatefulWidget {
  const LiveEventsScreen({super.key});

  @override
  State<LiveEventsScreen> createState() => _LiveEventsScreenState();
}

class _LiveEventsScreenState extends State<LiveEventsScreen> {
  final EventsRepository _repository = EventsRepository();
  List<LiveEventModel> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await _repository.getLiveEvents();
    if (mounted) {
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No live sessions right now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Be the first to go live!',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateLiveDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Start Live Session'),
            ),
          ],
        ),
      );
    }

    final liveNow = _events.where((e) => e.isLive).toList();
    final upcoming = _events.where((e) => e.isScheduled).toList();

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Go Live button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showCreateLiveDialog(context),
              icon: const Icon(Icons.videocam, size: 20),
              label: const Text('Start Live Session'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Live Now section
          if (liveNow.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('LIVE NOW',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 12),
            ...liveNow.map((event) => _LiveEventCard(
                  event: event,
                  onTap: () => _openLiveSession(context, event),
                )),
            const SizedBox(height: 24),
          ],

          // Upcoming section
          if (upcoming.isNotEmpty) ...[
            const Text('UPCOMING',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                    color: Colors.grey)),
            const SizedBox(height: 12),
            ...upcoming.map((event) => _LiveEventCard(
                  event: event,
                  onTap: () => _openLiveSession(context, event),
                )),
          ],
        ],
      ),
    );
  }

  void _openLiveSession(BuildContext context, LiveEventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LiveSessionViewScreen(event: event),
      ),
    );
  }

  void _showCreateLiveDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Live Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Session Title',
                hintText: 'What are you drawing today?',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Tell viewers what to expect',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live session started!')),
              );
            },
            child: const Text('Go Live'),
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying a live or upcoming event.
class _LiveEventCard extends StatelessWidget {
  const _LiveEventCard({
    required this.event,
    required this.onTap,
  });

  final LiveEventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Host avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withAlpha(30),
                child: Text(
                  event.hostUsername[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.hostUsername,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                    if (event.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 6,
                          children: event.tags
                              .take(3)
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(tag,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.primary)),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),

              // Status badge
              Column(
                children: [
                  if (event.isLive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('LIVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${event.viewerCount}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                  if (event.isScheduled && event.scheduledAt != null) ...[
                    const Icon(Icons.schedule, size: 20, color: Colors.grey),
                    const SizedBox(height: 4),
                    Text(
                      _formatScheduledTime(event.scheduledAt!),
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatScheduledTime(DateTime time) {
    final diff = time.difference(DateTime.now());
    if (diff.inHours > 0) return 'In ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'In ${diff.inMinutes}m';
    return 'Soon';
  }
}

/// Screen for viewing/participating in a live session.
class _LiveSessionViewScreen extends StatelessWidget {
  const _LiveSessionViewScreen({required this.event});

  final LiveEventModel event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          if (event.isLive)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('LIVE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Canvas area (placeholder for live stream)
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      event.isLive ? Icons.brush : Icons.schedule,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.isLive
                          ? 'Live canvas stream'
                          : 'Session starts soon',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Host: ${event.hostUsername}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Info bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withAlpha(30),
                      child: Text(event.hostUsername[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.hostUsername,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text(event.description,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (event.isLive)
                      Row(
                        children: [
                          const Icon(Icons.visibility,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${event.viewerCount}',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                  ],
                ),
                if (event.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: event.tags
                        .map((tag) => Chip(
                              label: Text(tag,
                                  style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
