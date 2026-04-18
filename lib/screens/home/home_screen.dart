import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../models/scenario.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

/// Home dashboard with progress stats and quick actions
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();

    // Load progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authProvider).userId ?? '';
      ref.read(progressProvider.notifier).loadProgress(userId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // App bar
                SliverToBoxAdapter(child: _buildHeader(auth)),
                // Stats cards
                SliverToBoxAdapter(child: _buildStats(progress)),
                // Quick start section
                SliverToBoxAdapter(child: _buildQuickStart()),
                // Recent activity
                SliverToBoxAdapter(child: _buildRecentSection(progress)),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthState auth) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.displayName ?? 'Learner',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Profile / Settings
          GestureDetector(
            onTap: () => _showSettingsMenu(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  (auth.displayName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ProgressState progress) {
    final p = progress.progress;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.trending_up_rounded,
            value: '${p.latestFluency}',
            label: 'Fluency',
            color: AppTheme.secondary,
            trend: p.fluencyTrend,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.chat_bubble_rounded,
            value: '${p.sessionsCompleted}',
            label: 'Sessions',
            color: AppTheme.primary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            value: '${p.streak}',
            label: 'Streak',
            color: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    int? trend,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.cardBorder.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (trend != null && trend != 0) ...[
                  const SizedBox(width: 4),
                  Icon(
                    trend > 0
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: trend > 0 ? AppTheme.success : AppTheme.error,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStart() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start Practicing',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose a scenario to begin a conversation',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GradientButton(
            text: 'New Conversation',
            icon: Icons.add_rounded,
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.routeScenarioSelect);
            },
          ),
          const SizedBox(height: 16),
          // Quick scenario buttons
          Row(
            children: Scenario.all.map((scenario) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: scenario != Scenario.all.last ? 8 : 0,
                  ),
                  child: _buildQuickScenarioButton(scenario),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickScenarioButton(Scenario scenario) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppConstants.routeScenarioSelect,
          arguments: scenario,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.cardBorder.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(scenario.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              scenario.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection(ProgressState progress) {
    final p = progress.progress;
    if (p.sessionsCompleted == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassCard(
          child: Column(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'No sessions yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start your first conversation to begin tracking your progress!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Scenario completion cards
          ...Scenario.all.map((scenario) {
            final sp = p.scenarioProgress[scenario.id];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.cardBorder.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text(scenario.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${sp?.completed ?? 0} sessions completed',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sp != null && sp.bestScore > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Best: ${sp.bestScore}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.error),
                  title: const Text('Sign Out',
                      style: TextStyle(color: AppTheme.textPrimary)),
                  onTap: () {
                    ref.read(authProvider.notifier).signOut();
                    Navigator.pushReplacementNamed(
                        context, AppConstants.routeLogin);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
