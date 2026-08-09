import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'advanced_analytics_engine.dart';
import 'models/fitness_models.dart';

class CoachingReportEngine {
  static Future<Uint8List> buildCoachingReport(
    FitnessData data, {
    DateTime? generatedAt,
  }) async {
    final now = generatedAt ?? DateTime.now();
    final document = pw.Document(
      title: 'Phoenix Coaching Report',
      author: 'Phoenix Local Coach',
    );
    final logs = data.logs.take(12).toList();
    final profile = data.profile;
    final currentWeight = data.weights.isEmpty
        ? profile?.weightKilograms
        : data.weights.first.kilograms;
    final workload = AdvancedAnalyticsEngine.workloadRatio(
      logs: data.logs,
      now: now,
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(34),
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'PHOENIX // COACHING REPORT',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
            pw.Text(_date(now), style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber}/${context.pagesCount} | generated locally',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ),
        build: (_) => [
          pw.SizedBox(height: 16),
          _title('Athlete snapshot'),
          _metrics([
            ['Goal', _safe(profile?.goal ?? 'Not configured')],
            ['Training days', '${profile?.daysPerWeek ?? 0} / week'],
            ['Body weight', '${currentWeight?.toStringAsFixed(1) ?? '-'} kg'],
            ['Completed sessions', '${data.logs.length}'],
          ]),
          pw.SizedBox(height: 18),
          _title('Workload and recovery guardrails'),
          pw.Text(
            'Acute/chronic workload ratio: ${workload.ratio.toStringAsFixed(2)}. '
            '${_safe(workload.label)}. This is a coaching signal, not a medical diagnosis.',
          ),
          pw.SizedBox(height: 18),
          _title('Recent sessions'),
          if (logs.isEmpty)
            pw.Text('No completed sessions yet.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Date', 'Session', 'Min', 'Sets', 'RPE'],
              data: [
                for (final log in logs)
                  [
                    _date(log.completedAt),
                    _safe(log.templateName),
                    '${log.minutes}',
                    '${log.sets.length}',
                    log.sessionRpe == 0 ? '-' : '${log.sessionRpe}',
                  ],
              ],
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey900,
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.all(5),
            ),
          pw.SizedBox(height: 18),
          _title('Coach actions'),
          pw.Text(
            '- ${workload.ratio > 1.5 ? 'Reduce non-essential volume and prioritize recovery.' : 'Keep progression conservative and technique-led.'}',
          ),
          pw.Text(
            '- ${data.recoveryChecks.isEmpty ? 'Add recovery check-ins to personalize readiness decisions.' : 'Continue daily sleep, stress and soreness check-ins.'}',
          ),
          pw.Text(
            '- Stop any set when technique changes or pain appears. '
            'Seek a qualified professional for persistent pain.',
          ),
        ],
      ),
    );
    return document.save();
  }

  static Future<Uint8List> buildWorkoutSheet(WorkoutTemplate template) async {
    final document = pw.Document(
      title: 'Phoenix Workout Sheet - ${_safe(template.name)}',
      author: 'Phoenix',
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            'PHOENIX // WORKOUT SHEET',
            style: pw.TextStyle(
              color: PdfColors.blue700,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            _safe(template.name),
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(_safe(template.coachingCue)),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Exercise',
              'Prescription',
              'Load',
              'Reps/time',
              'RIR',
              'Notes',
            ],
            data: [
              for (final exercise in template.exercises)
                [
                  _safe(exercise),
                  _safe(template.prescriptionFor(exercise).summary),
                  '______',
                  '______',
                  '____',
                  '________________',
                ],
            ],
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey900,
            ),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding: const pw.EdgeInsets.all(6),
          ),
          pw.SizedBox(height: 22),
          pw.Text(
            'SESSION REVIEW',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Duration: ______ min    Session RPE: ______ / 10'),
          pw.SizedBox(height: 8),
          pw.Text(
            'Technique notes: ______________________________________________',
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Pain or limitation: ____________________________________________',
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Safety: use a controlled range of motion and stop if pain or technique breakdown appears.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _title(String value) => pw.Text(
    value.toUpperCase(),
    style: pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue700,
    ),
  );

  static pw.Widget _metrics(List<List<String>> rows) => pw.Container(
    margin: const pw.EdgeInsets.only(top: 7),
    child: pw.TableHelper.fromTextArray(
      data: rows,
      headerCount: 0,
      cellPadding: const pw.EdgeInsets.all(6),
      cellStyle: const pw.TextStyle(fontSize: 9),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
    ),
  );

  static String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static String _safe(String value) {
    const replacements = <String, String>{
      'Α': 'A',
      'Ά': 'A',
      'Β': 'V',
      'Γ': 'G',
      'Δ': 'D',
      'Ε': 'E',
      'Έ': 'E',
      'Ζ': 'Z',
      'Η': 'I',
      'Ή': 'I',
      'Θ': 'Th',
      'Ι': 'I',
      'Ί': 'I',
      'Ϊ': 'I',
      'Κ': 'K',
      'Λ': 'L',
      'Μ': 'M',
      'Ν': 'N',
      'Ξ': 'X',
      'Ο': 'O',
      'Ό': 'O',
      'Π': 'P',
      'Ρ': 'R',
      'Σ': 'S',
      'Τ': 'T',
      'Υ': 'Y',
      'Ύ': 'Y',
      'Ϋ': 'Y',
      'Φ': 'F',
      'Χ': 'Ch',
      'Ψ': 'Ps',
      'Ω': 'O',
      'Ώ': 'O',
      'α': 'a',
      'ά': 'a',
      'β': 'v',
      'γ': 'g',
      'δ': 'd',
      'ε': 'e',
      'έ': 'e',
      'ζ': 'z',
      'η': 'i',
      'ή': 'i',
      'θ': 'th',
      'ι': 'i',
      'ί': 'i',
      'ϊ': 'i',
      'ΐ': 'i',
      'κ': 'k',
      'λ': 'l',
      'μ': 'm',
      'ν': 'n',
      'ξ': 'x',
      'ο': 'o',
      'ό': 'o',
      'π': 'p',
      'ρ': 'r',
      'σ': 's',
      'ς': 's',
      'τ': 't',
      'υ': 'y',
      'ύ': 'y',
      'ϋ': 'y',
      'ΰ': 'y',
      'φ': 'f',
      'χ': 'ch',
      'ψ': 'ps',
      'ω': 'o',
      'ώ': 'o',
      '×': 'x',
      '•': '|',
      '–': '-',
      '—': '-',
      '′': "'",
      '″': '"',
      '…': '...',
    };
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final replacement = replacements[char];
      if (replacement != null) {
        buffer.write(replacement);
      } else if (rune >= 32 && rune <= 126) {
        buffer.write(char);
      } else {
        buffer.write('?');
      }
    }
    return buffer.toString();
  }
}
