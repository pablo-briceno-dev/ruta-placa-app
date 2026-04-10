import 'package:flutter/material.dart';
import 'package:ruta_placa/data/holidays_co.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';
import 'package:ruta_placa/models/plates_result.dart';
import 'package:ruta_placa/models/schedule_type.dart';
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
    final isAlternating =
        restriction.scheduleType == ScheduleType.rotatingAlternating;

    // Domingo ---------------
    if (weekday == DateTime.sunday) {
      if (isAlternating) {
        final fridayOfWeek = date.subtract(const Duration(days: 2));
        final fridayWasHoliday = isHoliday(fridayOfWeek);
        if (fridayWasHoliday) {
          return PicoPlacaResult(
            hasRestriction: true,
            restrictedPlates: PlatesResult.all().plates,
            reason: RestrictionReason.holidaySundayAll,
            appliesToAll: true,
          );
        }
      }

      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: RestrictionReason.weekend,
      );
    }

    // -- Sabado ----------------
    if (weekday == DateTime.saturday) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: RestrictionReason.weekend,
      );
    }

    // Festivo viernes (solo alternating)
    if (holiday && weekday == DateTime.friday && isAlternating) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: RestrictionReason.holidayFriday,
      );
    }

    // Festivo lunes-jueves (solo alternating)
    if (holiday && isAlternating) {
      return PicoPlacaResult(
        hasRestriction: true,
        restrictedPlates: PlatesResult.all().plates,
        reason: RestrictionReason.holidayAll,
        appliesToAll: true,
      );
    }

    // Festivo en otros scheduleTypes -> sin Restricción
    if (holiday) {
      return const PicoPlacaResult(
        hasRestriction: false,
        restrictedPlates: [],
        reason: RestrictionReason.holidayFriday,
      );
    }

    // Dia laboral normal
    final result = restriction.platesForDayWithContext(
      date: date,
      isHoliday: false,
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
