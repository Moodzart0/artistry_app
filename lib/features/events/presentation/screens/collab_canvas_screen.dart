import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/events_repository.dart';
import '../../domain/collab_session_model.dart';
import '../../../workspace/domain/canvas_stroke.dart';
import '../../../workspace/domain/drawing_tool.dart';
import '../../../workspace/domain/stroke_point.dart';
import '../../../workspace/domain/canvas_layer.dart';
import '../../../workspace/presentation/engine/canvas_painter.dart';

/// Screen for browsing and joining collaborative drawing sessions.
class CollabCanvasScreen extends StatefulWidget {
  const CollabCanvasScreen({super.key});

  @override
  State<CollabCanvasScreen> createState() => _CollabCanvasScreenState();
}

class _CollabCanvasScreenState extends State<CollabCanvasScreen> {
  final EventsRepository _repository = EventsRepository();
  List<CollabSessionModel> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await _repository.getCollabSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Create session button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showCreateSessionDialog(context),
              icon: const Icon(Icons.group_add, size: 20),
              label: const Text('Create Collab Session'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Active sessions header
          const Text('ACTIVE SESSIONS',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                  color: Colors.grey)),
          const SizedBox(height: 12),

          if (_sessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.people_outline,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text('No active sessions',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Create one and invite friends!',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),

          ..._sessions.map((session) => _CollabSessionCard(
                session: session,
                onTap: () => _joinSession(context, session),
              )),
        ],
      ),
    );
  }

  void _joinSession(BuildContext context, CollabSessionModel session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollabDrawingScreen(session: session),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int maxParticipants = 8;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Collab Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Session Title',
                  hintText: 'e.g., Community Mural',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Max participants: ',
                      style: TextStyle(fontSize: 13)),
                  Expanded(
                    child: Slider(
                      value: maxParticipants.toDouble(),
                      min: 2,
                      max: 16,
                      divisions: 14,
                      label: '$maxParticipants',
                      onChanged: (v) {
                        setDialogState(() => maxParticipants = v.toInt());
                      },
                    ),
                  ),
                  Text('$maxParticipants',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
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
                  const SnackBar(
                      content: Text('Collab session created!')),
                );
                _loadSessions();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying a collab session.
class _CollabSessionCard extends StatelessWidget {
  const _CollabSessionCard({
    required this.session,
    required this.onTap,
  });

