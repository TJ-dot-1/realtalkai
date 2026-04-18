import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/scenario_provider.dart';
import '../../widgets/scenario/character_avatar.dart';
import '../../widgets/common/gradient_button.dart';

/// Character selection screen
class CharacterSelectionScreen extends ConsumerWidget {
  const CharacterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(charactersProvider);
    final selected = ref.watch(selectedCharacterProvider);
    final scenario = ref.watch(selectedScenarioProvider);

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
                      'Choose Your\nConversation Partner',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (scenario != null)
                      Row(
                        children: [
                          Text(scenario.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            scenario.title,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Character cards — horizontal scroll
              Expanded(
                child: PageView.builder(
                  itemCount: characters.length,
                  controller: PageController(viewportFraction: 0.85),
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: CharacterAvatar(
                        character: character,
                        isSelected: selected?.id == character.id,
                        onTap: () {
                          ref.read(selectedCharacterProvider.notifier).state =
                              character;
                        },
                      ),
                    );
                  },
                ),
              ),
              // Start button
              Padding(
                padding: const EdgeInsets.all(24),
                child: GradientButton(
                  text: 'Start Conversation',
                  icon: Icons.mic_rounded,
                  gradient: selected != null ? AppTheme.primaryGradient : null,
                  onPressed: selected != null
                      ? () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeConversation,
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
