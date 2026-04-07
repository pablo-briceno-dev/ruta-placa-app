import 'package:flutter/material.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

final medellinRule = CityRule(
  id: 'medellin',
  name: 'Medellín',
  emoji: '🌸',
  restrictions: {
    VehicleType.particular: VehicleRestriction(
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
    ),

    // Taxis sin restricción en Medellín
    VehicleType.taxi: VehicleRestriction.none,

    // Motos sin restricción en Medellín
    VehicleType.moto: VehicleRestriction.none,
  },
);
