import 'models/fitness_models.dart';

class EquipmentAvailability {
  const EquipmentAvailability._();

  static bool isHome(UserProfile? profile) {
    if (profile == null) return false;
    final place = _normalize(profile.trainingPlace);
    return place.contains('σπιτι') || place.contains('home');
  }

  static bool hasBands(UserProfile? profile) =>
      _available(profile).containsAny(const ['λαστιχ', 'band']);

  static bool hasDumbbells(UserProfile? profile) => _available(
    profile,
  ).containsAny(const ['αλτηρ', 'βαρακ', 'dumbbell', 'kettlebell']);

  static bool hasPullUpBar(UserProfile? profile) => _available(
    profile,
  ).containsAny(const ['μονοζυγ', 'pull-up bar', 'pull up bar', 'μπαρα']);

  static bool hasTreadmill(UserProfile? profile) =>
      _available(profile).containsAny(const ['διαδρομ', 'treadmill']);

  static bool supportsExercise(String exercise, UserProfile? profile) {
    if (profile == null || !isHome(profile)) return true;
    final available = _available(profile);
    if (available.containsAny(const ['πληρες γυμναστηριο', 'full gym'])) {
      return true;
    }

    final name = _normalize(exercise);
    if (name.containsAny(const [
      'trap-bar',
      'trap bar',
      'landmine',
      'τροχαλ',
      'cable machine',
      'κωπηλατικο εργομετρο',
      'row ergometer',
      'air bike',
      'sled',
      'safety bars',
    ])) {
      return false;
    }
    if (name.containsAny(const ['λαστιχ', 'band', 'pallof', 'face pull']) &&
        !hasBands(profile)) {
      return false;
    }
    if (name.containsAny(const [
          'αλτηρ',
          'βαρακ',
          'dumbbell',
          'kettlebell',
          'goblet',
          'farmer carry',
          'suitcase carry',
        ]) &&
        !hasDumbbells(profile)) {
      return false;
    }
    if (name.containsAny(const [
          'ελξει',
          'pull-up',
          'pull up',
          'hanging',
          'κρεμαστ',
          'scapular pull',
        ]) &&
        !hasPullUpBar(profile)) {
      return false;
    }
    if (name.containsAny(const ['διαδρομ', 'treadmill']) &&
        !hasTreadmill(profile)) {
      return false;
    }
    if (name.containsAny(const ['σακιδ', 'backpack']) &&
        !available.containsAny(const ['σακιδ', 'backpack'])) {
      return false;
    }
    if (name.containsAny(const ['παγκο', 'bench']) &&
        !available.containsAny(const ['παγκο', 'bench'])) {
      return false;
    }
    return true;
  }

  static _NormalizedText _available(UserProfile? profile) =>
      _NormalizedText(_normalize(profile?.equipment ?? ''));

  static String _normalize(String value) {
    var normalized = value.trim().toLowerCase();
    const replacements = <String, String>{
      'ά': 'α',
      'έ': 'ε',
      'ή': 'η',
      'ί': 'ι',
      'ϊ': 'ι',
      'ΐ': 'ι',
      'ό': 'ο',
      'ύ': 'υ',
      'ϋ': 'υ',
      'ΰ': 'υ',
      'ώ': 'ω',
      'ς': 'σ',
    };
    for (final entry in replacements.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    return normalized;
  }
}

extension on String {
  bool containsAny(Iterable<String> terms) => terms.any(contains);
}

class _NormalizedText {
  const _NormalizedText(this.value);

  final String value;

  bool contains(String term) => value.contains(term);

  bool containsAny(Iterable<String> terms) => terms.any(value.contains);
}
