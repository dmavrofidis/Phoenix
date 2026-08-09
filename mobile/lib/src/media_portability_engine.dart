import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'models/fitness_models.dart';

class WorkoutShareSummary {
  const WorkoutShareSummary({
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.exerciseLines,
    required this.shareText,
  });

  final String title;
  final String subtitle;
  final List<String> stats;
  final List<String> exerciseLines;
  final String shareText;
}

class SpotifyPkceBundle {
  const SpotifyPkceBundle({required this.verifier, required this.challenge});

  final String verifier;
  final String challenge;
}

class MediaPortabilityEngine {
  static WorkoutShareSummary shareSummary(
    FitnessData data,
    WorkoutTemplate template,
  ) {
    WorkoutLog? latest;
    for (final log in data.logs) {
      if (log.templateName == template.name &&
          (latest == null || log.completedAt.isAfter(latest.completedAt))) {
        latest = log;
      }
    }
    final sets = latest?.sets ?? const <ExerciseSetLog>[];
    final totalVolume = sets.fold<double>(0, (sum, item) => sum + item.volume);
    final exerciseLines = template.exercises.take(6).map((exercise) {
      final exerciseSets = sets
          .where((item) => item.exerciseName == exercise)
          .toList();
      if (exerciseSets.isEmpty) {
        return '$exercise • ${template.prescriptionFor(exercise).summary}';
      }
      final best = exerciseSets.reduce((a, b) {
        final aScore = a.weightKilograms * max(1, a.reps) + a.holdSeconds;
        final bScore = b.weightKilograms * max(1, b.reps) + b.holdSeconds;
        return aScore >= bScore ? a : b;
      });
      final performance = best.holdSeconds > 0
          ? '${best.holdSeconds}s hold'
          : '${best.reps} × ${best.weightKilograms.toStringAsFixed(1)} kg';
      return '$exercise • $performance';
    }).toList();
    final subtitle = latest == null
        ? 'NEXT PHOENIX MISSION'
        : 'COMPLETED ${_date(latest.completedAt)}';
    final stats = latest == null
        ? [
            '${template.exercises.length} exercises',
            '${template.restSeconds}s rest',
            'Technique first',
          ]
        : [
            '${latest.minutes} min',
            '${sets.length} sets',
            '${totalVolume.toStringAsFixed(0)} kg volume',
            if (latest.sessionRpe > 0) 'RPE ${latest.sessionRpe}',
          ];
    final shareText = [
      'PHOENIX // ${template.name}',
      subtitle,
      stats.join(' • '),
      ...exerciseLines,
      'Built locally. Trained deliberately.',
    ].join('\n');
    return WorkoutShareSummary(
      title: template.name,
      subtitle: subtitle,
      stats: stats,
      exerciseLines: exerciseLines,
      shareText: shareText,
    );
  }

  static SpotifyPkceBundle createSpotifyPkce({Random? random}) {
    final generator = random ?? Random.secure();
    final bytes = List<int>.generate(64, (_) => generator.nextInt(256));
    final verifier = base64Url.encode(bytes).replaceAll('=', '');
    final challenge = base64Url
        .encode(sha256.convert(utf8.encode(verifier)).bytes)
        .replaceAll('=', '');
    return SpotifyPkceBundle(verifier: verifier, challenge: challenge);
  }

