import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../common/app_animated_builder.dart';

/// Pulsing microphone button for voice input
class VoiceInputButton extends StatefulWidget {
  final bool isRecording;
  final bool isDisabled;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final String statusText;

  const VoiceInputButton({
    super.key,
    required this.isRecording,
    required this.isDisabled,
    required this.onTapDown,
    required this.onTapUp,
    required this.statusText,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rippleAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
      _rippleController.repeat();
    } else if (!widget.isRecording && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
      _rippleController.stop();
      _rippleController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.statusText,
            key: ValueKey(widget.statusText),
            style: TextStyle(
              color: widget.isRecording ? AppTheme.accent : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Button
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect
              if (widget.isRecording)
                AppAnimatedBuilder(
                  listenable: _rippleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _rippleAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent.withOpacity(
                            0.3 * (1 - (_rippleAnimation.value - 1) / 0.6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              // Main button
              AppAnimatedBuilder(
                listenable: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isRecording ? _pulseAnimation.value : 1.0,
                    child: GestureDetector(
                      onTapDown: widget.isDisabled ? null : (_) => widget.onTapDown(),
                      onTapUp: widget.isDisabled ? null : (_) => widget.onTapUp(),
                      onTapCancel: widget.isDisabled ? null : () => widget.onTapUp(),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: widget.isRecording
                              ? AppTheme.accentGradient
                              : widget.isDisabled
                                  ? const LinearGradient(
                                      colors: [
                                        AppTheme.surfaceLight,
                                        AppTheme.surfaceLight,
                                      ],
                                    )
                                  : AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: (widget.isRecording
                                      ? AppTheme.accent
                                      : AppTheme.primary)
                                  .withOpacity(widget.isDisabled ? 0 : 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
