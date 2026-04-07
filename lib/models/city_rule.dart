import 'package:flutter/material.dart';

class CityRule {
  final String id;
  final String name;
  final String emoji;
  // weekday (1=lunes…5=viernes) → últimos dígitos restringidos
  final Map<int, List<int>> schedule;
  final TimeOfDay morningStart;
  final TimeOfDay morningEnd;
  final TimeOfDay? afternoonStart; // null si es horario continuo
  final TimeOfDay? afternoonEnd;
  final bool appliesToTaxis;
  final bool appliesToTrucks;

  const CityRule({
    required this.id,
    required this.name,
    required this.emoji,
    required this.schedule,
    required this.morningStart,
    required this.morningEnd,
    this.afternoonStart,
    this.afternoonEnd,
    this.appliesToTaxis = false,
    this.appliesToTrucks = false,
  });

  List<int> platesForDay(DateTime date) => schedule[date.weekday] ?? [];

  bool isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}
