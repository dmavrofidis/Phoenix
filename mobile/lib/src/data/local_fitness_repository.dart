import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fitness_models.dart';

abstract interface class FitnessRepository {
  Future<FitnessData> load();
  Future<void> save(FitnessData data);
}

class LocalFitnessRepository implements FitnessRepository {
  static const _storageKey = 'phoenix.fitness-data.v1';

  @override
  Future<FitnessData> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return FitnessData.initial();
    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      return FitnessData.fromJson(json);
    } on FormatException {
      return FitnessData.initial();
    } on TypeError {
      return FitnessData.initial();
    }
  }

  @override
  Future<void> save(FitnessData data) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(data.toJson()));
  }
}
