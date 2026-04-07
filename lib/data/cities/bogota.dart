import 'package:flutter/material.dart';
import 'package:ruta_placa/models/city_rule.dart';

final bogotaRule = CityRule(
  id: 'bogota',
  name: 'Bogotá',
  emoji: '🏙️',
  schedule: {
    DateTime.monday: [9, 0],
    DateTime.tuesday: [1, 2],
    DateTime.wednesday: [3, 4],
    DateTime.thursday: [5, 6],
    DateTime.friday: [7, 8],
  },
  morningStart: TimeOfDay(hour: 6, minute: 0),
  morningEnd: TimeOfDay(hour: 20, minute: 0), // horario continuo
  appliesToTaxis: true,
);
