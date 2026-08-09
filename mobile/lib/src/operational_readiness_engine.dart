import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

import 'models/fitness_models.dart';
import 'phoenix_translations.dart';

class DashboardConfiguration {
  const DashboardConfiguration({
    required this.cards,
    required this.pinnedMetrics,
    required this.quickEntries,
    required this.compact,
    required this.preset,
  });

  final List<String> cards;
  final List<String> pinnedMetrics;
  final List<String> quickEntries;
  final bool compact;
  final String preset;

  Map<String, Object> toJson() => {
    'cards': cards,
    'pinnedMetrics': pinnedMetrics,
    'quickEntries': quickEntries,
    'compact': compact,
    'preset': preset,
  };

  factory DashboardConfiguration.fromJson(Map<String, dynamic> json) =>
      DashboardConfiguration(
        cards: List<String>.from(json['cards'] as List? ?? const []),
        pinnedMetrics: List<String>.from(
          json['pinnedMetrics'] as List? ?? const [],
        ),
        quickEntries: List<String>.from(
          json['quickEntries'] as List? ?? const [],
        ),
        compact: json['compact'] as bool? ?? false,
        preset: json['preset'] as String? ?? 'balanced',
      );
}

class ReminderPolicy {
  const ReminderPolicy({
    this.quietStartMinutes = 22 * 60,
    this.quietEndMinutes = 7 * 60,
    this.maximumPerDay = 4,
    this.minimumGapMinutes = 120,
  });

  final int quietStartMinutes;
  final int quietEndMinutes;
  final int maximumPerDay;
  final int minimumGapMinutes;
}

class ReminderDelivery {
  const ReminderDelivery({
    required this.kind,
    required this.scheduledAt,
    required this.status,
  });

  final String kind;
  final DateTime scheduledAt;
  final String status;
}

class SmartReminder {
  const SmartReminder({
    required this.kind,
    required this.title,
    required this.reason,
    required this.scheduledAt,
    required this.priority,
  });

  final String kind;
  final String title;
  final String reason;
  final DateTime scheduledAt;
  final int priority;
}

class LocaleReadiness {
  const LocaleReadiness({
    required this.languageCode,
    required this.translated,
    required this.total,
    required this.fallbackLanguage,
    required this.isRtlReady,
  });

  final String languageCode;
  final int translated;
  final int total;
  final String fallbackLanguage;
  final bool isRtlReady;

  int get coverage => total == 0 ? 0 : (translated / total * 100).round();
}

class PerformanceBudgetReport {
  const PerformanceBudgetReport({
    required this.measurements,
    required this.budgets,
    required this.violations,
  });

  final Map<String, double> measurements;
  final Map<String, double> budgets;
  final List<String> violations;

  bool get passes => violations.isEmpty;
}

class ReconciliationResult {
  const ReconciliationResult({
    required this.data,
    required this.removed,
    required this.checksum,
  });

  final FitnessData data;
  final Map<String, int> removed;
  final String checksum;

  int get totalRemoved => removed.values.fold(0, (sum, value) => sum + value);
}

class OperationalReadinessEngine {
  const OperationalReadinessEngine._();

  static const supportedDashboardCards = <String>[
    'today-timeline',
    'weekly-command',
    'readiness',
    'next-workout',
    'nutrition',
    'hydration',
    'progress',
    'habits',
    'quick-entry',
    'data-health',
  ];

  static DashboardConfiguration dashboardPreset(String goal) {
    final normalized = goal.trim().toLowerCase();
    final goalCards =
        normalized.contains('strength') || normalized.contains('δύνα')
        ? const ['readiness', 'next-workout', 'progress']
        : normalized.contains('nutrition') || normalized.contains('διατροφ')
        ? const ['nutrition', 'hydration', 'progress']
        : normalized.contains('recovery') || normalized.contains('αποκατ')
        ? const ['readiness', 'habits', 'hydration']
        : const ['today-timeline', 'weekly-command', 'readiness'];
    return DashboardConfiguration(
      cards: [...goalCards, 'quick-entry', 'data-health'],
      pinnedMetrics: const ['sessions', 'readiness'],
      quickEntries: const ['workout', 'meal', 'water', 'recovery'],
      compact: false,
      preset: normalized.isEmpty ? 'balanced' : normalized,
    );
  }

