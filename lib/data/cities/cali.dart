import 'package:flutter/material.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

final caliRule = CityRule(
  id: 'cali',
  name: 'Cali',
  emoji: '🌺',
  restrictions: {
    VehicleType.particular: VehicleRestriction(
      schedule: {
        1: [3, 4],
        2: [5, 6],
        3: [7, 8],
        4: [9, 0],
        5: [1, 2],
      },
      morningStart: TimeOfDay(hour: 7, minute: 0),
      morningEnd: TimeOfDay(hour: 9, minute: 0),
      afternoonStart: TimeOfDay(hour: 17, minute: 30),
      afternoonEnd: TimeOfDay(hour: 19, minute: 30),
    ),

    VehicleType.taxi: VehicleRestriction(
      schedule: {
        1: [5, 6],
        2: [7, 8],
        3: [9, 0],
        4: [1, 2],
        5: [3, 4],
      },
      morningStart: TimeOfDay(hour: 6, minute: 0),
      morningEnd: TimeOfDay(hour: 9, minute: 0),
      afternoonStart: TimeOfDay(hour: 15, minute: 0),
      afternoonEnd: TimeOfDay(hour: 21, minute: 0),
      note: 'Dígitos distintos a los particulares',
    ),

    VehicleType.moto: VehicleRestriction(
      schedule: {
        1: [1, 2],
        2: [3, 4],
        3: [5, 6],
        4: [7, 8],
        5: [9, 0],
      },
      morningStart: TimeOfDay(hour: 7, minute: 0),
      morningEnd: TimeOfDay(hour: 9, minute: 0),
      afternoonStart: TimeOfDay(hour: 17, minute: 0),
      afternoonEnd: TimeOfDay(hour: 19, minute: 0),
      note: 'Aplica en vías principales',
    ),
  },
);
