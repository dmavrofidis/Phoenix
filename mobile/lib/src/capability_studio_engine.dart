import 'models/fitness_models.dart';

enum CapabilityKind {
  planner,
  tracker,
  audit,
  automation,
  importExport,
  education,
  security,
  timer,
  accessibility,
}

class CapabilitySpec {
  const CapabilitySpec({
    required this.id,
    required this.title,
    required this.batch,
    required this.batchTitle,
    required this.kind,
  });

  final int id;
  final String title;
  final int batch;
  final String batchTitle;
  final CapabilityKind kind;

  String get searchText =>
      '$id $title $batch $batchTitle ${kind.name}'.toLowerCase();
}

class CapabilityOutcome {
  const CapabilityOutcome({
    required this.score,
    required this.status,
    required this.summary,
    required this.nextAction,
    required this.evidence,
  });

  final int score;
  final String status;
  final String summary;
  final String nextAction;
  final List<String> evidence;

  String get exportText => [
    '$status • $score/100',
    summary,
    'Next: $nextAction',
    ...evidence.map((item) => 'Evidence: $item'),
  ].join('\n');
}

class CapabilityStudioEngine {
  static final List<CapabilitySpec> catalog = _buildCatalog();

  static List<CapabilitySpec> _buildCatalog() {
    final titles = _capabilityTitles
        .trim()
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (titles.length != 289) {
      throw StateError('Phoenix capability catalog must contain 289 items.');
    }
    return List<CapabilitySpec>.unmodifiable([
      for (var index = 0; index < titles.length; index++)
        CapabilitySpec(
          id: 279 + index,
          title: titles[index],
          batch: _batchFor(279 + index),
          batchTitle: _batchTitles[_batchFor(279 + index)]!,
          kind: _kindFor(titles[index]),
        ),
    ]);
  }

  static int _batchFor(int id) => id <= 280 ? 28 : 29 + ((id - 281) ~/ 10);

  static CapabilityKind _kindFor(String title) {
    final value = title.toLowerCase();
    if (_hasAny(value, const [
      'accessibility',
      'large-text',
      'screen-reader',
      'keyboard',
      'motion',
      'color-blind',
      'dyslexia',
      'one-hand',
      'voice-friendly',
      'touch target',
      'rtl',
      'responsive desktop',
      'keyboard shortcut',
    ])) {
      return CapabilityKind.accessibility;
    }
    if (_hasAny(value, const [
      'pin',
      'unlock',
      'privacy',
      'encryption',
      'password',
      'consent',
      'secure',
      'security',
      'retention',
      'permission',
      'network security',
      'backup rules',
    ])) {
      return CapabilityKind.security;
    }
    if (_hasAny(value, const [
      'timer',
      'emom',
      'amrap',
      'tabata',
      'countdown',
    ])) {
      return CapabilityKind.timer;
    }
    if (_hasAny(value, const [
      'import',
      'export',
      'share',
      'snapshot',
      'print',
      'gpx',
      'ics',
      'schema documentation',
      'support bundle',
    ])) {
      return CapabilityKind.importExport;
    }
    if (_hasAny(value, const [
      'education',
      'tutorial',
      'fundamentals',
      'cue library',
      'error library',
      'disclaimer',
      'glossary',
      'faq',
      'guide',
    ])) {
      return CapabilityKind.education;
    }
    if (_hasAny(value, const [
      'audit',
      'score',
      'health check',
      'quality',
      'diagnostic',
      'coverage',
      'budget',
      'checklist',
      'reconciliation',
      'conflict',
      'risk',
      'status',
      'tracing',
      'timing',
      'regression report',
    ])) {
      return CapabilityKind.audit;
    }
    if (_hasAny(value, const [
      'schedule',
      'reminder',
      'sync',
      'retry',
      'queue',
      'update-available',
      'automation',
      'lifecycle',
      'rotation',
      'transactional',
    ])) {
      return CapabilityKind.automation;
    }
    if (_hasAny(value, const [
      'tracker',
      'tracking',
      'log',
      'history',
      'timeline',
      'calendar',
      'check-in',
      'notes',
      'baseline',
      'progress',
      'comparison',
      'metadata',
    ])) {
      return CapabilityKind.tracker;
    }
    return CapabilityKind.planner;
  }

  static bool _hasAny(String value, List<String> terms) =>
      terms.any(value.contains);

