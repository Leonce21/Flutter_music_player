// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/library/presentation/screens/detail_screen.dart';
import '../../features/library/presentation/screens/see_all_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screens.dart';
import '../../features/player/presentation/screens/now_playing_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../services/prefs.dart';
import 'page_transitions.dart';

final _root = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _root,
  initialLocation: '/splash',
  redirect: (context, state) {
    final loc = state.matchedLocation;
    if (!Prefs.onboarded &&
        !loc.startsWith('/onboarding') &&
        loc != '/splash') {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (c, s) => const MaterialPage(child: SplashScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (c, s) => const MaterialPage(child: OnboardingScreen()),
    ),
    GoRoute(
      path: '/now',
      pageBuilder: (c, s) => SlideUpPage(child: const NowPlayingScreen()),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (c, s) => FadePage(child: const SearchScreen()),
    ),
    GoRoute(
      path: '/artist/:id',
      pageBuilder: (c, s) => ScaleFadePage(
        child: DetailScreen(
          kind: DetailKind.artist,
          id: int.parse(s.pathParameters['id']!),
        ),
      ),
    ),
    GoRoute(
      path: '/album/:id',
      pageBuilder: (c, s) => ScaleFadePage(
        child: DetailScreen(
          kind: DetailKind.album,
          id: int.parse(s.pathParameters['id']!),
        ),
      ),
    ),
    GoRoute(
      path: '/folder/:id',
      pageBuilder: (c, s) => ScaleFadePage(
        child: DetailScreen(
          kind: DetailKind.folder,
          id: int.parse(s.pathParameters['id']!),
        ),
      ),
    ),
    GoRoute(
      path: '/playlist/:name',
      pageBuilder: (c, s) => ScaleFadePage(
        child: DetailScreen(
          kind: DetailKind.playlist,
          name: Uri.decodeComponent(s.pathParameters['name']!),
        ),
      ),
    ),
    GoRoute(
      path: '/see-all/:type',
      pageBuilder: (c, s) => SlideRightPage(
        child: SeeAllScreen(type: s.pathParameters['type']!),
      ),
    ),
    ShellRoute(
      builder: (c, s, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: HomeTab(index: 0)),
        ),
        GoRoute(
          path: '/favorites',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: HomeTab(index: 1)),
        ),
        GoRoute(
          path: '/playlists',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: HomeTab(index: 2)),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: HomeTab(index: 3)),
        ),
      ],
    ),
  ],
);