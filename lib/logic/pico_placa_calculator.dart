import 'package:flutter/material.dart';
import 'package:ruta_placa/data/cities_repository.dart';
import 'package:ruta_placa/data/holidays_co.dart';
import 'package:ruta_placa/models/city_rule.dart';

class PicoPlacaResult {
  final bool hasRestriction;
  final List<int> restictedPlates;
  final String? reason;

  const PicoPlacaResult({
    required this.hasRestriction,
    required this.restictedPlates,
    this.reason,
  });
}

class PicoPlacaCalculator {
  static PicoPlacaResult checkPlate({
    required String cityId,
    required String plate,
    required DateTime date,
    TimeOfDay? time,
  }) {
    final rule = CitiesRepository.getCityRule(cityId);
    if (rule == null)
      return PicoPlacaResult(hasRestriction: false, restictedPlates: []);

    if (isHoliday(date)) {
      return PicoPlacaResult(
        hasRestriction: false,
        restictedPlates: [],
        reason: 'festivo',
      );
    }

    if (rule.isWeekend(date)) {
      return PicoPlacaResult(
        hasRestriction: false,
        restictedPlates: [],
        reason: 'fin de semana',
      );
    }

    final lastDigit = _extractLastDigit(plate);
    if (lastDigit == -1) {
      return PicoPlacaResult(hasRestriction: false, restictedPlates: []);
    }

    final restricted = rule.platesForDay(date);
    bool inTime = time == null || _isInRestrictionTime(rule, time);
    bool plateRestricted = restricted.contains(lastDigit);

    return PicoPlacaResult(
      hasRestriction: plateRestricted && inTime,
      restictedPlates: restricted,
    );
  }

  /// Devuelve todos los dígitos restringidos en una ciudad y fecha
  static List<int> restrictedDigitsForDay(String cityId, DateTime date) {
    final rule = CitiesRepository.getCityRule(cityId);
    if (rule == null || isHoliday(date) || rule.isWeekend(date)) return [];
    return rule.platesForDay(date);
  }

  static int _extractLastDigit(String plate) {
    final clean = plate.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return -1;
    return int.tryParse(clean[clean.length - 1]) ?? -1;
  }

  static bool _isInRestrictionTime(CityRule rule, TimeOfDay time) {
    bool inMorning = _timeBetween(time, rule.morningStart, rule.morningEnd);
    if (rule.afternoonStart == null) return inMorning;
    bool inAfternoon = _timeBetween(
      time,
      rule.afternoonStart!,
      rule.afternoonEnd!,
    );
    return inMorning || inAfternoon;
  }

  static bool _timeBetween(TimeOfDay t, TimeOfDay start, TimeOfDay end) {
    int toMin(TimeOfDay x) => x.hour * 60 + x.minute;
    return toMin(t) >= toMin(start) && toMin(t) <= toMin(end);
  }
}
