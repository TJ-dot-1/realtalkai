import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/scenario_provider.dart';
import '../../models/feedback_result.dart';
import '../../widgets/feedback/feedback_widgets.dart';
import '../../widgets/common/gradient_button.dart';

/// Feedback screen — post-session analysis with scores and suggestions
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedback = ref.watch(feedbackProvider);

    // Start animation when feedback is ready
    if (feedback.status == FeedbackStatus.done && !_controller.isAnimating) {
      _controller.forward();

      // Update progress
      final scenario = ref.read(selectedScenarioProvider);
      if (scenario != null && feedback.result != null) {
        ref.read(progressProvider.notifier).recordSession(
              scenarioId: scenario.id,
              fluencyScore: feedback.result!.fluencyScore,
            );
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: feedback.status == FeedbackStatus.generating
              ? _buildLoading()
              : feedback.status == FeedbackStatus.error
                  ? _buildError(feedback.error ?? 'Unknown error')
                  : feedback.result != null
                      ? _buildFeedback(feedback.result!)
                      : _buildLoading(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 6.28,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🧠', style: TextStyle(fontSize: 40)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Analyzing your conversation...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take a few seconds',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😞', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            const Text(
              'Feedback generation failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Back to Home',
              onPressed: () {
                ref.read(feedbackProvider.notifier).reset();
                Navigator.pushNamedAndRemoveUntil(
                    context, AppConstants.routeHome, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(FeedbackResult result) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),
          // Score cards
          SliverToBoxAdapter(child: _buildScores(result)),
          // Overall feedback
          SliverToBoxAdapter(child: _buildOverallFeedback(result)),
          // Strengths
          if (result.strengths.isNotEmpty)
            SliverToBoxAdapter(child: _buildStrengths(result)),
          // Areas to improve
          if (result.areasToImprove.isNotEmpty)
            SliverToBoxAdapter(child: _buildAreasToImprove(result)),
          // Grammar corrections
          if (result.grammarCorrections.isNotEmpty)
            SliverToBoxAdapter(child: _buildCorrections(result)),
          // Better responses
          if (result.improvedResponses.isNotEmpty)
            SliverToBoxAdapter(child: _buildSuggestions(result)),
          // Action buttons
          SliverToBoxAdapter(child: _buildActions()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'Session Complete!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Here\'s how you did',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScores(FeedbackResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ScoreGauge(
              score: result.confidenceScore,
              label: 'Confidence',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ScoreGauge(
              score: result.fluencyScore,
              label: 'Fluency',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallFeedback(FeedbackResult result) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withOpacity(0.1),
              AppTheme.secondary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'AI Coach Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.overallFeedback,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengths(FeedbackResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star_rounded, color: AppTheme.success, size: 20),
              SizedBox(width: 8),
              Text(
                'Strengths',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.strengths.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outlined,
                        color: AppTheme.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAreasToImprove(FeedbackResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up_rounded, color: AppTheme.warning, size: 20),
              SizedBox(width: 8),
              Text(
                'Areas to Improve',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.areasToImprove.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppTheme.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCorrections(FeedbackResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.spellcheck_rounded, color: AppTheme.secondary, size: 20),
              SizedBox(width: 8),
              Text(
                'Grammar Corrections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.grammarCorrections
              .asMap()
              .entries
              .map((entry) => CorrectionCard(
                    correction: entry.value,
                    index: entry.key,
                  )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSuggestions(FeedbackResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Better Ways to Respond',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.improvedResponses
              .map((s) => SuggestionCard(suggestion: s)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GradientButton(
            text: 'Practice Again',
            icon: Icons.replay_rounded,
            gradient: AppTheme.primaryGradient,
            onPressed: () {
              ref.read(feedbackProvider.notifier).reset();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.routeCharacterSelect,
                (route) => route.settings.name == AppConstants.routeHome,
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(feedbackProvider.notifier).reset();
                ref.read(selectedScenarioProvider.notifier).state = null;
                ref.read(selectedCharacterProvider.notifier).state = null;
                Navigator.pushNamedAndRemoveUntil(
                    context, AppConstants.routeHome, (route) => false);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.cardBorder.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.home_rounded, color: AppTheme.textSecondary),
              label: const Text(
                'Back to Home',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
