import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

  static const _keyRulesPath = 'rules_path';
  static const _keyLastUpdated = 'rules_last_updated';
  static const _keyVersion = 'rules_version';
  static const _keyLastCheck = 'rules_last_check';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Caché --------------------------------------------
  Future<bool> hasCachedRules() async {
    final path = _prefs.getString(_keyRulesPath);
    if (path == null) return false;
    return File(path).exists();
  }

  bool hasCachedRulesSync() {
    final path = _prefs.getString(_keyRulesPath);
    if (path == null) return false;
    return File(path).existsSync();
  }

  // Cargar solo desde caché sin intentar la red
  Future<List<CityRule>> loadFromCacheOnly() async {
    final path = _prefs.getString(_keyRulesPath);
    final content = path != null ? await _readFile(path) : null;
    return _loadFromCache(content);
  }

  // Archivo local --------------------------------------
  Future<String> _saveToFile(String json) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/rules.json');
    await file.writeAsString(json);
    return file.path;
  }

  Future<String?> _readFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  // Llamar al iniciar la app
  Future<List<CityRule>> loadRules({
    VoidCallback? onDownloadStart,
    VoidCallback? onDownloadComplete,
    VoidCallback? onUsingCache,
    void Function(double)? onProgress,
  }) async {
    final lastCheck = _prefs.getInt(_keyLastCheck);
    final shouldFetch = _shouldFetch(lastCheck);

    if (shouldFetch) {
      try {
        onDownloadStart?.call();
        final fresh = await _fetchFromNetwork(onProgress: onProgress);
        if (fresh != null) {
          onDownloadComplete?.call();
          return fresh;
        }
      } catch (_) {
        // Sin internet → caer en caché
      }
    } else {
      onUsingCache?.call();
    }

    final path = _prefs.getString(_keyRulesPath);
    final content = path != null ? await _readFile(path) : null;
    return _loadFromCache(content);
  }

  bool _shouldFetch(int? lastCheck) {
    if (lastCheck == null) return true;
    final diff = DateTime.now().millisecondsSinceEpoch - lastCheck;
    return diff > const Duration(hours: 12).inMilliseconds;
  }

  // Descarga de red ------------------------------------
  Future<List<CityRule>?> _fetchFromNetwork({
    void Function(double)? onProgress,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(_rulesUrl));
      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );

      if (response.statusCode != 200) {
        // Guardar el error para debug
        await _prefs.setString(
          'last_error',
          'HTTP ${response.statusCode} al descargar reglas',
        );
        return null;
      }

      final total = response.contentLength ?? 0;
      int received = 0;
      final bytes = <int>[];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
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

      // Guardar timestamp de última consulta siempre
      await _prefs.setInt(_keyLastCheck, DateTime.now().millisecondsSinceEpoch);

      final isSameVersion = newVersion == cachedVersion;
      final isSameDate =
          cachedLastUpdated != null &&
          !newLastUpdated.isAfter(cachedLastUpdated);

      // Misma versión y misma fecha → usar caché existente
      if (isSameVersion && isSameDate) {
        final path = _prefs.getString(_keyRulesPath);
        final content = path != null ? await _readFile(path) : null;
        return _loadFromCache(content);
      }

      // Nueva versión → guardar archivo y actualizar prefs
      final path = await _saveToFile(body);
      await _prefs.setString(_keyRulesPath, path);
      await _prefs.setString(_keyVersion, newVersion);
      await _prefs.setString(_keyLastUpdated, newLastUpdatedStr);

      debugPrint(
        'RulesService: actualizado a $newVersion ($newLastUpdatedStr)',
      );
      return _parseRules(json);
    } catch (e) {
      // ✅ Guardar el error en prefs para poder leerlo
      await _prefs.setString('last_error', e.toString());
      rethrow;
    }
  }

  // Parseo ----------------------------------------------
  List<CityRule> _loadFromCache(String? content) {
    if (content == null) return _fallbackRules();
    try {
      return _parseRules(jsonDecode(content) as Map<String, dynamic>);
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

  // ── Fallback ───────────────────────────────────────────

  List<CityRule> _fallbackRules() {
    debugPrint('RulesService: usando fallback hardcodeado');
    return [
      CityRule(
        id: 'pasto',
        name: 'Pasto',
        emoji: '🏙️',
        restrictions: {
          VehicleType.particular: VehicleRestriction(
            scheduleType: ScheduleType.rotatingWeeklyDaily,
            schedule: {},
            rotation: RotationRule(
              cycleStartDate: DateTime(2026, DateTime.april, 6),
              cycleLength: 5,
              weekdaysApply: [1, 2, 3, 4, 5],
              rotationCycle: [
                [0, 1],
                [2, 3],
                [4, 5],
                [6, 7],
                [8, 9],
              ],
            ),
            morningStart: const TimeOfDay(hour: 7, minute: 30),
            morningEnd: const TimeOfDay(hour: 19, minute: 0),
          ),
        },
      ),
    ];
  }

  // ── Utilidades públicas ────────────────────────────────

  Future<List<CityRule>> forceRefresh({
    void Function(double)? onProgress,
  }) async {
    await _prefs.remove(_keyLastCheck);
    await _prefs.remove(_keyVersion);
    await _prefs.remove(_keyLastUpdated);
    return loadRules(onProgress: onProgress);
  }

  Future<bool> hasNewVersion() async {
    try {
      final response = await http
          .get(Uri.parse(_rulesUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return false;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final newVersion = json['version'] as String;
      return newVersion != _prefs.getString(_keyVersion);
    } catch (_) {
      return false;
    }
  }

  String? get cachedVersion => _prefs.getString(_keyVersion);

  String? get cachedLastCheck {
    final ms = _prefs.getInt(_keyLastCheck);
    if (ms == null) return null;
    final date = DateTime.fromMillisecondsSinceEpoch(ms);
    final formatter = DateFormat("MMMM d 'del' yyyy", 'es');
    final formatted = formatter.format(date);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  // En RulesService agregar getter
  String? get lastError => _prefs.getString('last_error');
}
