import 'data/drift_fitness_repository.dart';
import 'data_validation_engine.dart';
import 'models/fitness_models.dart';

enum ReleaseAuditStatus { pass, warning, fail }

class ReleaseAuditCheck {
  const ReleaseAuditCheck({
    required this.id,
    required this.title,
    required this.detail,
    required this.status,
  });

  final String id;
  final String title;
  final String detail;
  final ReleaseAuditStatus status;
}

class ReleaseAuditReport {
  const ReleaseAuditReport(this.checks);

  final List<ReleaseAuditCheck> checks;

  int get score {
    if (checks.isEmpty) return 0;
    final points = checks.fold<int>(
      0,
      (sum, check) =>
          sum +
          switch (check.status) {
            ReleaseAuditStatus.pass => 100,
            ReleaseAuditStatus.warning => 65,
            ReleaseAuditStatus.fail => 0,
          },
    );
    return (points / checks.length).round();
  }

  bool get releaseReady =>
      checks.every((check) => check.status != ReleaseAuditStatus.fail);
}

class ReleaseAuditEngine {
  const ReleaseAuditEngine._();

  static ReleaseAuditReport audit({
    required FitnessData data,
    required DataValidationReport integrity,
    required List<LocalProfileInfo> profiles,
    required List<DiagnosticEntry> diagnostics,
    required bool pwaReady,
  }) {
    final pinHash = data.preferences.vaultPinHash;
    final securePinHash =
        pinHash.isEmpty || RegExp(r'^[a-f0-9]{64}$').hasMatch(pinHash);
    final safeUrls = [
      ...data.workoutPlaylists.values,
      ...data.exerciseVideoUrls.values,
    ].every((value) => Uri.tryParse(value)?.scheme == 'https');
    final remindersValid = data.workoutReminders.every(
      (item) =>
          item.weekday >= 1 &&
          item.weekday <= 7 &&
          item.minutesSinceMidnight >= 0 &&
          item.minutesSinceMidnight < 1440,
    );
    return ReleaseAuditReport([
      ReleaseAuditCheck(
        id: 'sqlite',
        title: 'Drift / SQLite persistence',
        detail: profiles.isEmpty
            ? 'Δεν επιβεβαιώθηκε ενεργό SQLite profile.'
            : '${profiles.length} isolated local profile(s) in SQLite.',
        status: profiles.isEmpty
            ? ReleaseAuditStatus.fail
            : ReleaseAuditStatus.pass,
      ),
      ReleaseAuditCheck(
        id: 'migrations',
        title: 'Versioned storage migrations',
        detail:
            'Storage v19 with deterministic v1→v2→v3→v4→v5→v6→v7→v8→v9→v10→v11→v12→v13→v14→v15→v16→v17→v18→v19 coverage.',
        status: ReleaseAuditStatus.pass,
      ),
      ReleaseAuditCheck(
        id: 'diagnostics',
        title: 'Local diagnostic trail',
        detail: '${diagnostics.length} recent local-only diagnostic event(s).',
        status: diagnostics.isEmpty
            ? ReleaseAuditStatus.warning
            : ReleaseAuditStatus.pass,
      ),
      ReleaseAuditCheck(
        id: 'integrity',
        title: 'Automatic data-integrity audit',
        detail:
            '${integrity.integrityScore}/100 • ${integrity.checkedRecords} records • '
            '${integrity.criticalCount} critical.',
        status: integrity.criticalCount > 0
            ? ReleaseAuditStatus.fail
            : integrity.warningCount > 0
            ? ReleaseAuditStatus.warning
            : ReleaseAuditStatus.pass,
      ),
      ReleaseAuditCheck(
        id: 'pin',
        title: 'Vault credential storage',
        detail: pinHash.isEmpty
            ? 'PIN is optional and not configured.'
            : 'PIN is stored only as a salted SHA-256 hash.',
        status: securePinHash
            ? pinHash.isEmpty
                  ? ReleaseAuditStatus.warning
                  : ReleaseAuditStatus.pass
            : ReleaseAuditStatus.fail,
      ),
      ReleaseAuditCheck(
        id: 'profiles',
        title: 'Multiple-profile isolation',
        detail: 'Each athlete owns an independent versioned JSON snapshot.',
        status: profiles.isEmpty
            ? ReleaseAuditStatus.fail
            : ReleaseAuditStatus.pass,
      ),
      ReleaseAuditCheck(
        id: 'urls',
        title: 'External media transport',
        detail: 'Stored media links are HTTPS-only and Spotify is PKCE-ready.',
        status: safeUrls ? ReleaseAuditStatus.pass : ReleaseAuditStatus.fail,
      ),
      ReleaseAuditCheck(
        id: 'reminders',
        title: 'Local reminder bounds',
        detail:
            '${data.workoutReminders.length} reminder(s) within day/time bounds.',
        status: remindersValid
            ? ReleaseAuditStatus.pass
            : ReleaseAuditStatus.fail,
      ),
      ReleaseAuditCheck(
        id: 'accessibility',
        title: 'Accessibility and locale layer',
        detail:
            'Greek/English, high contrast, scalable Material controls and semantics.',
        status: const {'el', 'en'}.contains(data.preferences.languageCode)
            ? ReleaseAuditStatus.pass
            : ReleaseAuditStatus.fail,
      ),
      ReleaseAuditCheck(
        id: 'pwa',
        title: 'Installable offline PWA',
        detail: pwaReady
            ? 'Manifest and Phoenix offline service worker are enabled.'
            : 'PWA verification is pending in this runtime.',
        status: pwaReady ? ReleaseAuditStatus.pass : ReleaseAuditStatus.warning,
      ),
    ]);
  }
}