  static Uri spotifyAuthorizeUri(SpotifyAuthConfig config) {
    if (!config.isConfigured) {
      throw const FormatException('Το Spotify OAuth δεν έχει ρυθμιστεί.');
    }
    return Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': config.clientId,
      'response_type': 'code',
      'redirect_uri': config.redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': config.pkceChallenge,
      'scope':
          'playlist-read-private playlist-read-collaborative user-read-private',
      'show_dialog': 'true',
    });
  }

  static List<String> qrFrames(String backup, {int payloadSize = 900}) {
    if (payloadSize < 200 || payloadSize > 1600) {
      throw const FormatException('Μη ασφαλές μέγεθος QR frame.');
    }
    final encoded = base64Url.encode(utf8.encode(backup)).replaceAll('=', '');
    final checksum = sha256
        .convert(utf8.encode(backup))
        .toString()
        .substring(0, 12);
    final total = (encoded.length / payloadSize).ceil();
    return [
      for (var index = 0; index < total; index++)
        'PHX1:${index + 1}:$total:$checksum:'
            '${encoded.substring(index * payloadSize, min(encoded.length, (index + 1) * payloadSize))}',
    ];
  }

  static String assembleQrFrames(Iterable<String> frames) {
    final parsed = <int, String>{};
    int? total;
    String? checksum;
    for (final raw in frames) {
      final frame = raw.trim();
      if (frame.isEmpty) continue;
      final parts = frame.split(':');
      if (parts.length != 5 || parts.first != 'PHX1') {
        throw const FormatException('Άγνωστο Phoenix QR frame.');
      }
      final index = int.tryParse(parts[1]);
      final frameTotal = int.tryParse(parts[2]);
      if (index == null ||
          frameTotal == null ||
          index < 1 ||
          index > frameTotal) {
        throw const FormatException('Κατεστραμμένη αρίθμηση QR frame.');
      }
      total ??= frameTotal;
      checksum ??= parts[3];
      if (total != frameTotal || checksum != parts[3]) {
        throw const FormatException('Τα QR frames ανήκουν σε άλλο backup.');
      }
      parsed[index] = parts[4];
    }
    if (total == null || parsed.length != total) {
      throw FormatException(
        'Λείπουν QR frames: ${parsed.length}/${total ?? 0}.',
      );
    }
    final encoded = [
      for (var index = 1; index <= total; index++) parsed[index]!,
    ].join();
    final normalized = base64Url.normalize(encoded);
    final backup = utf8.decode(base64Url.decode(normalized));
    final actual = sha256
        .convert(utf8.encode(backup))
        .toString()
        .substring(0, 12);
    if (actual != checksum) {
      throw const FormatException(
        'Το QR backup απέτυχε στον έλεγχο ακεραιότητας.',
      );
    }
    return backup;
  }

  static List<WearableDailySummary> parseWearable(
    String content, {
    String source = 'wearable-import',
  }) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Το wearable αρχείο είναι κενό.');
    }
    final rows = <Map<String, dynamic>>[];
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      final decoded = jsonDecode(trimmed);
      final dynamic list = decoded is List
          ? decoded
          : decoded is Map<String, dynamic>
          ? decoded['data'] ??
                decoded['samples'] ??
                decoded['records'] ??
                decoded['daily']
          : null;
      if (list is! List) {
        throw const FormatException(
          'Το JSON χρειάζεται λίστα data/samples/records/daily.',
        );
      }
      for (final item in list) {
        if (item is Map<String, dynamic>) rows.add(item);
      }
    } else {
      final lines = const LineSplitter()
          .convert(trimmed)
          .where((line) => line.trim().isNotEmpty)
          .toList();
      if (lines.length < 2) {
        throw const FormatException('Το CSV δεν περιέχει εγγραφές.');
      }
      final headers = _splitCsv(
        lines.first,
      ).map((item) => item.trim()).toList();
      for (final line in lines.skip(1)) {
        final values = _splitCsv(line);
        rows.add({
          for (
            var index = 0;
            index < min(headers.length, values.length);
            index++
          )
            headers[index]: values[index].trim(),
        });
      }
    }

    final summaries = <String, WearableDailySummary>{};
    for (final row in rows) {
      final normalized = {
        for (final entry in row.entries)
          entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''):
              entry.value,
      };
      final rawDay =
          normalized['date'] ??
          normalized['day'] ??
          normalized['timestamp'] ??
          normalized['startdate'] ??
          normalized['starttime'];
      final day = DateTime.tryParse(rawDay?.toString() ?? '');
      if (day == null) continue;
      final steps = _number(
        normalized['steps'] ?? normalized['stepcount'],
      ).round();
      final rhr = _number(
        normalized['restingheartrate'] ?? normalized['rhr'],
      ).round();
      var sleepMinutes = _number(normalized['sleepminutes']).round();
      if (sleepMinutes == 0) {
        sleepMinutes = (_number(normalized['sleephours']) * 60).round();
      }
      final key = _date(day);
      summaries[key] = WearableDailySummary(
        id: 'wearable-${source.replaceAll(RegExp(r'[^A-Za-z0-9]'), '-')}-$key',
        day: DateTime(day.year, day.month, day.day),
        source: source,
        steps: steps,
        restingHeartRate: rhr,
        sleepMinutes: sleepMinutes,
      );
    }
    if (summaries.isEmpty) {
      throw const FormatException(
        'Δεν βρέθηκαν αναγνωρίσιμες ημερομηνίες wearable.',
      );
    }
    return summaries.values.toList()..sort((a, b) => b.day.compareTo(a.day));
  }

  static List<String> _splitCsv(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var quoted = false;
    for (var index = 0; index < line.length; index++) {
      final char = line[index];
      if (char == '"') {
        if (quoted && index + 1 < line.length && line[index + 1] == '"') {
          buffer.write('"');
          index++;
        } else {
          quoted = !quoted;
        }
      } else if (char == ',' && !quoted) {
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    values.add(buffer.toString());
    return values;
  }

  static double _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
