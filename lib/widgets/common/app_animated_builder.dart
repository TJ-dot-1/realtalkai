import 'package:flutter/material.dart';

/// Reusable AnimatedBuilder widget used across the app
/// Rebuilds its child whenever the animation value changes
class AppAnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AppAnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
