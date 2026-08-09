import 'dart:convert';

import 'data_validation_engine.dart';
import 'models/fitness_models.dart';
import 'operational_readiness_engine.dart';

/// Runs a small, deterministic benchmark against the athlete's current local
/// data. Results remain in memory and are never uploaded.
class LocalPerformanceProfiler {
  const LocalPerformanceProfiler._();

  static Map<String, double> measure(FitnessData data) {
    late String encoded;
    final serialization = _elapsedMilliseconds(() {
      encoded = jsonEncode(data.toJson());
    });
    final deserialization = _elapsedMilliseconds(() {
      FitnessData.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
    });
    final integrity = _elapsedMilliseconds(() {
      DataValidationEngine.audit(data);
    });
    final reconciliation = _elapsedMilliseconds(() {
      OperationalReadinessEngine.reconcileDuplicates(data);
    });
    return {
      'json-serialization-ms': serialization,
      'json-deserialization-ms': deserialization,
      'integrity-audit-ms': integrity,
      'reconciliation-ms': reconciliation,
      'profile-payload-kb': utf8.encode(encoded).length / 1024,
    };
  }

  static double _elapsedMilliseconds(void Function() operation) {
    final timer = Stopwatch()..start();
    operation();
    timer.stop();
    return timer.elapsedMicroseconds / 1000;
  }
}
