import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'live_events_screen.dart';
import 'challenges_screen.dart';
import 'collab_canvas_screen.dart';

/// Hub screen for the Events & Interactive Zone.
/// Contains tabs for Live Events, Challenges, and Collab Canvas.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text(
          'Events',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.live_tv, size: 20),
              text: 'Live',
            ),
            Tab(
              icon: Icon(Icons.emoji_events, size: 20),
              text: 'Challenges',
            ),
            Tab(
              icon: Icon(Icons.people, size: 20),
              text: 'Collab',
            ),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LiveEventsScreen(),
          ChallengesScreen(),
          CollabCanvasScreen(),
        ],
      ),
    );
  }
}