  static CapabilityOutcome evaluate({
    required CapabilitySpec spec,
    required FitnessData data,
    required CapabilityState state,
  }) {
    var score = 10 + state.guardLevel ~/ 5;
    if (data.profile != null) score += 12;
    score += data.logs.length.clamp(0, 10) * 2;
    score += data.recoveryChecks.length.clamp(0, 5) * 2;
    score += data.meals.length.clamp(0, 5);
    score += data.wearableSummaries.length.clamp(0, 5) * 2;
    if (state.note.isNotEmpty) score += 5;
    if (state.runCount > 0) score += 8;
    if (spec.kind == CapabilityKind.security && data.preferences.hasVaultPin) {
      score += 12;
    }
    score = score.clamp(0, 100);

    final status = !state.enabled
        ? 'PAUSED LOCALLY'
        : score >= 75
        ? 'READY'
        : score >= 45
        ? 'CONFIGURED'
        : 'NEEDS INPUT';
    final modeText = switch (state.mode) {
      'conservative' => 'conservative safety boundary',
      'progressive' => 'progressive local target',
      _ => 'balanced local target',
    };
    final action = switch (spec.kind) {
      CapabilityKind.security =>
        'Review the private boundary, retain the minimum data, and verify recovery before enabling it.',
      CapabilityKind.importExport =>
        'Generate a local preview, validate it, then explicitly approve the file operation.',
      CapabilityKind.automation =>
        'Confirm timing, quiet hours, and a safe fallback before activating automation.',
      CapabilityKind.audit =>
        'Resolve the lowest-confidence evidence item and run the audit again.',
      CapabilityKind.timer =>
        'Set a bounded duration and a clear stop condition before starting.',
      CapabilityKind.education =>
        'Open the contextual lesson and apply one concrete cue in the next session.',
      CapabilityKind.accessibility =>
        'Verify the control with text scaling, keyboard focus, and spoken semantics.',
      CapabilityKind.tracker =>
        'Record one consistent observation so the next comparison uses real history.',
      CapabilityKind.planner =>
        'Review the generated local plan and explicitly approve it before it changes behavior.',
    };
    return CapabilityOutcome(
      score: score,
      status: status,
      summary:
          '${spec.title} is evaluated on-device with a $modeText and guard level ${state.guardLevel}/100.',
      nextAction: action,
      evidence: [
        '${data.logs.length} workout logs',
        '${data.recoveryChecks.length} recovery check-ins',
        '${data.wearableSummaries.length} wearable days',
        '${state.runCount} local executions',
      ],
    );
  }
}

const Map<int, String> _batchTitles = {
  28: 'Reports Studio',
  29: 'Local Collaboration',
  30: 'Education and Media',
  31: 'Accessibility Plus',
  32: 'Privacy and Security',
  33: 'Import and Export',
  34: 'Integrations Hub',
  35: 'Wearable Intelligence',
  36: 'Gamification',
  37: 'Challenges',
  38: 'Onboarding Plus',
  39: 'Workout Experience',
  40: 'Timer and Audio',
  41: 'Advanced Logging',
  42: 'Planner and Calendar',
  43: 'Injury-Aware Training',
  44: 'Periodization Plus',
  45: 'Performance Testing',
  46: 'Sports Conditioning',
  47: 'Outdoor Training',
  48: 'Travel Training',
  49: 'Adaptive Training',
  50: 'Life-Stage Options',
  51: 'Dashboard Studio',
  52: 'Smart Reminders',
  53: 'Localization',
  54: 'Desktop and PWA',
  55: 'Android Production',
  56: 'Performance',
  57: 'Data Reliability',
};

