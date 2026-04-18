import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/feedback_result.dart';

/// Score gauge widget for feedback display
class ScoreGauge extends StatelessWidget {
  final int score;
  final String label;
  final Color? color;

  const ScoreGauge({
    super.key,
    required this.score,
    required this.label,
    this.color,
  });

  Color get _color {
    if (color != null) return color!;
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return AppTheme.secondary;
    if (score >= 40) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Score circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(_color),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '${(value * 100).toInt()}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Correction card showing original vs corrected text
class CorrectionCard extends StatelessWidget {
  final GrammarCorrection correction;
  final int index;

  const CorrectionCard({
    super.key,
    required this.correction,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original (with strikethrough)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.close_rounded, color: AppTheme.error, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correction.original,
                  style: const TextStyle(
                    color: AppTheme.error,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppTheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Corrected
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_rounded, color: AppTheme.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correction.corrected,
                  style: const TextStyle(
                    color: AppTheme.success,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Explanation
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: AppTheme.warning, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    correction.explanation,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Suggestion card showing better response alternatives
class SuggestionCard extends StatelessWidget {
  final ImprovedResponse suggestion;

  const SuggestionCard({
    super.key,
    required this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What you said
          Text(
            'What you said:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"${suggestion.userSaid}"',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          // Better way
          Text(
            'A better way:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondary.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"${suggestion.betterWay}"',
            style: const TextStyle(
              color: AppTheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Why
          Text(
            suggestion.why,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
