import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/rotation_rule.dart';
import 'package:ruta_placa/models/schedule_type.dart';
import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RulesService {
  RulesService._();

  static final RulesService instance = RulesService._();

  late SharedPreferences _prefs;

  static const _rulesUrl =
      'https://raw.githubusercontent.com/pablo-briceno-dev/ruta-placa-app-data/refs/heads/main/rules.json';

  static const _keyRules = 'rules_path';
  static const _keyLastUpdated = 'rules_last_updated';
  static const _keyVersion = 'rules_version';
  static const _keyLastCheck = 'rules_last_check';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> getPreferences() async =>
      await SharedPreferences.getInstance();

  Future<String> saveRulesToFile(String json) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/rules.json');

    await file.writeAsString(json);

    return file.path;
  }

  Future<String?> readRulesFromFile(String path) async {
    final file = File(path);

    if (!await file.exists()) return null;

    return await file.readAsString();
  }

  // Llamar al iniciar la app
  Future<List<CityRule>> loadRules({
    void Function(double progress)? onProgress,
  }) async {
    final lastCheck = _prefs.getInt(_keyLastCheck);
    final shouldFetch = _shouldFetchFromNetwork(lastCheck);

    if (shouldFetch) {
      try {
        final fresh = await _fetchFromNetwork(onProgress: onProgress);
        if (fresh != null) return fresh;
      } catch (_) {
        // Sin internet → usar caché
      }
    }

    final path = _prefs.getString(_keyRules);
    if (path == null) return _fallbackRules();
    final content = await readRulesFromFile(path);

    return _loadFromCache(content);
  }

  // ¿Hay que ir a la red?
  // Solo si pasaron más de 24 horas desde la última descarga
  bool _shouldFetchFromNetwork(int? lastCheck) {
    if (lastCheck == null) return true;

    final diff = DateTime.now().millisecondsSinceEpoch - lastCheck;

    return diff > const Duration(hours: 12).inMilliseconds;
  }

  Future<List<CityRule>?> _fetchFromNetwork({
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(_rulesUrl));
    final response = await request.send();

    final total = response.contentLength ?? 0;
    int received = 0;

    final bytes = <int>[];

    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
      received += chunk.length;

      if (total != 0) {
        final progress = received / total;
        onProgress?.call(progress);
      }
    }

    final body = utf8.decode(bytes);

    final json = jsonDecode(body) as Map<String, dynamic>;

    final newVersion = json['version'] as String;
    final newLastUpdatedStr = json['lastUpdated'] as String;
    final newLastUpdated = DateTime.parse(newLastUpdatedStr);

    final cachedVersion = _prefs.getString(_keyVersion);
    final cachedLastUpdatedStr = _prefs.getString(_keyLastUpdated);
    final cachedLastUpdated = cachedLastUpdatedStr != null
        ? DateTime.tryParse(cachedLastUpdatedStr)
        : null;

    // Guardar siempre el timestamp de la última consulta
    await _prefs.setInt(_keyLastCheck, DateTime.now().millisecondsSinceEpoch);

    final isSameVersion = newVersion == cachedVersion;
    final isSameDate =
        cachedLastUpdated != null && !newLastUpdated.isAfter(cachedLastUpdated);

    // Si la versión no cambió, no hace falta re-parsear
    if (isSameVersion && isSameDate) {
      final path = _prefs.getString(_keyRules);
      if (path == null) return _fallbackRules();

      final content = await readRulesFromFile(path);
      return _loadFromCache(content);
    }

    // Nueva versión → guardar en caché
    final path = await saveRulesToFile(body);

    await _prefs.setString(_keyRules, path);
    await _prefs.setString(_keyVersion, newVersion);
    await _prefs.setString(_keyLastUpdated, newLastUpdatedStr);

    debugPrint(
      'RulesService: reglas actualizadas a $newVersion ($newLastUpdatedStr)',
    );
    return _parseRules(json);
  }

  List<CityRule> _loadFromCache(String? content) {
    if (content == null) return _fallbackRules();

    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      final rules = _parseRules(json);
      return rules;
    } catch (_) {
      return _fallbackRules();
    }
  }

  List<CityRule> _parseRules(Map<String, dynamic> json) {
    final cities = json['cities'] as List<dynamic>;
    return cities
        .map((c) => CityRule.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  // Reglas mínimas hardcodeadas como último recurso
  // (solo Bogotá particulares, para que la app no quede vacía)
  List<CityRule> _fallbackRules() {
    debugPrint('RulesService: usando fallback hardcodeado');
    return [
      CityRule(
        id: 'bogota',
        name: 'Bogotá',
        emoji: '🏙️',
        restrictions: {
          VehicleType.particular: VehicleRestriction(
            scheduleType: ScheduleType.rotatingWeekly,
            schedule: {},
            rotation: RotationRule(
              cycleStartDate: DateTime(2026, DateTime.january, 5),
              cycleLength: 5,
              weekdaysApply: [1, 3],
              rotationCycle: [
                [1, 2],
                [3, 4],
                [5, 6],
                [7, 8],
                [9, 0],
              ],
            ),
            morningStart: const TimeOfDay(hour: 6, minute: 0),
            morningEnd: const TimeOfDay(hour: 20, minute: 0),
          ),
        },
      ),
    ];
  }

  // Forzar actualización (botón "Actualizar" en Settings)
  Future<List<CityRule>> forceRefresh({
    void Function(double progress)? onProgress,
  }) async {
    await _prefs.remove(_keyLastCheck);
    await _prefs.remove(_keyVersion);
    await _prefs.remove(_keyLastUpdated);
    return loadRules(onProgress: onProgress);
  }

  String? get cachedVersion => _prefs.getString(_keyVersion);

  Future<bool> hasNewVersion() async {
    try {
      final response = await http
          .get(Uri.parse(_rulesUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return false;

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final newVersion = json['version'] as String;
      final cachedVersion = _prefs.getString(_keyVersion);

      return newVersion != cachedVersion;
    } catch (_) {
      return false;
    }
  }
}
