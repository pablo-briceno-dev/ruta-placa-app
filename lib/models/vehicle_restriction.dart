import 'package:flutter/material.dart';
import 'package:ruta_placa/models/rotation_rule.dart';
import 'package:ruta_placa/models/schedule_type.dart';

class VehicleRestriction {
  final ScheduleType scheduleType;
  // Solo para scheduleType = fixedWeekly
  final Map<int, List<int>> schedule;

  // Solo para rotatingWeekly / rotatingDaily
  final RotationRule? rotation;

  final TimeOfDay morningStart;
  final TimeOfDay morningEnd;
  final TimeOfDay? afternoonStart;
  final TimeOfDay? afternoonEnd;

  // Nota informativa para mostrar en UI
  // Ej: "Solo en corredores viales principales"
  final String? note;

  const VehicleRestriction({
    required this.scheduleType,
    required this.schedule,
    required this.morningStart,
    required this.morningEnd,
    this.rotation,
    this.afternoonStart,
    this.afternoonEnd,
    this.note,
  });

  bool get hasRestriction => schedule.isNotEmpty || rotation != null;

  // ---- Metodo principal -----------------------
  // Devuelve los dígitos restringidos para una fecha dada
  List<int> platesForDay(DateTime date) {
    if (!_weekdayApplies(date)) return [];
    switch (scheduleType) {
      case ScheduleType.fixedWeekly:
        return schedule[date.weekday] ?? [];

      case ScheduleType.rotatingWeekly:
        return _rotatingWeeklyPlates(date);

      case ScheduleType.rotatingDaily:
        return _rotatingDailyPlates(date);

      case ScheduleType.rotatingWeeklyDaily:
        return _rotatingWeeklyDailyPlates(date);
    }
  }

  // ----- Rotación semanal -----------------
  // Calcula en qué semana del ciclo cae la fecha
  List<int> _rotatingWeeklyPlates(DateTime date) {
    if (rotation == null) return [];

    // Inicio de la semana (lunes) de cyclesStartDate
    final startMonday = _mondayOf(rotation!.cycleStartDate);
    // Inicio de la semana (lunes) de date
    final dateMonday = _mondayOf(date);

    final weeksDiff = dateMonday.difference(startMonday).inDays ~/ 7;
    if (weeksDiff < 0) return [];

    final cycleIndex = weeksDiff % rotation!.cycleLength;
    return rotation!.rotationCycle[cycleIndex];
  }

  // ------ Rotación diaria -------------------
  // Cuenta solo días laborales desde cycleStartDate
  List<int> _rotatingDailyPlates(DateTime date) {
    if (rotation == null) return [];

    int laboralDays = 0;
    DateTime cursor = rotation!.cycleStartDate;

    // Contar días laborales entre cycleStartDate y date (inclusive)
    while (!_isSameDay(cursor, date)) {
      if (cursor.isAfter(date)) return [];
      if (_weekdayApplies(cursor)) laboralDays++;
      cursor = cursor.add(const Duration(days: 1));
    }

    final cycleIndex = laboralDays % rotation!.cycleLength;
    return rotation!.rotationCycle[cycleIndex];
  }

  List<int> _rotatingWeeklyDailyPlates(DateTime date) {
    if (rotation == null) return [];

    final startMonday = _mondayOf(rotation!.cycleStartDate);
    final dateMonday = _mondayOf(date);
    final weeksDiff = dateMonday.difference(startMonday).inDays ~/ 7;
    if (weeksDiff < 0) return [];

    final daysFromMonday = rotation!.weekdaysApply
        .where((wd) => wd < date.weekday)
        .length;

    // El lunes de la semana N empieza en índice N (no N*5)
    // Dentro de la semana avanza día a día
    final finalIndex =
        (weeksDiff + daysFromMonday) % rotation!.rotationCycle.length;

    return rotation!.rotationCycle[finalIndex];
  }

  bool _weekdayApplies(DateTime date) {
    switch (scheduleType) {
      case ScheduleType.fixedWeekly:
        return schedule.containsKey(date.weekday);
      case ScheduleType.rotatingWeekly:
      case ScheduleType.rotatingDaily:
      case ScheduleType.rotatingWeeklyDaily:
        // Para rotación: aplica si el weekday está en weekdaysApply
        if (rotation == null) return false;
        return rotation!.weekdaysApply.contains(date.weekday);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _mondayOf(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // --- fromJson ------------------------
  factory VehicleRestriction.fromJson(Map<String, dynamic> json) {
    final typeStr = json['scheduleType'] as String;
    final type = switch (typeStr) {
      'fixed_weekly' => ScheduleType.fixedWeekly,
      'rotating_weekly' => ScheduleType.rotatingWeekly,
      'rotating_daily' => ScheduleType.rotatingDaily,
      'rotating_weekly_daily' => ScheduleType.rotatingWeeklyDaily,
      _ => ScheduleType.fixedWeekly,
    };

    Map<int, List<int>> schedule = {};
    if (type == ScheduleType.fixedWeekly) {
      final raw = json['schedule'] as Map<String, dynamic>? ?? {};
      schedule = raw.map(
        (key, value) => MapEntry(int.parse(key), List<int>.from(value as List)),
      );
    }

    RotationRule? rotation;
    if (type != ScheduleType.fixedWeekly && json['rotation'] != null) {
      rotation = RotationRule.fromJson(
        json['rotation'] as Map<String, dynamic>,
      );
    }

    return VehicleRestriction(
      scheduleType: type,
      schedule: schedule,
      rotation: rotation,
      morningStart: _parseTime(json['morningStart']),
      morningEnd: _parseTime(json['morningEnd']),
      afternoonStart: json['afternoonStart'] != null
          ? _parseTime(json['afternoonStart'])
          : null,
      afternoonEnd: json['afternoonEnd'] != null
          ? _parseTime(json['afternoonEnd'])
          : null,
      note: json['note'] as String?,
    );
  }

  // Sin restricción para este tipo de vehículo
  static const none = VehicleRestriction(
    scheduleType: ScheduleType.fixedWeekly,
    schedule: {},
    morningStart: TimeOfDay(hour: 0, minute: 0),
    morningEnd: TimeOfDay(hour: 0, minute: 0),
  );

  // "07:30" → TimeOfDay(hour: 7, minute: 30)
  static TimeOfDay _parseTime(String raw) {
    final parts = raw.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