const String _capabilityTitles = '''
Print-friendly chart themes
Scheduled local report generation
Coach-view export
Read-only athlete snapshot
Session-plan share code
Program import approval
Local feedback notes
Training-partner session
Shared challenge code
Redacted health export
Share-expiration metadata
Collaboration audit trail
Exercise cue library
Common-error library
Breathing cue library
Tempo education cards
RPE and RIR tutorial
Pain-versus-effort education
Warm-up education
Nutrition fundamentals library
Recovery fundamentals library
Contextual education search
Large-text layout audit
Screen-reader landmark audit
Keyboard-only navigation
Reduced-motion mode
Color-blind-safe chart palettes
Dyslexia-friendly typography option
One-hand workout controls
Voice-friendly labels
Adjustable touch targets
Accessibility self-check
Profile-level PINs
Failed-unlock cooldown
Sensitive-screen privacy blur
Backup encryption
Export password protection
Data-retention controls
Privacy activity log
Secure clipboard timeout
Local consent records
Security health dashboard
CSV workout import
Strong-app import mapping
Hevy-style import mapping
Generic nutrition CSV import
GPX route import
ICS training calendar export
JSON schema documentation
Incremental backup
Selective restore
Import conflict preview
Integration status dashboard
Spotify token lifecycle
Calendar connection configuration
Health-data connection configuration
Webhook export configuration
Integration permission scopes
Connection health checks
Integration retry queue
Integration data provenance
Disconnect-and-purge workflow
Daily wearable summary
Steps baseline model
Resting-heart-rate baseline
Sleep-duration baseline
HRV optional baseline
Wearable data-quality score
Missing-data handling
Readiness sensor weighting
Wearable trend alerts
Device-source comparison
Athlete level system
Experience points
Skill-specific XP
Achievement rarity tiers
Personal best badges
Consistency badges
Recovery badges
Nutrition badges
Achievement showcase
Gamification opt-out
Custom personal challenges
Strength challenge templates
Mobility challenge templates
Steps challenge templates
Nutrition consistency challenges
Recovery consistency challenges
Challenge progress calendar
Safe challenge limits
Challenge completion report
Repeatable challenge history
Modular onboarding steps
Goal trade-off explanation
Training-history assessment
Movement-confidence assessment
Schedule reality check
Equipment photo-free checklist
Nutrition preference setup
Reminder preference setup
Privacy setup
Onboarding completion report
Compact active-workout mode
Focus mode
Exercise queue
Set swipe actions
Previous-performance overlay
Inline plate calculator
Inline technique cues
Session progress ring
Estimated finish time
Accidental-exit recovery
Multiple concurrent timers
EMOM timer
AMRAP timer
Tabata timer
Interval timer designer
Set-start countdown
Spoken exercise cues
Audio ducking controls
Silent vibration mode
Timer history
Per-side load logging
Assisted-load logging
Distance-per-set logging
Calories-per-interval logging
Range-of-motion notes
Grip and stance notes
Equipment-instance notes
Set video reference
Intra-set pain marker
Logging completeness score
Month training calendar
Drag-and-drop rescheduling
Recurring workout rules
Planned-versus-completed view
Vacation calendar
Deload calendar
Event countdowns
Schedule conflict alerts
Calendar density modes
Calendar print view
Symptom check-in
Pain trend timeline
Movement-tolerance map
Load modification rules
Range-of-motion modification
Isometric fallback options
Return-to-training stages
Recurrence-risk flags
Professional-care reminder rules
Injury-note export
Linear progression blocks
Undulating progression blocks
Block periodization
Accumulation/intensification/realization
Pivot week
Taper planner
Auto-deload criteria editor
Volume ramp controls
Intensity ramp controls
Phase comparison report
Push-up capacity test
Pull-up capacity test
Squat endurance test
Plank endurance test
Broad-jump test
Vertical-jump test
Cooper test
Step-test recovery
Test battery scheduler
Performance profile radar
Sport-demand profile
Acceleration session builder
Agility session builder
Jump-landing session builder
Change-of-direction load
Sprint exposure tracker
Power-endurance circuits
In-season maintenance mode
Competition-week taper
Sport conditioning report
Outdoor workout mode
Route distance log
Elevation-gain log
Weather note field
Park equipment presets
Hill-session templates
Ruck-training templates
Outdoor safety checklist
Daylight-aware reminder
Outdoor session history
Hotel-room program
No-equipment program
Resistance-band travel plan
Fifteen-minute travel sessions
Jet-lag recovery mode
Travel nutrition checklist
Time-zone schedule shift
Limited-space exercise filter
Travel streak protection
Return-home ramp
Seated exercise filters
Low-impact exercise filters
Balance-support options
Range-limited alternatives
Sensory-friendly session mode
Fatigue-limited session mode
Caregiver-readable workout sheet
Adaptive equipment tags
Functional-goal programs
Adaptive progress metrics
Beginner confidence mode
Teen-safe training guard
Older-adult strength mode
Bone-health exercise tags
Menstrual-cycle optional notes
Pregnancy-mode safety boundary
Postpartum return boundary
Menopause symptom notes
Life-stage privacy controls
Professional-guidance disclaimers
Custom dashboard cards
Card reordering
Compact dashboard density
Goal-specific dashboard presets
Today timeline
Weekly command center
Personal metric pinning
Dashboard quick-entry controls
Dashboard empty states
Dashboard reset and backup
Reminder quiet hours
Reminder snooze
Missed-reminder recovery
Context-aware workout reminders
Hydration reminders
Meal reminders
Mobility-break reminders
Measurement reminders
Reminder delivery history
Reminder fatigue protection
Full German locale
Full Spanish locale
Locale-aware units
Locale-aware dates
Locale-aware decimal input
Translation coverage report
Missing-translation fallback
Exercise alias localization
RTL layout groundwork
Language import/export
Responsive desktop navigation
Keyboard shortcuts
Install-state detection
Offline status indicator
Update-available prompt
Background sync queue
PWA share target
File-handler groundwork
Desktop window-size persistence
Offline cache diagnostics
Android notification channels
Android deep links
Android backup rules
Android network security config
Android release flavors
Android version automation
Android icon and splash audit
Android permission audit
Play Store metadata template
Android pre-release checklist
Startup performance tracing
Lazy page construction
Large-list virtualization audit
Image memory controls
Database query timing
JSON serialization timing
Chart rendering budget
Rebuild-count diagnostics
Web bundle-size budget
Performance regression report
Database checksum metadata
Profile snapshot rotation
Transactional profile switch
Backup verification pass
Corruption quarantine
Migration rollback snapshot
Duplicate-event reconciliation
''';
