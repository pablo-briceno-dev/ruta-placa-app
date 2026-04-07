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

  // Sin restricción para este tipo de vehículo
  static const none = VehicleRestriction(
    schedule: {},
    morningStart: TimeOfDay(hour: 0, minute: 0),
    morningEnd: TimeOfDay(hour: 0, minute: 0),
  );

  bool get hasRestriction => schedule.isNotEmpty;

  List<int> platesForDay(DateTime date) => schedule[date.weekday] ?? [];
}
