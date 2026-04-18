import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/scenario_provider.dart';
import '../../widgets/scenario/scenario_card.dart';
import '../../widgets/common/gradient_button.dart';

/// Scenario selection screen
class ScenarioSelectionScreen extends ConsumerWidget {
  const ScenarioSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenarios = ref.watch(scenariosProvider);
    final selected = ref.watch(selectedScenarioProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Choose Your\nScenario',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pick a real-life situation to practice',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Scenario cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: scenarios.length,
                  itemBuilder: (context, index) {
                    final scenario = scenarios[index];
                    return ScenarioCard(
                      scenario: scenario,
                      isSelected: selected?.id == scenario.id,
                      onTap: () {
                        ref.read(selectedScenarioProvider.notifier).state =
                            scenario;
                      },
                    );
                  },
                ),
              ),
              // Continue button
              Padding(
                padding: const EdgeInsets.all(24),
                child: GradientButton(
                  text: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: selected != null
                      ? () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeCharacterSelect,
                          );
                        }
                      : () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
