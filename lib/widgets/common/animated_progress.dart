import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../config/theme.dart';

/// Animated circular progress indicator with score display
class AnimatedProgress extends StatelessWidget {
  final double percent;
  final String label;
  final Color? progressColor;
  final double radius;
  final double lineWidth;

  const AnimatedProgress({
    super.key,
    required this.percent,
    required this.label,
    this.progressColor,
    this.radius = 60,
    this.lineWidth = 10,
  });

  Color get _color {
    if (progressColor != null) return progressColor!;
    if (percent >= 0.8) return AppTheme.success;
    if (percent >= 0.6) return AppTheme.secondary;
    if (percent >= 0.4) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      percent: percent.clamp(0.0, 1.0),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(percent * 100).toInt()}',
            style: TextStyle(
              fontSize: radius * 0.4,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: radius * 0.16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      progressColor: _color,
      backgroundColor: AppTheme.surfaceLight,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1200,
      curve: Curves.easeOutCubic,
    );
  }
}