  final CollabSessionModel session;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: session.isFull
                          ? Colors.orange.withAlpha(20)
                          : AppColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${session.participantCount}/${session.maxParticipants}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: session.isFull
                            ? Colors.orange
                            : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              if (session.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(session.description,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 10),

              // Participant avatars
              Row(
                children: [
                  ...session.participants.take(5).map((p) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(p.cursorColor),
                          child: Text(
                            p.username[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                  if (session.participants.length > 5)
                    Text(
                      '+${session.participants.length - 5}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  const Spacer(),
                  Text(
                    'Host: ${session.hostUsername}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The collaborative drawing screen with real-time canvas.
class CollabDrawingScreen extends StatefulWidget {
  const CollabDrawingScreen({super.key, required this.session});

  final CollabSessionModel session;

  @override
  State<CollabDrawingScreen> createState() => _CollabDrawingScreenState();
}

class _CollabDrawingScreenState extends State<CollabDrawingScreen> {
  final List<CanvasStroke> _strokes = [];
  final List<StrokePoint> _currentPoints = [];
  DrawingTool _currentTool = const DrawingTool();
  Timer? _cursorBroadcastTimer;
  final List<_RemoteCursor> _remoteCursors = [];

  // Simulated remote participant strokes
  final List<CanvasStroke> _remoteStrokes = [];

  @override
  void initState() {
    super.initState();
    _initRealtimeConnection();
  }

  @override
  void dispose() {
    _cursorBroadcastTimer?.cancel();
    super.dispose();
  }

  /// Initialize Supabase Realtime channel for this session.
  /// In production, this subscribes to the session's channel
  /// and broadcasts/receives stroke events in real-time.
  void _initRealtimeConnection() {
    // Simulate remote cursors updating
    _cursorBroadcastTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remoteCursors.clear();
        for (final participant in widget.session.participants) {
          if (participant.userId != 'current-user') {
            _remoteCursors.add(_RemoteCursor(
              username: participant.username,
              color: Color(participant.cursorColor),
              x: 100.0 + (timer.tick * 20.0 % 400),
              y: 100.0 + (timer.tick * 15.0 % 300),
            ));
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
        actions: [
          // Participant count
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                const Icon(Icons.people, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${widget.session.participantCount}/${widget.session.maxParticipants}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          // Participants list
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Participants',
            onPressed: () => _showParticipants(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas
          Expanded(
            child: Stack(
              children: [
                // Drawing canvas
                GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Container(
                    color: Colors.white,
                    child: CustomPaint(
                      painter: CanvasPainter(
                        layers: [
                          CanvasLayer(
                            id: 'collab-layer',
                            name: 'Collab',
                            strokes: [..._remoteStrokes, ..._strokes],
                          ),
                        ],
                        currentStroke: _currentPoints.isNotEmpty
                            ? CanvasStroke(
                                id: 'current',
                                layerId: 'collab-layer',
                                points: _currentPoints,
                                tool: _currentTool,
                              )
                            : null,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),

                // Remote cursors
                ..._remoteCursors.map((cursor) => Positioned(
                      left: cursor.x,
                      top: cursor.y,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.near_me,
                              color: cursor.color, size: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cursor.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              cursor.username,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )),

                // Connection indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi, color: AppColors.success, size: 14),
                        SizedBox(width: 6),
                        Text('Connected',
                            style: TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Simple toolbar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toolButton(Icons.brush, 'Brush', ToolType.brush),
                _toolButton(Icons.edit, 'Pencil', ToolType.pencil),
                _toolButton(
                    Icons.auto_fix_high, 'Eraser', ToolType.eraser),
                _colorButton(Colors.black),
                _colorButton(AppColors.primary),
                _colorButton(AppColors.error),
                _colorButton(const Color(0xFF4CAF50)),
                _colorButton(const Color(0xFFFF9800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolButton(IconData icon, String tooltip, ToolType type) {
    final isSelected = _currentTool.type == type;
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      color: isSelected ? AppColors.primary : Colors.grey,
      onPressed: () {
        setState(() {
          _currentTool = _currentTool.copyWith(type: type);
        });
      },
    );
  }

  Widget _colorButton(Color color) {
    final isSelected = _currentTool.color == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTool = _currentTool.copyWith(color: color);
        });
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentPoints.clear();
      _currentPoints.add(StrokePoint(
        x: details.localPosition.dx,
        y: details.localPosition.dy,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPoints.add(StrokePoint(
        x: details.localPosition.dx,
        y: details.localPosition.dy,
      ));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPoints.isEmpty) return;

    final stroke = CanvasStroke(
      id: 'stroke-${_strokes.length}',
      layerId: 'collab-layer',
      points: List.from(_currentPoints),
      tool: _currentTool,
    );

    setState(() {
      _strokes.add(stroke);
      _currentPoints.clear();
    });

    // In production, broadcast this stroke via Supabase Realtime channel
    _broadcastStroke(stroke);
  }

  /// Broadcasts a stroke event to other participants via Supabase Realtime.
  void _broadcastStroke(CanvasStroke stroke) {
    // In production implementation:
    // final channel = Supabase.instance.client.channel('collab:${widget.session.id}');
    // channel.sendBroadcastMessage(
    //   event: 'stroke',
    //   payload: stroke.toStrokeData(),
    // );
    debugPrint(
        'Broadcasting stroke to collab session: ${widget.session.id}');
  }

  void _showParticipants(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participants (${widget.session.participantCount})',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...widget.session.participants.map((p) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(p.cursorColor),
                    child: Text(p.username[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(p.username),
                  subtitle: Text(
                      p.userId == widget.session.hostId
                          ? 'Host'
                          : 'Participant',
                      style: const TextStyle(fontSize: 12)),
                  trailing: p.isActive
                      ? const Icon(Icons.circle,
                          color: AppColors.success, size: 10)
                      : const Icon(Icons.circle,
                          color: Colors.grey, size: 10),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Represents a remote participant's cursor position.
class _RemoteCursor {
  const _RemoteCursor({
    required this.username,
    required this.color,
    required this.x,
    required this.y,
  });

  final String username;
  final Color color;
  final double x;
  final double y;
}
