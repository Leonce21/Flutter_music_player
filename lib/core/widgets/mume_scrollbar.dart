// lib/core/widgets/mume_scrollbar.dart
import 'package:flutter/material.dart';

/// A professional, draggable scrollbar styled via the global AppTheme.
class MumeScrollbar extends StatelessWidget {
  const MumeScrollbar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      interactive: true, // ✅ Allows dragging the scrollbar directly
      child: child,
    );
  }
}