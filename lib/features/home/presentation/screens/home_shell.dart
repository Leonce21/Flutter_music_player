// lib/features/home/presentation/screens/home_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/bottom_nav.dart';
import '../../../../core/widgets/mini_player.dart';
import '../../../favorites/favorites_screen.dart';
import '../../../playlists/playlists_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'home_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: child, bottomNavigationBar: const _Dock());
}

class _Dock extends StatelessWidget {
  const _Dock();

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final index = loc.startsWith('/favorites')
        ? 1
        : loc.startsWith('/playlists')
            ? 2
            : loc.startsWith('/settings')
                ? 3
                : 0;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          MumeBottomNav(index: index),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) => switch (index) {
        1 => const FavoritesScreen(),
        2 => const PlaylistsScreen(),
        3 => const SettingsScreen(),
        _ => const HomeScreen(),
      };
}