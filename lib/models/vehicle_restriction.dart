import 'package:flutter/material.dart';

class VehicleRestriction {
  // weekday (1=lunes…5=viernes) → dígitos restringidos
  // Si el mapa está vacío = no aplica restricción
  final Map<int, List<int>> schedule;

  final TimeOfDay morningStart;
  final TimeOfDay morningEnd;
  final TimeOfDay? afternoonStart;
  final TimeOfDay? afternoonEnd;

  // Nota informativa para mostrar en UI
  // Ej: "Solo en corredores viales principales"
  final String? note;

  const VehicleRestriction({
    required this.schedule,
    required this.morningStart,
    required this.morningEnd,
    this.afternoonStart,
    this.afternoonEnd,
    this.note,
  });

  bool get hasRestriction => schedule.isNotEmpty;
  List<int> platesForDay(DateTime date) => schedule[date.weekday] ?? [];

  // Sin restricción para este tipo de vehículo
  static const none = VehicleRestriction(
    schedule: {},
    morningStart: TimeOfDay(hour: 0, minute: 0),
    morningEnd: TimeOfDay(hour: 0, minute: 0),
  );

  factory VehicleRestriction.fromJson(Map<String, dynamic> json) {
    final rawSchedule = json['schedule'] as Map<String, dynamic>;
    final schedule = rawSchedule.map(
      (key, value) => MapEntry(int.parse(key), List<int>.from(value as List)),
    );

    return VehicleRestriction(
      schedule: schedule,
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

  // "07:30" → TimeOfDay(hour: 7, minute: 30)
  static TimeOfDay _parseTime(String raw) {
    final parts = raw.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Map<String, dynamic> toJson() => {
    'schedule': schedule.map((key, value) => MapEntry(key.toString(), value)),
    'morningStart': _formatTime(morningStart),
    'morningEnd': _formatTime(morningEnd),
    if (afternoonStart != null) 'afternoonStart': _formatTime(afternoonStart!),
    if (afternoonEnd != null) 'afternoonEnd': _formatTime(afternoonEnd!),
    'note': note,
  };

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
