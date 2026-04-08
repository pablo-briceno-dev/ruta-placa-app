import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:ruta_placa/models/city_rule.dart';
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
  Future<List<CityRule>> loadRules() async {
    final lastCheck = _prefs.getInt(_keyLastCheck);
    final shouldFetch = _shouldFetchFromNetwork(lastCheck);

    if (shouldFetch) {
      try {
        final fresh = await _fetchFromNetwork();
        if (fresh != null) return fresh;
      } catch (_) {
        // Sin internet → usar caché
      }
    }

    final path = _prefs.getString('rules_path');
    if (path == null) return _fallbackRules();
    final content = await readRulesFromFile(path);

    return _loadFromCache(content);
  }

  // ¿Hay que ir a la red?
  // Solo si pasaron más de 24 horas desde la última descarga
  bool _shouldFetchFromNetwork(int? lastCheck) {
    if (lastCheck == null) return true;

    final diff = DateTime.now().millisecondsSinceEpoch - lastCheck;
    return diff > const Duration(hours: 24).inMilliseconds;
  }

  Future<List<CityRule>?> _fetchFromNetwork() async {
    final response = await http
        .get(Uri.parse(_rulesUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final newVersion = json['version'] as String;
    final cachedVersion = _prefs.getString(_keyVersion);

    // Guardar siempre el timestamp de la última consulta
    await _prefs.setInt(_keyLastCheck, DateTime.now().millisecondsSinceEpoch);

    // Si la versión no cambió, no hace falta re-parsear
    if (newVersion == cachedVersion) {
      final path = _prefs.getString('rules_path');
      if (path == null) return _fallbackRules();
      final content = await readRulesFromFile(path);

      return _loadFromCache(content);
    }

    // Nueva versión → guardar en caché
    final path = await saveRulesToFile(response.body);
    await _prefs.setString(_keyRules, path);
    await _prefs.setString(_keyVersion, newVersion);

    debugPrint('RulesService: reglas actualizadas a $newVersion');
    return _parseRules(json);
  }

  List<CityRule> _loadFromCache(String? content) {
    if (content == null) return _fallbackRules();

    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      return _parseRules(json);
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
            schedule: {
              1: [9, 0],
              2: [1, 2],
              3: [3, 4],
              4: [5, 6],
              5: [7, 8],
            },
            morningStart: const TimeOfDay(hour: 6, minute: 0),
            morningEnd: const TimeOfDay(hour: 20, minute: 0),
          ),
        },
      ),
    ];
  }

  // Forzar actualización (botón "Actualizar" en Settings)
  Future<List<CityRule>> forceRefresh() async {
    await _prefs.remove(_keyLastCheck);
    return loadRules();
  }

  String? get cachedVersion => _prefs.getString(_keyVersion);
}
