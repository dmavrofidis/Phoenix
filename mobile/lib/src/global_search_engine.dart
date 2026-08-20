import 'models/fitness_models.dart';
import 'exercise_intelligence_engine.dart';
import 'equipment_availability.dart';

enum SearchResultType { workout, exercise, workoutLog, meal, tool }

class PhoenixSearchResult {
  const PhoenixSearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.keywords,
    this.template,
    this.route = '',
  });

  final SearchResultType type;
  final String title;
  final String subtitle;
  final String keywords;
  final WorkoutTemplate? template;
  final String route;
}

class GlobalSearchEngine {
  const GlobalSearchEngine._();

  static List<PhoenixSearchResult> search(FitnessData data, String query) {
    final normalized = query.trim().toLowerCase();
    final all = <PhoenixSearchResult>[
      for (final template in data.templates)
        PhoenixSearchResult(
          type: SearchResultType.workout,
          title: template.name,
          subtitle:
              '${template.exercises.length} ασκήσεις • ${template.tags.join(' • ')}',
          keywords:
              '${template.name} ${template.exercises.join(' ')} ${template.tags.join(' ')}',
          template: template,
        ),
      for (final profile in ExerciseIntelligenceEngine.allProfiles(data))
        if (EquipmentAvailability.supportsExercise(
              profile.name,
              data.profile,
            ) &&
            ExerciseIntelligenceEngine.isEquipmentCompatible(
              profile,
              data.profile,
            ))
          PhoenixSearchResult(
            type: SearchResultType.exercise,
            title: profile.name,
            subtitle:
                '${profile.movementPattern} • ${profile.primaryMuscles.join(' • ')}',
            keywords:
                '${profile.name} ${profile.movementPattern} '
                '${profile.primaryMuscles.join(' ')} '
                '${profile.secondaryMuscles.join(' ')} '
                '${profile.equipment.join(' ')} exercise άσκηση οδηγός guide',
            route: 'exercise',
          ),
      for (final log in data.logs.take(100))
        PhoenixSearchResult(
          type: SearchResultType.workoutLog,
          title: log.templateName,
          subtitle:
              '${log.completedAt.day}/${log.completedAt.month}/${log.completedAt.year} • ${log.sets.length} σετ',
          keywords: '${log.templateName} ${log.notes} ιστορικό history',
          route: 'analytics',
        ),
      for (final meal in data.meals.take(100))
        PhoenixSearchResult(
          type: SearchResultType.meal,
          title: meal.name,
          subtitle:
              '${meal.calories} kcal • ${meal.proteinGrams.toStringAsFixed(0)} g πρωτεΐνη',
          keywords: '${meal.name} γεύμα meal nutrition διατροφή',
          route: 'nutrition',
        ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Program Architecture',
        subtitle: 'Mesocycle wizard, split design, set budgets and audit',
        keywords:
            'program architecture mesocycle split duration set budget movement balance frequency med mrv conflict',
        route: 'architecture',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Strength Lab',
        subtitle:
            'Big-lift dashboard, plate loading, protocols and meet attempts',
        keywords:
            'strength lab squat bench deadlift overhead press training max rep max plate loading warmup top set backoff velocity meet attempts',
        route: 'strength-lab',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Hypertrophy Lab',
        subtitle:
            'Volume landmarks, stimulus scoring, set techniques and specialization',
        keywords:
            'hypertrophy muscle growth volume mev mav mrv stimulus fatigue lengthened pump soreness myo reps drop set rest pause specialization',
        route: 'hypertrophy',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Conditioning Lab',
        subtitle:
            'Heart-rate zones, session builder, cardio load and benchmarks',
        keywords:
            'conditioning cardio heart rate zone 2 intervals work rest rpe modality aerobic interference benchmark cooper row bike',
        route: 'conditioning',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Running Lab',
        subtitle: 'Pace, 5K plans, mileage, shoes and running-load guard',
        keywords:
            'running pace run walk 5k plan long run mileage shoe surface elevation cadence injury guard race predictor',
        route: 'running',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Cycling & Rowing Lab',
        subtitle: 'FTP, power zones, erg splits, workouts and multi-sport load',
        keywords:
            'cycling bike rowing erg ftp power zones cadence split watts stroke rate indoor workout benchmark endurance multi sport load',
        route: 'endurance',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Advanced Calisthenics',
        subtitle: 'Six skill trees, readiness, straight-arm load and deload',
        keywords:
            'advanced calisthenics muscle up front lever back lever planche handstand push up rings false grip straight arm skill exposure deload',
        route: 'advanced-cali',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Mobility Intelligence',
        subtitle: 'Joint screens, asymmetry, snacks, lift matching and retests',
        keywords:
            'mobility intelligence joint screen ankle dorsiflexion hip rotation shoulder flexion thoracic asymmetry snack pre lift posture break retest',
        route: 'mobility-intelligence',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Recovery Intelligence',
        subtitle: 'Recovery trends, sleep debt, RHR alerts and interventions',
        keywords:
            'recovery intelligence sleep debt soreness decay stress load resting heart rate rhr deviation active recovery sauna cold exposure intervention comparison baseline forecast',
        route: 'recovery-intelligence',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Recommended Meal Plan',
        subtitle: 'Simple weekly meals adapted to your goal and preferences',
        keywords:
            'recommended meal plan weekly food diet nutrition grocery simple personalized διατροφή πρόγραμμα φαγητό φαγητού εβδομάδα εβδομαδιαίο',
        route: 'recommended-nutrition',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Nutrition Planner',
        subtitle:
            'Goal phases, weekly calories, macro timing and diet transitions',
        keywords:
            'nutrition planner calorie phase weekly budget protein distribution carb timing fat minimum fiber sodium hydration meal timing diet break reverse diet',
        route: 'nutrition-planner',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Meal Intelligence',
        subtitle:
            'Ingredient builder, pantry, expiry, budget and batch cooking',
        keywords:
            'meal intelligence ingredient recipe serving duplicate favorite recent food macro suggestion pantry inventory expiry budget grocery batch cooking',
        route: 'meal-intelligence',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Body Composition',
        subtitle:
            'Smoothed weight, measurements, photo compare and projections',
        keywords:
            'body composition smoothed weight trend weekly rate waist measurement body fat lean mass progress photo comparison reminder projection plateau calorie review',
        route: 'body-composition',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Habit Builder',
        subtitle:
            'Daily checklist, streak protection, stacking and correlations',
        keywords:
            'habit builder health behavior daily checklist streak protection weekly score implementation intention stacking friction minimum day reflection correlation',
        route: 'habit-builder',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Sleep & Stress',
        subtitle:
            'Schedule, caffeine cutoff, wind-down, stress and fatigue brief',
        keywords:
            'sleep stress bedtime wake consistency caffeine cutoff wind down screen free relaxation training correlation fatigue morning brief',
        route: 'sleep-stress',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Advanced Coach',
        subtitle: 'Explainable recommendations, feedback, reviews and safety',
        keywords:
            'advanced coach explainable recommendation confidence competing goal priority rule trace feedback learning weekly monthly review drift safety escalation',
        route: 'advanced-coach',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Analytics Studio',
        subtitle:
            'Custom metrics, comparisons, monotony, heatmaps and forecasts',
        keywords:
            'analytics studio custom metric dashboard date range comparison moving average training monotony strain volume intensity distribution set rep heatmap adherence funnel goal forecast annotation',
        route: 'analytics-studio',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Reports Studio',
        subtitle:
            'Weekly, nutrition, recovery, strength and coach handoff reports',
        keywords:
            'reports studio weekly monthly nutrition adherence recovery strength calisthenics coach handoff print copy local',
        route: 'reports',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Exercise Intelligence',
        subtitle: 'Taxonomy, muscles, equipment, safety and progressions',
        keywords:
            'exercise intelligence taxonomy muscle movement equipment caution progression substitution builder',
        route: 'exercise-lab',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Advanced Analytics',
        subtitle: 'e1RM, PRs, φόρτος, συνέπεια και exports',
        keywords: 'analytics e1rm pr progress πρόοδος στατιστικά export',
        route: 'analytics',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Recovery Lab',
        subtitle: 'Ύπνος, readiness, κόπωση και επιστροφή',
        keywords: 'recovery sleep ύπνος αποκατάσταση readiness soreness',
        route: 'recovery',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Mobility Lab',
        subtitle: 'Κινητικότητα και ασφαλής προετοιμασία',
        keywords: 'mobility warmup stretch κινητικότητα ζέσταμα',
        route: 'mobility',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Nutrition Pro',
        subtitle: 'Γεύματα, macros, νερό και grocery list',
        keywords: 'nutrition meal macros water διατροφή γεύμα νερό',
        route: 'nutrition',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Weekly Planner',
        subtitle: 'Οργάνωση εβδομαδιαίου προγράμματος',
        keywords: 'planner week schedule εβδομάδα πρόγραμμα ημερολόγιο',
        route: 'planner',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Phoenix Coach',
        subtitle: 'Daily actions, plateau radar και long-term phases',
        keywords:
            'coach daily action plateau reschedule technique phases καθοδήγηση',
        route: 'coach',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Strength Test Lab',
        subtitle: 'AMRAP και ασφαλές estimated 1RM protocol',
        keywords: 'strength test amrap e1rm 1rm δύναμη τεστ',
        route: 'test',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Calisthenics Lab',
        subtitle: 'Skill trees, assessments, practice και hold analytics',
        keywords:
            'calisthenics skill tree handstand pull-up push-up l-sit hold καλλισθενική',
        route: 'calisthenics',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Media & Portability',
        subtitle:
            'Share cards, private photos, Spotify, QR, PDF και wearable import',
        keywords:
            'media share photo vault spotify playlist video qr backup pdf print wearable import',
        route: 'media',
      ),
      const PhoenixSearchResult(
        type: SearchResultType.tool,
        title: 'Reliability Center',
        subtitle: 'SQLite, migrations, profiles, reminders και release audit',
        keywords:
            'reliability sqlite drift migration diagnostics profiles reminders pwa security audit',
        route: 'reliability',
      ),
    ];
    if (normalized.isEmpty) {
      return all.where((item) => item.type == SearchResultType.tool).toList();
    }
    final terms = normalized.split(RegExp(r'\s+'));
    final matches = all.where((item) {
      final haystack = '${item.title} ${item.subtitle} ${item.keywords}'
          .toLowerCase();
      return terms.every(haystack.contains);
    }).toList();
    matches.sort((left, right) {
      final leftStarts = left.title.toLowerCase().startsWith(normalized);
      final rightStarts = right.title.toLowerCase().startsWith(normalized);
      if (leftStarts != rightStarts) return leftStarts ? -1 : 1;
      return left.title.compareTo(right.title);
    });
    return matches.take(60).toList();
  }
}
