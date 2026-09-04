// lib/core/router/page_transitions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Slide from right transition (standard for push navigation)
class SlideRightPage extends CustomTransitionPage<void> {
  SlideRightPage({required super.child, super.key})
      : super(
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// Slide from bottom transition (for modal-like screens)
class SlideUpPage extends CustomTransitionPage<void> {
  SlideUpPage({required super.child, super.key})
      : super(
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// Fade transition (for subtle screen changes)
class FadePage extends CustomTransitionPage<void> {
  FadePage({required super.child, super.key})
      : super(
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Scale + Fade transition (for detail screens)
class ScaleFadePage extends CustomTransitionPage<void> {
  ScaleFadePage({required super.child, super.key})
      : super(
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            const begin = 0.95;
            const end = 1.0;
            const curve = Curves.easeOutCubic;

            final scaleTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
        );
}