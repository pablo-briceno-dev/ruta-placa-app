import 'package:flutter/material.dart';
import 'package:ruta_placa/core/utils/default_models_utils.dart';
import 'package:ruta_placa/logic/calendar_generator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/screens/calendar/colors_schedule_panel.dart';
import 'package:ruta_placa/screens/calendar/day_detail_panel.dart';
import 'package:ruta_placa/screens/calendar/vehicles_selector_button.dart';
import 'package:ruta_placa/widgets/calendar/table_calendar_panel.dart';

class PortraitLayout extends StatelessWidget {
  final DateTime focused;
  final DateTime selectedDate;
  final Vehicle? selectedVehicle;
  final bool colorsScheduleEnabled;
  final Function(Vehicle) onSelectedVehicle;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Function(bool) onChangedSwitch;
  final PicoPlacaResult restricted;
  final List<CalendarDay> calDays;
  final List<List<int>> vehiclePlates;
  final Vehicle vehicle;
  final CityRule? cityRule;
  final Vehicle? defaultVehicle;

  const PortraitLayout({
    super.key,
    required this.focused,
    required this.selectedDate,
    this.selectedVehicle,
    required this.colorsScheduleEnabled,
    required this.onSelectedVehicle,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onChangedSwitch,
    required this.restricted,
    required this.calDays,
    required this.vehiclePlates,
    required this.vehicle,
    this.cityRule, this.defaultVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: VehiclesSelectorButton(
                selected: selectedVehicle,
                onSelected: onSelectedVehicle,
              ),
            ),
            const SizedBox(height: 5),
            TableCalendarPanel(
              calDays: calDays,
              focused: focused,
              selectedDate: selectedDate,
              onDaySelected: onDaySelected,
              onPageChanged: onPageChanged,
            ),
            const Divider(),
            DayDetailPanel(
              date: DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
              ),
              city: cityRule ?? cityRuleUtils,
              vehicle: selectedVehicle ?? defaultVehicle ?? vehicleDefaultUtils,
              plates: vehiclePlates,
              isSytemColors: colorsScheduleEnabled,
            ),
            const SizedBox(height: 10),
            ColorsSchedulePanel(
              plates: vehiclePlates,
              platesRestriction: restricted.restrictedPlates,
              lastDigitPlate: '${vehicle.lastDigit}',
              isEnabledSystemColors: colorsScheduleEnabled,
              onChangedSwitch: onChangedSwitch,
            ),
          ],
        ),
      ),
    );
  }
}