  static DashboardConfiguration reorderDashboard(
    DashboardConfiguration source,
    List<String> cards, {
    bool? compact,
  }) {
    final unique = cards.toSet();
    if (cards.isEmpty ||
        cards.length != unique.length ||
        !unique.every(supportedDashboardCards.contains)) {
      throw const FormatException('Dashboard cards are invalid or duplicated.');
    }
    return DashboardConfiguration(
      cards: List.unmodifiable(cards),
      pinnedMetrics: source.pinnedMetrics,
      quickEntries: source.quickEntries,
      compact: compact ?? source.compact,
      preset: 'custom',
    );
  }

  static String exportDashboard(DashboardConfiguration value) => jsonEncode({
    'format': 'PHOENIX_DASHBOARD_V1',
    'configuration': value.toJson(),
  });

  static DashboardConfiguration importDashboard(String encoded) {
    final json = jsonDecode(encoded) as Map<String, dynamic>;
    if (json['format'] != 'PHOENIX_DASHBOARD_V1') {
      throw const FormatException('Unsupported dashboard backup.');
    }
    final configuration = DashboardConfiguration.fromJson(
      json['configuration'] as Map<String, dynamic>,
    );
    return reorderDashboard(
      configuration,
      configuration.cards,
      compact: configuration.compact,
    );
  }

  static bool isQuiet(DateTime value, ReminderPolicy policy) {
    final minutes = value.hour * 60 + value.minute;
    final start = policy.quietStartMinutes;
    final end = policy.quietEndMinutes;
    return start <= end
        ? minutes >= start && minutes < end
        : minutes >= start || minutes < end;
  }

