import 'package:flutter/material.dart';
import 'package:ruta_placa/data/holidays_co.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/holiday_behavior.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';
import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

class PicoPlacaCalculator {
  static PicoPlacaResult checkPlate({
    required CityRule cityRule,
    required String plate,
    required VehicleType vehicleType, // ← nuevo parámetro
    required DateTime date,
    TimeOfDay? time,
  }) {
    final restriction = cityRule.restrictionFor(vehicleType);

    if (!restriction.hasRestriction) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: RestrictionReason.noRule,
      );
    }

    final weekday = date.weekday;
    final holiday = isHoliday(date);

    // Delegar el manejo de festivos según la regla
    if (holiday) {
      return _handleHoliday(
        restriction: restriction,
        date: date,
        plate: plate,
        time: time,
      );
    }

    // ── Fin de semana — respetar weekdaysApply ────────
    // Si el día no está en weekdaysApply → sin restricción
    if (!_dayApplies(restriction, weekday)) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: RestrictionReason.weekend,
      );
    }

    // ── Día laboral normal ────────────────────────────
    return _evaluateNormalDay(
      restriction: restriction,
      plate: plate,
      date: date,
      time: time,
      isHoliday: false,
    );
  }

  // Manejo centralizado de festivos
  static PicoPlacaResult _handleHoliday({
    required VehicleRestriction restriction,
    required DateTime date,
    required String plate,
    required TimeOfDay? time,
  }) {
    switch (restriction.holidayBehavior) {
      case HolidayBehavior.noRestriction:
        // La mayoría de ciudades: festivo = libre
        return const PicoPlacaResult(
          hasRestriction: false,
          restrictedPlates: [],
          reason: RestrictionReason.holiday,
        );
      case HolidayBehavior.appliesNormal:
        // Armenia taxis: el festivo avanza el ciclo y aplica normal
        // Solo verificar que el día esté en weekdaysApply
        if (!_dayApplies(restriction, date.weekday)) {
          return const PicoPlacaResult(
            hasRestriction: false,
            restrictedPlates: [],
            reason: RestrictionReason.weekend,
          );
        }
        return _evaluateNormalDay(
          restriction: restriction,
          plate: plate,
          date: date,
          time: time,
          isHoliday: true,
        );
      case HolidayBehavior.appliesToAll:
        // Festivo aplica para todos los dígitos
        return PicoPlacaResult(
          hasRestriction: true,
          restrictedPlates: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          reason: RestrictionReason.holidayAll,
          appliesToAll: true,
        );

      case HolidayBehavior.customBogota:
        return _handleHolidayBogota(
          restriction: restriction,
          date: date,
          plate: plate,
          time: time,
        );
    }
  }

  // ── Lógica especial Bogotá ──────────────────────────────────────────────
  static PicoPlacaResult _handleHolidayBogota({
    required VehicleRestriction restriction,
    required DateTime date,
    required String plate,
    required TimeOfDay? time,
  }) {
    final weekday = date.weekday;

    // Domingo compensatorio: el viernes anterior fue festivo
    if (weekday == DateTime.sunday) {
      final fridayBefore = date.subtract(const Duration(days: 2));
      final fridayWasHoliday = isHoliday(fridayBefore);
      if (fridayWasHoliday) {
        return PicoPlacaResult(
          hasRestriction: true,
          restrictedPlates: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          reason: RestrictionReason.holidaySundayAll,
          appliesToAll: true,
        );
      }
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: RestrictionReason.weekend,
      );
    }

    // Festivo viernes → no aplica (el domingo sí, manejado arriba)
    if (weekday == DateTime.friday) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: RestrictionReason.holiday,
      );
    }

    // Festivo lunes–jueves → aplica para todos
    return PicoPlacaResult(
      hasRestriction: true,
      restrictedPlates: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      reason: RestrictionReason.holidayAll,
      appliesToAll: true,
    );
  }

  // ── Evaluar un día normal (laboral o festivo que aplica normal) ─────────
  static PicoPlacaResult _evaluateNormalDay({
    required VehicleRestriction restriction,
    required String plate,
    required DateTime date,
    required TimeOfDay? time,
    required bool isHoliday,
  }) {
    final result = restriction.platesForDayWithContext(
      date: date,
      isHoliday: isHoliday,
    );

    if (!result.hasRestriction) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: RestrictionReason.normal,
      );
    }

    final lastDigit = _extractLastDigit(plate);
    final inTime = time == null || _isInRestrictionTime(restriction, time);

    return PicoPlacaResult(
      hasRestriction: result.plates.contains(lastDigit) && inTime,
      restrictedPlates: result.plates,
      reason: RestrictionReason.normal,
      appliesToAll: result.appliesToAll,
      note: restriction.note,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Verifica si el día de la semana está en weekdaysApply
  /// Para fixedWeekly usa el mapa schedule directamente
  static bool _dayApplies(VehicleRestriction r, int weekday) {
    if (r.rotation != null) {
      return r.rotation!.weekdaysApply.contains(weekday);
    }
    return r.schedule.containsKey(weekday);
  }

  static int _extractLastDigit(String plate) {
    final clean = plate.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return -1;
    return int.parse(clean[clean.length - 1]);
  }

  static bool _isInRestrictionTime(
    VehicleRestriction restriction,
    TimeOfDay time,
  ) {
    bool inMorning = _timeBetween(
      time,
      restriction.morningStart,
      restriction.morningEnd,
    );
    if (restriction.afternoonStart == null) return inMorning;
    return inMorning ||
        _timeBetween(
          time,
          restriction.afternoonStart!,
          restriction.afternoonEnd!,
        );
  }

  static bool _timeBetween(TimeOfDay t, TimeOfDay start, TimeOfDay end) {
    int toMin(TimeOfDay x) => x.hour * 60 + x.minute;
    return toMin(t) >= toMin(start) && toMin(t) <= toMin(end);
  }
}
