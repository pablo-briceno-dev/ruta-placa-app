import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ruta_placa/core/utils/time_format_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool notificationsEnabled;
  final bool dayBeforeEnabled;
  final int dayBeforeHour;
  final int dayBeforeMinute;
  final bool sameDayEnabled;
  // IDs de vehículos con notificaciones activas
  // null = todos activos
  final Set<int> disabledVehicleIds;

  const NotificationSettings({
    this.notificationsEnabled = false,
    this.dayBeforeEnabled = true,
    this.dayBeforeHour = 20,
    this.dayBeforeMinute = 0,
    this.sameDayEnabled = true,
    this.disabledVehicleIds = const {},
  });

  bool isVehicleEnabled(int id) => !disabledVehicleIds.contains(id);

  NotificationSettings copyWith({
    bool? notificationsEnabled,
    bool? dayBeforeEnabled,
    int? dayBeforeHour,
    int? dayBeforeMinute,
    bool? sameDayEnabled,
    Set<int>? disabledVehicleIds,
  }) => NotificationSettings(
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    dayBeforeEnabled: dayBeforeEnabled ?? this.dayBeforeEnabled,
    dayBeforeHour: dayBeforeHour ?? this.dayBeforeHour,
    dayBeforeMinute: dayBeforeMinute ?? this.dayBeforeMinute,
    sameDayEnabled: sameDayEnabled ?? this.sameDayEnabled,
    disabledVehicleIds: disabledVehicleIds ?? this.disabledVehicleIds,
  );

  String dayBeforeTimeFormatted(bool use24h) => formatTimeOfDayRaw(
    TimeOfDay(hour: dayBeforeHour, minute: dayBeforeMinute),
    use24h: use24h,
  );
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((
      ref,
    ) {
      return NotificationSettingsNotifier();
    });

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final vehicleIds =
        p.getStringList('notif_disabled_vehicle_ids')?.map(int.parse).toSet() ??
        {};
    state = NotificationSettings(
      notificationsEnabled: p.getBool('notif_enabled') ?? false,
      dayBeforeEnabled: p.getBool('notif_day_before') ?? true,
      dayBeforeHour: p.getInt('notif_db_hour') ?? 20,
      dayBeforeMinute: p.getInt('notif_db_minute') ?? 0,
      sameDayEnabled: p.getBool('notif_same_day') ?? true,
      disabledVehicleIds: vehicleIds,
    );
    debugPrint('📦 Loaded disabledVehicleIds: $vehicleIds');
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_enabled', state.notificationsEnabled);
    await p.setBool('notif_day_before', state.dayBeforeEnabled);
    await p.setInt('notif_db_hour', state.dayBeforeHour);
    await p.setInt('notif_db_minute', state.dayBeforeMinute);
    await p.setBool('notif_same_day', state.sameDayEnabled);
    await p.setStringList(
      'notif_disabled_vehicle_ids',
      state.disabledVehicleIds.map((e) => e.toString()).toList(),
    );
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _save();
  }

  Future<void> setDayBefore(bool value) async {
    state = state.copyWith(dayBeforeEnabled: value);
    await _save();
  }

  Future<void> setDayBeforeTime(int hour, int minute) async {
    state = state.copyWith(dayBeforeHour: hour, dayBeforeMinute: minute);
    await _save();
  }

  Future<void> setSameDay(bool value) async {
    state = state.copyWith(sameDayEnabled: value);
    await _save();
  }

  Future<void> toggleVehicle(int id, bool enabled) async {
    final ids = Set<int>.from(state.disabledVehicleIds);
    if (!enabled) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    state = state.copyWith(disabledVehicleIds: ids);
    await _save();
  }
}
