import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/providers/settings_provider.dart';
import 'package:ruta_placa/services/city_rules_reader.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  // Pedir permiso de notificaciones
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    return await Permission.notification.isGranted;
  }

  // --- Programar todas las notificaciones -----------------------------------
  // Llamar: al guardar ajustes, al iniciar la app, al agregar vehículo
  Future<void> scheduleAll({
    required List<Vehicle> vehicles,
    required NotificationSettings settings,
    required CityRulesReader rulesReader,
  }) async {
    // cancelar todas las anteriores antes de reprogramar
    await _plugin.cancelAll();

    if (!settings.notificationsEnabled) return;

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestExactAlarmsPermission();
      if (granted != true) {
        debugPrint('Permiso de alarma exacta denegado');
        return;
      }
    }

    for (final vehicle in vehicles) {
      if (!settings.isVehicleEnabled(vehicle.id!)) continue;
      final cityRule = rulesReader.getCity(vehicle.cityId);
      if (cityRule == null) continue;

      final now = DateTime.now();

      // --- nOtificación del día anterior -----------
      if (settings.dayBeforeEnabled) {
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        final result = PicoPlacaCalculator.checkPlate(
          cityRule: cityRule,
          plate: vehicle.plate,
          vehicleType: vehicle.vehicleType,
          date: tomorrow,
        );

        if (result.hasRestriction || result.appliesToAll) {
          final notifTime = DateTime(
            now.year,
            now.month,
            now.day,
            settings.dayBeforeHour,
            settings.dayBeforeMinute,
          );

          if (notifTime.isAfter(now)) {
            await _schedule(
              id: _idForVehicle(vehicle.id!, 0),
              title: 'Pico y Placa mañana - ${vehicle.alias}',
              body: _buildBody(vehicle, result, tomorrow),
              time: notifTime,
            );
          }
        }
      }
      // ── Notificación 1h antes del inicio ─────────────
      if (settings.sameDayEnabled) {
        final today = DateTime(now.year, now.month, now.day);
        final result = PicoPlacaCalculator.checkPlate(
          cityRule: cityRule,
          plate: vehicle.plate,
          vehicleType: vehicle.vehicleType,
          date: today,
        );

        if (result.hasRestriction || result.appliesToAll) {
          final restriction = cityRule.restrictionFor(vehicle.vehicleType);
          final startHour = restriction.morningStart.hour;
          final startMin = restriction.morningStart.minute;

          final notifTime = DateTime(
            now.year,
            now.month,
            now.day,
            startHour,
            startMin,
          ).subtract(const Duration(hours: 1));

          if (notifTime.isAfter(now)) {
            await _schedule(
              id: _idForVehicle(vehicle.id!, 1),
              title: 'Pico y placa en 1 hora — ${vehicle.alias}',
              body: _buildBody(vehicle, result, today),
              time: notifTime,
            );
          }
        }
      }
    }
  }

  String _buildBody(Vehicle vehicle, dynamic result, DateTime date) {
    final plates = result.appliesToAll
        ? 'todos los dígitos'
        : 'dígitos ${(result.restrictedPlates as List).join(', ')}';
    final dayStr = _isSameDay(date, DateTime.now()) ? 'hoy' : 'mañana';
    return 'Tu placa ${vehicle.plate} tiene restricción $dayStr — $plates';
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Intentar alarma exacta, si falla usar inexacta
    final canExact = Platform.isAndroid
        ? await androidPlugin?.canScheduleExactNotifications() ?? false
        : true;

    await _plugin.zonedSchedule(
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact,
      id: id,
      scheduledDate: tz.TZDateTime.from(time, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pico_placa_channel',
          'Pico y placa',
          channelDescription: 'Alertas de pico y placa',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ID único por vehículo y tipo (0=día anterior, 1=mismo día)
  int _idForVehicle(int vehicleId, int type) => vehicleId * 10 + type;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> sendTestNotification({
    required Vehicle vehicle,
    required CityRule? cityRule,
  }) async {
    // Mostrar inmediatamente sin programar
    await _plugin.show(
      id: 9999, // ID fijo para la notificación de prueba
      title: 'Prueba — ${vehicle.alias}',
      body: cityRule != null
          ? 'Esta es una notificación de prueba para ${vehicle.plate} en ${cityRule.name}'
          : 'Esta es una notificación de prueba para ${vehicle.plate}',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pico_placa_channel',
          'Pico y placa',
          channelDescription: 'Alertas de pico y placa',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
    );
  }
}