  static DateTime afterQuietHours(DateTime value, ReminderPolicy policy) {
    if (!isQuiet(value, policy)) return value;
    var candidate = DateTime(
      value.year,
      value.month,
      value.day,
      policy.quietEndMinutes ~/ 60,
      policy.quietEndMinutes % 60,
    );
    if (!candidate.isAfter(value)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  static DateTime snooze(
    DateTime scheduledAt, {
    required int minutes,
    required ReminderPolicy policy,
  }) {
    if (minutes < 5 || minutes > 24 * 60) {
      throw const FormatException(
        'Snooze must stay between 5 minutes and one day.',
      );
    }
    return afterQuietHours(scheduledAt.add(Duration(minutes: minutes)), policy);
  }

  static List<SmartReminder> smartReminders({
    required FitnessData data,
    required DateTime now,
    required ReminderPolicy policy,
    List<ReminderDelivery> history = const [],
  }) {
    if (policy.maximumPerDay < 1 ||
        policy.maximumPerDay > 10 ||
        policy.minimumGapMinutes < 30 ||
        policy.minimumGapMinutes > 720) {
      throw const FormatException(
        'Reminder policy exceeds fatigue-safe bounds.',
      );
    }
    final dayStart = DateTime(now.year, now.month, now.day);
    final deliveredToday = history
        .where(
          (item) =>
              !item.scheduledAt.isBefore(dayStart) &&
              item.status == 'delivered',
        )
        .toList();
    if (deliveredToday.length >= policy.maximumPerDay) return const [];
    final candidates = <SmartReminder>[];
    DateTime safeTime(Duration offset) =>
        afterQuietHours(now.add(offset), policy);
    bool recentlyDelivered(String kind) => history.any(
      (item) =>
          item.kind == kind &&
          item.status == 'delivered' &&
          now.difference(item.scheduledAt).inMinutes < policy.minimumGapMinutes,
    );

    final todaysWater = data.hydration
        .where((item) => _sameDay(item.loggedAt, now))
        .fold<int>(0, (sum, item) => sum + item.milliliters);
    if (todaysWater < 1000 && !recentlyDelivered('hydration')) {
      candidates.add(
        SmartReminder(
          kind: 'hydration',
          title: 'Hydration check',
          reason: '$todaysWater ml logged today; a small prompt may be useful.',
          scheduledAt: safeTime(const Duration(minutes: 30)),
          priority: 2,
        ),
      );
    }
    final latestMeal = data.meals.isEmpty
        ? null
        : (data.meals.toList()
                ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt)))
              .first;
    if ((latestMeal == null ||
            now.difference(latestMeal.loggedAt).inHours >= 5) &&
        !recentlyDelivered('meal')) {
      candidates.add(
        SmartReminder(
          kind: 'meal',
          title: 'Optional meal log',
          reason:
              'No recent meal entry; dismiss if this does not fit your day.',
          scheduledAt: safeTime(const Duration(minutes: 45)),
          priority: 1,
        ),
      );
    }
    final assignedToday =
        data.dateAssignments[_dateKey(now)] ??
        data.weeklyAssignments['${now.weekday}'];
    final completedToday = data.logs.any(
      (item) => _sameDay(item.completedAt, now),
    );
    if (assignedToday != null &&
        !completedToday &&
        !recentlyDelivered('workout')) {
      candidates.add(
        SmartReminder(
          kind: 'workout',
          title: 'Planned session is still open',
          reason: 'Today has a local plan but no completion yet.',
          scheduledAt: safeTime(const Duration(hours: 1)),
          priority: 4,
        ),
      );
    }
    final lastWeight = data.weights.isEmpty
        ? null
        : (data.weights.toList()
                ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt)))
              .first;
    if ((lastWeight == null ||
            now.difference(lastWeight.recordedAt).inDays >= 14) &&
        !recentlyDelivered('measurement')) {
      candidates.add(
        SmartReminder(
          kind: 'measurement',
          title: 'Optional measurement window',
          reason: 'No bodyweight entry in the last fourteen days.',
          scheduledAt: safeTime(const Duration(hours: 2)),
          priority: 1,
        ),
      );
    }
    candidates.sort((a, b) => b.priority.compareTo(a.priority));
    return candidates
        .take(policy.maximumPerDay - deliveredToday.length)
        .toList();
  }

  static const localeCatalog = <String, Map<String, String>>{
    'today': {'el': 'Σήμερα', 'en': 'Today', 'de': 'Heute', 'es': 'Hoy'},
    'workout': {
      'el': 'Προπόνηση',
      'en': 'Workout',
      'de': 'Training',
      'es': 'Entrenamiento',
    },
    'nutrition': {
      'el': 'Διατροφή',
      'en': 'Nutrition',
      'de': 'Ernährung',
      'es': 'Nutrición',
    },
    'recovery': {
      'el': 'Αποκατάσταση',
      'en': 'Recovery',
      'de': 'Erholung',
      'es': 'Recuperación',
    },
    'settings': {
      'el': 'Ρυθμίσεις',
      'en': 'Settings',
      'de': 'Einstellungen',
      'es': 'Ajustes',
    },
    'save': {
      'el': 'Αποθήκευση',
      'en': 'Save',
      'de': 'Speichern',
      'es': 'Guardar',
    },
    'cancel': {
      'el': 'Ακύρωση',
      'en': 'Cancel',
      'de': 'Abbrechen',
      'es': 'Cancelar',
    },
    'offline': {
      'el': 'Εκτός σύνδεσης',
      'en': 'Offline',
      'de': 'Offline',
      'es': 'Sin conexión',
    },
  };

  static String localized(String key, String languageCode) =>
      localeCatalog[key]?[languageCode] ??
      localeCatalog[key]?['en'] ??
      key.replaceAll('-', ' ');

  static LocaleReadiness localeReadiness(String languageCode) {
    final translated = languageCode == 'el' || languageCode == 'en'
        ? PhoenixTranslations.catalog.length
        : PhoenixTranslations.translatedCount(languageCode);
    return LocaleReadiness(
      languageCode: languageCode,
      translated: translated,
      total: PhoenixTranslations.catalog.length,
      fallbackLanguage: 'en',
      isRtlReady: true,
    );
  }

  static String formatDecimal(double value, String languageCode) =>
      NumberFormat.decimalPattern(languageCode).format(value);

  static double parseDecimal(String value, String languageCode) {
    final symbols = NumberFormat.decimalPattern(languageCode).symbols;
    final normalized = value
        .trim()
        .replaceAll(symbols.GROUP_SEP, '')
        .replaceAll(symbols.DECIMAL_SEP, '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || !parsed.isFinite) {
      throw const FormatException('Invalid locale-aware decimal.');
    }
    return parsed;
  }

  static String formatDate(DateTime value, String languageCode) {
    const months = <String, List<String>>{
      'el': [
        'Ιαν',
        'Φεβ',
        'Μαρ',
        'Απρ',
        'Μαΐ',
        'Ιουν',
        'Ιουλ',
        'Αυγ',
        'Σεπ',
        'Οκτ',
        'Νοε',
        'Δεκ',
      ],
      'en': [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ],
      'de': [
        'Jan',
        'Feb',
        'Mär',
        'Apr',
        'Mai',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Okt',
        'Nov',
        'Dez',
      ],
      'es': [
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sept',
        'oct',
        'nov',
        'dic',
      ],
    };
    final selected = months[languageCode] ?? months['en']!;
    return languageCode == 'en'
        ? '${selected[value.month - 1]} ${value.day}, ${value.year}'
        : '${value.day} ${selected[value.month - 1]} ${value.year}';
  }

  static String exportLanguage(String languageCode) => jsonEncode({
    'format': 'PHOENIX_LANGUAGE_V1',
    'languageCode': languageCode,
  });

  static String importLanguage(String encoded) {
    final json = jsonDecode(encoded) as Map<String, dynamic>;
    final code = json['languageCode'] as String?;
    if (json['format'] != 'PHOENIX_LANGUAGE_V1' ||
        !const {'el', 'en', 'de', 'es'}.contains(code)) {
      throw const FormatException('Unsupported Phoenix language setting.');
    }
    return code!;
  }

  static PerformanceBudgetReport performanceBudget(
    Map<String, double> measurements,
  ) {
    const budgets = <String, double>{
      'startup-ms': 1500,
      'database-query-ms': 100,
      'json-serialization-ms': 75,
      'json-deserialization-ms': 100,
      'integrity-audit-ms': 75,
      'reconciliation-ms': 100,
      'profile-payload-kb': 8192,
      'chart-frame-ms': 16.7,
      'rebuild-count': 20,
      'web-bundle-mb': 12,
      'image-memory-mb': 64,
    };
    final violations = <String>[];
    for (final entry in measurements.entries) {
      final budget = budgets[entry.key];
      if (budget == null || entry.value < 0 || !entry.value.isFinite) {
        violations.add('${entry.key}: invalid or unbudgeted measurement');
      } else if (entry.value > budget) {
        violations.add(
          '${entry.key}: ${entry.value.toStringAsFixed(1)} exceeds ${budget.toStringAsFixed(1)}',
        );
      }
    }
    return PerformanceBudgetReport(
      measurements: Map.unmodifiable(measurements),
      budgets: budgets,
      violations: violations,
    );
  }

  static String checksum(FitnessData data) =>
      sha256.convert(utf8.encode(jsonEncode(data.toJson()))).toString();

  static ReconciliationResult reconcileDuplicates(FitnessData data) {
    List<T> unique<T>(List<T> values, String Function(T) key) {
      final seen = <String>{};
      return [
        for (final value in values)
          if (seen.add(key(value))) value,
      ];
    }

    final logs = unique(
      data.logs,
      (item) =>
          '${item.templateName}|${item.completedAt.toIso8601String()}|${item.minutes}',
    );
    final meals = unique(
      data.meals,
      (item) =>
          '${item.name}|${item.loggedAt.toIso8601String()}|${item.calories}',
    );
    final hydration = unique(
      data.hydration,
      (item) => '${item.loggedAt.toIso8601String()}|${item.milliliters}',
    );
    final wearable = unique(data.wearableSummaries, (item) => item.id);
    final reconciled = data.copyWith(
      logs: logs,
      meals: meals,
      hydration: hydration,
      wearableSummaries: wearable,
    );
    return ReconciliationResult(
      data: reconciled,
      removed: {
        'workouts': data.logs.length - logs.length,
        'meals': data.meals.length - meals.length,
        'hydration': data.hydration.length - hydration.length,
        'wearables': data.wearableSummaries.length - wearable.length,
      },
      checksum: checksum(reconciled),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
