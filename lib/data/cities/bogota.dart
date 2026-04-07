import 'package:flutter/material.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

final bogotaRule = CityRule(
  id: 'bogota',
  name: 'Bogotá',
  emoji: '🏙️',
  restrictions: {
    VehicleType.particular: VehicleRestriction(
      schedule: {
        1: [9, 0], // lunes
        2: [1, 2],
        3: [3, 4],
        4: [5, 6],
        5: [7, 8],
      },
      morningStart: TimeOfDay(hour: 6, minute: 0),
      morningEnd: TimeOfDay(hour: 20, minute: 0),
    ),

    VehicleType.taxi: VehicleRestriction(
      schedule: {
        1: [9, 0],
        2: [1, 2],
        3: [3, 4],
        4: [5, 6],
        5: [7, 8],
      },
      morningStart: TimeOfDay(hour: 5, minute: 30),
      morningEnd: TimeOfDay(hour: 21, minute: 0),
      note: 'Aplica en toda la malla vial',
    ),

    // Motos sin restricción en Bogotá actualmente
    // (cambia según decreto vigente)
    VehicleType.moto: VehicleRestriction.none,

    VehicleType.camion: VehicleRestriction(
      schedule: {
        1: [1, 2, 3, 4, 5, 6, 7, 8, 9, 0], // todos los dígitos
        2: [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
        3: [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
        4: [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
        5: [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
      },
      morningStart: TimeOfDay(hour: 6, minute: 0),
      morningEnd: TimeOfDay(hour: 9, minute: 0),
      afternoonStart: TimeOfDay(hour: 17, minute: 0),
      afternoonEnd: TimeOfDay(hour: 20, minute: 0),
      note: 'Vehículos de carga pesada',
    ),
  },
);
