import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/check_in/capture_screen.dart';
import 'presentation/check_in/confirmation_screen.dart';
import 'presentation/check_in/mood_screen.dart';
import 'presentation/history/event_detail_screen.dart';
import 'presentation/history/history_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/theme/app_theme.dart';

/// The app shell: theme + named routes. Each instance owns its router so
/// navigation state never leaks between test pumps.
class RootsApp extends StatefulWidget {
  const RootsApp({super.key});

  @override
  State<RootsApp> createState() => _RootsAppState();
}

class _RootsAppState extends State<RootsApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/check-in/capture',
        builder: (_, _) => const CaptureScreen(),
      ),
      GoRoute(path: '/check-in/mood', builder: (_, _) => const MoodScreen()),
      GoRoute(
        path: '/check-in/confirm',
        builder: (_, _) => const ConfirmationScreen(),
      ),
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
      GoRoute(
        path: '/history/:id',
        builder: (_, state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Plant Selfie',
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
