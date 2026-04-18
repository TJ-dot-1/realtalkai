import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/scenario.dart';
import '../common/app_animated_builder.dart';

/// Scenario selection card with gradient and icon
class ScenarioCard extends StatefulWidget {
  final Scenario scenario;
  final bool isSelected;
  final VoidCallback onTap;

  const ScenarioCard({
    super.key,
    required this.scenario,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ScenarioCard> createState() => _ScenarioCardState();
}

class _ScenarioCardState extends State<ScenarioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _gradientStart =>
      Color(int.parse(widget.scenario.gradientStart));
  Color get _gradientEnd =>
      Color(int.parse(widget.scenario.gradientEnd));

  String get _difficultyLabel {
    switch (widget.scenario.difficulty) {
      case 'Easy':
        return '🟢 Easy';
      case 'Medium':
        return '🟡 Medium';
      case 'Hard':
        return '🔴 Hard';
      default:
        return widget.scenario.difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AppAnimatedBuilder(
        listenable: _scaleAnimation,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppTheme.primary.withOpacity(0.1)
                    : AppTheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: widget.isSelected
                      ? AppTheme.primary.withOpacity(0.5)
                      : AppTheme.cardBorder.withOpacity(0.3),
                  width: widget.isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? AppTheme.primary.withOpacity(0.15)
                        : Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon with gradient background
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _gradientStart.withOpacity(0.2),
                          _gradientEnd.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        widget.scenario.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.scenario.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _difficultyLabel,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.scenario.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              size: 14,
                              color: _gradientStart,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.scenario.goal,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _gradientStart,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    widget.isSelected
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios_rounded,
                    color: widget.isSelected
                        ? AppTheme.primary
                        : AppTheme.textTertiary,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
