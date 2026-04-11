import 'package:flutter/material.dart';
import 'package:ruta_placa/core/utils/list_utils.dart';
import 'package:ruta_placa/data/colors_plates.dart';
import 'package:ruta_placa/data/holidays_co.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

enum DayStatus { free, restricted, holiday, weekend, noData }

class CalendarDay {
  final DateTime date;
  final DayStatus status;
  final Color color;
  final List<int> restrictedPlates;

  const CalendarDay({
    required this.date,
    required this.status,
    this.color = Colors.transparent,
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
    bool isSystemColors = false,
    String? plate, // si se pasa, marca los días que afectan ESA placa
  }) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final result = <CalendarDay>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);

      final restriction = cityRule.restrictionFor(vehicleType);
      final plates = restriction.platesForDay(date);
      final vehiclePlates =
          cityRule.restrictions[VehicleType.particular]?.getPlates() ?? [];
      final indexColor = findIndexList(vehiclePlates, plates);

      if (plate != null && plates.isNotEmpty) {
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
            color: picoResult.hasRestriction
                ? Colors.red
                : isSystemColors &&
                      picoResult.reason != RestrictionReason.holiday
                ? colorsPlates[indexColor]
                : picoResult.reason == RestrictionReason.holiday ||
                      picoResult.reason == RestrictionReason.holiday
                ? holidayColor
                : Colors.green,
          ),
        );
        continue;
      }

      if (date.weekday >= 6) {
        result.add(CalendarDay(date: date, status: DayStatus.weekend));
        continue;
      }

      if (isHoliday(date)) {
        result.add(
          CalendarDay(
            date: date,
            status: DayStatus.holiday,
            color: holidayColor,
          ),
        );
        continue;
      }

      if (plates.isEmpty) {
        result.add(CalendarDay(date: date, status: DayStatus.free));
        continue;
      }

      // Sin placa: marcar todos los días con el sistema de colores
      // o transparente si no se quiere usar el sistema de colores
      if (plate == null) {
        result.add(
          CalendarDay(
            date: date,
            status: DayStatus.free,
            color: isSystemColors
                ? colorsPlates[indexColor]
                : Colors.transparent,
            restrictedPlates: plates,
          ),
        );
      }
    }

    return result;
  }
}
