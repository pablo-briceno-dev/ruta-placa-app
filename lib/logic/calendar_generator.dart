import 'package:flutter/material.dart';
import 'package:ruta_placa/data/holidays_co.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

enum DayStatus { free, restricted, holiday, weekend, noData }

class CalendarDay {
  final DateTime date;
  final DayStatus status;
  final List<int> restrictedPlates;

  const CalendarDay({
    required this.date,
    required this.status,
    this.restrictedPlates = const [],
  });
}

class CalendarGenerator {
  // Genera todos los días de un mes con su estado
  static List<CalendarDay> generateMonth({
    required int year,
    required int month,
    required CityRule cityRule,
    required VehicleType vehicleType,
    String? plate, // si se pasa, marca los días que afectan ESA placa
  }) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final result = <CalendarDay>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday >= 6) {
        result.add(CalendarDay(date: date, status: DayStatus.weekend));
        continue;
      }

      if (isHoliday(date)) {
        result.add(CalendarDay(date: date, status: DayStatus.holiday));
        continue;
      }

      final restriction = cityRule.restrictionFor(vehicleType);
      final plates = restriction.platesForDay(date);

      if (plates.isEmpty) {
        result.add(CalendarDay(date: date, status: DayStatus.free));
        continue;
      }

      if (plate != null) {
        final picoResult = PicoPlacaCalculator.checkPlate(
          cityRule: cityRule,
          plate: plate,
          vehicleType: vehicleType,
          date: date,
        );
        result.add(
          CalendarDay(
            date: date,
            status: picoResult.hasRestriction
                ? DayStatus.restricted
                : DayStatus.free,
            restrictedPlates: plates,
          ),
        );
      } else {
        // Sin placa: marcar todos los días con restricción
        result.add(
          CalendarDay(
            date: date,
            status: DayStatus.restricted,
            restrictedPlates: plates,
          ),
        );
      }
    }

    return result;
  }
}
