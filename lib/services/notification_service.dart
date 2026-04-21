import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/notification_settings_provider.dart';
import 'package:ruta_placa/services/city_rules_reader.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async => await Permission.notification.isGranted;

  Future<void> scheduleAll({
    required List<Vehicle> vehicles,
    required NotificationSettings settings,
    required CityRulesReader rulesReader,
  }) async {
    await _plugin.cancelAll();

    if (!settings.notificationsEnabled) {
      return;
    }

    final now = DateTime.now();
    int scheduled = 0;

    for (final vehicle in vehicles) {
      if (!settings.isVehicleEnabled(vehicle.id!)) {
        _log('   ⏭️ Saltado — vehículo deshabilitado');
        continue;
      }

      final cityRule = rulesReader.getCity(
        settings.cityDefault.isNotEmpty ? settings.cityDefault : vehicle.cityId,
      );

      if (cityRule == null) {
        _log('   ⏭️ Saltado — ciudad no encontrada');
        continue;
      }

      if (settings.dayBeforeEnabled) {
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        final result = PicoPlacaCalculator.checkPlate(
          cityRule: cityRule,
          plate: vehicle.plate,
          vehicleType: vehicle.vehicleType,
          date: tomorrow,
          plateOrigin: vehicle.plateOrigin,
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
              title: 'Pico y Placa mañana — ${vehicle.alias}',
              body: _buildBody(vehicle, result, tomorrow),
              time: notifTime,
            );
            scheduled++;
          } else {
            _log('   ⏭️ Saltado — la hora ya pasó hoy');
          }
        }
      }

      if (settings.sameDayEnabled) {
        final today = DateTime(now.year, now.month, now.day);
        final result = PicoPlacaCalculator.checkPlate(
          cityRule: cityRule,
          plate: vehicle.plate,
          vehicleType: vehicle.vehicleType,
          date: today,
          plateOrigin: vehicle.plateOrigin,
        );

        if (result.hasRestriction || result.appliesToAll) {
          // ✅ Calcular 1 hora antes del morningStart de la restricción
          final restrictionStart = _parseRestrictionStart(
            cityRule,
            vehicle.vehicleType,
            today,
          );

          if (restrictionStart != null) {
            final notifTime = restrictionStart.subtract(
              const Duration(hours: 1),
            );

            if (notifTime.isAfter(now)) {
              await _schedule(
                id: _idForVehicle(vehicle.id!, 1),
                title: 'Pico y Placa hoy — ${vehicle.alias}',
                body: _buildBody(vehicle, result, today),
                time: notifTime,
              );
              scheduled++;
            } else {
              _log('   ⏭️ Saltado — notificación del mismo día ya pasó');
            }
          }
        }
      }
    }

    _log('✅ scheduleAll completado — $scheduled notificaciones programadas');
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

    final canExact = Platform.isAndroid
        ? await androidPlugin?.canScheduleExactNotifications() ?? false
        : true;

    final scheduled = tz.TZDateTime.from(time, tz.local);

    _log('  ➕ Programando #$id "$title" para $scheduled');

    // ✅ title y body ahora se pasan correctamente
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pico_placa_channel',
          'Pico y placa',
          channelDescription: 'Alertas de pico y placa',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_launcher_foreground',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact,
    );
  }

  String _buildBody(Vehicle vehicle, dynamic result, DateTime date) {
    final plates = result.appliesToAll
        ? 'todos los dígitos'
        : 'dígitos ${(result.restrictedPlates as List).join(', ')}';
    final dayStr = _isSameDay(date, DateTime.now()) ? 'hoy' : 'mañana';
    return 'Tu placa ${vehicle.plate} tiene restricción $dayStr — $plates';
  }

  int _idForVehicle(int vehicleId, int type) => vehicleId * 10 + type;
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> sendTestNotification({
    required Vehicle vehicle,
    required CityRule? cityRule,
  }) async {
    await _plugin.show(
      id: 9999,
      title: 'Prueba — ${vehicle.alias}',
      body: cityRule != null
          ? 'Notificación de prueba para ${vehicle.plate} en ${cityRule.name}'
          : 'Notificación de prueba para ${vehicle.plate}',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pico_placa_channel',
          'Pico y placa',
          channelDescription: 'Alertas de pico y placa',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_launcher_foreground',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> fireNow({required int id}) async {
    final pending = await _plugin.pendingNotificationRequests();
    final notif = pending.firstWhere(
      (n) => n.id == id,
      orElse: () => throw Exception('No encontrada'),
    );

    // Mostrar inmediatamente con el mismo contenido
    await _plugin.show(
      id: notif.id,
      title: notif.title,
      body: notif.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pico_placa_channel',
          'Pico y placa',
          channelDescription: 'Alertas de pico y placa',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_launcher_foreground',
        ),
      ),
    );
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint(msg);
  }

  DateTime? _parseRestrictionStart(
    CityRule cityRule,
    VehicleType vehicleType,
    DateTime date,
  ) {
    // Busca la restricción que aplica al tipo de vehículo
    final restriction = cityRule.restrictions[vehicleType];

    final morningStart = restriction!.morningStart; // "06:00"
    final parts = morningStart.toString().split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    // Caso especial: si morningStart es "00:00" (restricción todo el día)
    // notificar a las 07:00 por defecto para no molestar a medianoche
    if (hour == 0 && minute == 0) {
      return DateTime(date.year, date.month, date.day, 7, 0);
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
