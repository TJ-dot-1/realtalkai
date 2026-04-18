import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scenario.dart';
import '../models/character.dart';

/// Selected scenario provider
final selectedScenarioProvider = StateProvider<Scenario?>((ref) => null);

/// Selected character provider
final selectedCharacterProvider = StateProvider<Character?>((ref) => null);

/// Available scenarios provider
final scenariosProvider = Provider<List<Scenario>>((ref) {
  return Scenario.all;
});

/// Available characters provider
final charactersProvider = Provider<List<Character>>((ref) {
  return Character.all;
});
