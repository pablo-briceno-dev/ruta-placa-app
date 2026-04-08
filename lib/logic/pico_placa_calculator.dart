import 'package:flutter/material.dart';
import 'package:ruta_placa/data/holidays_co.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

class PicoPlacaResult {
  final bool hasRestriction;
  final List<int> restrictedPlates;
  final String? reason; // 'festivo', 'fin de semana', 'no aplica'
  final String? note; // nota informativa de la restricción

  const PicoPlacaResult({
    required this.hasRestriction,
    required this.restrictedPlates,
    this.reason,
    this.note,
  });
}

class PicoPlacaCalculator {
  static PicoPlacaResult checkPlate({
    CityRule? cityRule,
    required String plate,
    required VehicleType vehicleType, // ← nuevo parámetro
    required DateTime date,
    TimeOfDay? time,
  }) {
    if (cityRule == null) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: 'ciudad no encontrada',
      );
    }

    // Festivo → sin restricción siempre
    if (isHoliday(date)) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: 'festivo',
      );
    }

    // Fin de semana → sin restricción
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: 'fin de semana',
      );
    }

    // Obtener la restricción específica para este tipo de vehículo
    final restriction = cityRule.restrictionFor(vehicleType);

    // Este tipo no tiene restricción en esta ciudad
    if (!restriction.hasRestriction) {
      return PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: 'no aplica para ${vehicleType.label}',
      );
    }

    final lastDigit = _extractLastDigit(plate);
    final restricted = restriction.platesForDay(date);
    final inTime = time == null || _isInRestrictionTime(restriction, time);
    final plateRestricted = restricted.contains(lastDigit);

    return PicoPlacaResult(
      hasRestriction: plateRestricted && inTime,
      restrictedPlates: restricted,
      note: restriction.note,
    );
  }

  static int _extractLastDigit(String plate) {
    final clean = plate.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return -1;
    return int.parse(clean[clean.length - 1]);
  }

  static bool _isInRestrictionTime(VehicleRestriction r, TimeOfDay time) {
    bool inMorning = _timeBetween(time, r.morningStart, r.morningEnd);
    if (r.afternoonStart == null) return inMorning;
    return inMorning || _timeBetween(time, r.afternoonStart!, r.afternoonEnd!);
  }

  static bool _timeBetween(TimeOfDay t, TimeOfDay start, TimeOfDay end) {
    int toMin(TimeOfDay x) => x.hour * 60 + x.minute;
    return toMin(t) >= toMin(start) && toMin(t) <= toMin(end);
  }
}
