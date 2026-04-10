import 'package:flutter/material.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/rotation_rule.dart';
import 'package:ruta_placa/models/schedule_type.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

final cityRuleUtils = CityRule(
  id: 'default',
  name: 'Ciudad Por Defecto',
  emoji: '🏙️',
  restrictions: {
    VehicleType.particular: VehicleRestriction(
      scheduleType: ScheduleType.rotatingWeeklyDaily,
      schedule: const {},
      rotation: RotationRule(
        cycleStartDate: DateTime(2026, DateTime.march, 6),
        weekdaysApply: const [1, 2, 3, 4, 5],
        rotationCycle: const [
          [0, 1],
          [2, 3],
          [4, 5],
          [6, 7],
          [8, 9],
        ],
        cycleLength: 5,
      ),
      morningStart: const TimeOfDay(hour: 6, minute: 0),
      morningEnd: const TimeOfDay(hour: 20, minute: 0),
    ),
  },
);

final vehicleDefaultUtils = Vehicle(
  plate: '',
  alias: 'Vehiculo',
  cityId: 'default',
);
