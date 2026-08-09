import 'package:flutter/material.dart';

enum EducationTopic {
  exercise,
  errors,
  breathing,
  tempo,
  effort,
  safety,
  warmup,
  nutrition,
  recovery,
}

class EducationLesson {
  const EducationLesson({
    required this.id,
    required this.topic,
    required this.title,
    required this.summary,
    required this.cues,
    required this.stopRule,
  });

  final String id;
  final EducationTopic topic;
  final String title;
  final String summary;
  final List<String> cues;
  final String stopRule;

  String get searchText =>
      '$id $title $summary ${cues.join(' ')} ${topic.name}'.toLowerCase();
}

class PhoenixEducationLibrary {
  const PhoenixEducationLibrary._();

  static const lessons = <EducationLesson>[
    EducationLesson(
      id: 'exercise-cues',
      topic: EducationTopic.exercise,
      title: 'Exercise cue library',
      summary: 'Use one external cue at a time and keep the rep repeatable.',
      cues: [
        'Brace before moving',
        'Control the lowering phase',
        'Finish in the same stable position',
      ],
      stopRule:
          'Stop when the next repetition cannot match the intended technique.',
    ),
    EducationLesson(
      id: 'common-errors',
      topic: EducationTopic.errors,
      title: 'Common-error library',
      summary:
          'Correct the cause of a failed position before adding load or speed.',
      cues: [
        'Reduce range if control is lost',
        'Use a stable stance',
        'Avoid chasing fatigue with momentum',
      ],
      stopRule:
          'Regress the movement if the same error repeats after one correction.',
    ),
    EducationLesson(
      id: 'breathing',
      topic: EducationTopic.breathing,
      title: 'Breathing cue library',
      summary:
          'Match breathing to task intensity without prolonged breath holding.',
      cues: [
        'Inhale before the effort',
        'Brace through the hardest range',
        'Exhale under control',
      ],
      stopRule:
          'Stop if breathlessness, dizziness, chest discomfort, or unusual symptoms appear.',
    ),
    EducationLesson(
      id: 'tempo',
      topic: EducationTopic.tempo,
      title: 'Tempo education cards',
      summary: 'Tempo uses eccentric, pause, concentric, and reset counts.',
      cues: [
        '3-1-1-0 means three seconds down',
        'Pauses remove momentum',
        'Tempo must not hide pain',
      ],
      stopRule:
          'End the set when the prescribed tempo can no longer be maintained.',
    ),
    EducationLesson(
      id: 'rpe-rir',
      topic: EducationTopic.effort,
      title: 'RPE and RIR tutorial',
      summary:
          'RIR estimates good repetitions remaining; RPE describes the completed effort.',
      cues: [
        'RIR 3 is controlled work',
        'RIR 1 is near the limit',
        'Technique failure is not a valid extra rep',
      ],
      stopRule:
          'Do not use RIR 0 by default or when readiness and technique are uncertain.',
    ),
    EducationLesson(
      id: 'pain-effort',
      topic: EducationTopic.safety,
      title: 'Pain versus effort education',
      summary:
          'Muscular effort can be expected; sharp, escalating, or joint pain is not a target.',
      cues: [
        'Effort is diffuse and resolves',
        'Pain may be sharp or localized',
        'Record location and trend',
      ],
      stopRule:
          'Stop the provoking movement and seek professional guidance for severe or persistent symptoms.',
    ),
    EducationLesson(
      id: 'warmup',
      topic: EducationTopic.warmup,
      title: 'Warm-up education',
      summary:
          'Warm up the movement and load without creating pre-session fatigue.',
      cues: [
        'Raise temperature briefly',
        'Rehearse the target pattern',
        'Ramp load while reps fall',
      ],
      stopRule:
          'Do not continue a warm-up progression that increases pain or reduces control.',
    ),
    EducationLesson(
      id: 'nutrition',
      topic: EducationTopic.nutrition,
      title: 'Nutrition fundamentals library',
      summary:
          'Consistency, adequate energy, protein, fiber, and hydration precede optimization.',
      cues: [
        'Use repeatable anchor meals',
        'Distribute protein',
        'Adjust from multi-week trends',
      ],
      stopRule:
          'Phoenix does not diagnose or replace individualized medical nutrition care.',
    ),
    EducationLesson(
      id: 'recovery',
      topic: EducationTopic.recovery,
      title: 'Recovery fundamentals library',
      summary:
          'Sleep, manageable training stress, food, and time drive most recovery.',
      cues: [
        'Protect a regular sleep window',
        'Use easier days intentionally',
        'Compare trends, not one score',
      ],
      stopRule:
          'Persistent fatigue, illness, or worsening symptoms require rest and appropriate care.',
    ),
  ];

  static List<EducationLesson> search(String query, {EducationTopic? topic}) {
    final normalized = query.trim().toLowerCase();
    return lessons
        .where((lesson) => topic == null || lesson.topic == topic)
        .where(
          (lesson) =>
              normalized.isEmpty || lesson.searchText.contains(normalized),
        )
        .toList();
  }
}

class EducationLibraryPage extends StatefulWidget {
  const EducationLibraryPage({super.key});

  @override
  State<EducationLibraryPage> createState() => _EducationLibraryPageState();
}

class _EducationLibraryPageState extends State<EducationLibraryPage> {
  final _query = TextEditingController();
  EducationTopic? _topic;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = PhoenixEducationLibrary.search(_query.text, topic: _topic);
    return Scaffold(
      appBar: AppBar(title: const Text('PHOENIX EDUCATION LIBRARY')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          Text(
            'LEARN IN CONTEXT',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Text(
            'Concise, offline lessons with a practical cue and explicit stop rule.',
          ),
          const SizedBox(height: 14),
          SearchBar(
            controller: _query,
            leading: const Icon(Icons.search),
            hintText: 'Search cue, error, effort, pain, food or recovery…',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              ChoiceChip(
                label: const Text('ALL'),
                selected: _topic == null,
                onSelected: (_) => setState(() => _topic = null),
              ),
              for (final topic in EducationTopic.values)
                ChoiceChip(
                  label: Text(topic.name.toUpperCase()),
                  selected: _topic == topic,
                  onSelected: (_) => setState(() => _topic = topic),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (lessons.isEmpty)
            const Card(
              child: ListTile(title: Text('No lesson matches this search.')),
            )
          else
            for (final lesson in lessons)
              Card(
                child: ExpansionTile(
                  leading: Icon(_icon(lesson.topic)),
                  title: Text(
                    lesson.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(lesson.summary),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final cue in lesson.cues)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text('• $cue'),
                      ),
                    const SizedBox(height: 5),
                    Text(
                      'STOP RULE: ${lesson.stopRule}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

IconData _icon(EducationTopic topic) => switch (topic) {
  EducationTopic.exercise => Icons.fitness_center,
  EducationTopic.errors => Icons.warning_amber,
  EducationTopic.breathing => Icons.air,
  EducationTopic.tempo => Icons.speed,
  EducationTopic.effort => Icons.monitor_heart_outlined,
  EducationTopic.safety => Icons.health_and_safety_outlined,
  EducationTopic.warmup => Icons.local_fire_department_outlined,
  EducationTopic.nutrition => Icons.restaurant_outlined,
  EducationTopic.recovery => Icons.bedtime_outlined,
};
