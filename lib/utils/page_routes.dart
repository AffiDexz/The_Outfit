// lib/utils/page_routes.dart
import 'package:flutter/material.dart';

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (ctx, anim, secAnim) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (ctx, anim, secAnim, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        );
}

/// Fade + slight scale transition
class FadeScaleRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings? routeSettings;

  FadeScaleRoute({required this.page, this.routeSettings})
      : super(
          settings: routeSettings,
          pageBuilder: (ctx, anim, secAnim) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (ctx, anim, secAnim, child) {
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
        );
}

/// Slide-right transition 
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings? routeSettings;

  SlideRightRoute({required this.page, this.routeSettings})
      : super(
          settings: routeSettings,
          pageBuilder: (ctx, anim, secAnim) => page,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (ctx, anim, secAnim, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        );
}
