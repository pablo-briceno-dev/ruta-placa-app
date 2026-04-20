import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/logic/calendar_generator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/screens/calendar/colors_schedule_panel.dart';
import 'package:ruta_placa/screens/calendar/day_detail_panel.dart';
import 'package:ruta_placa/screens/calendar/vehicles_selector_button.dart';
import 'package:ruta_placa/widgets/calendar/table_calendar_panel.dart';

class LandscapeLayout extends ConsumerStatefulWidget {
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
  final CityRule cityRule;
  final Vehicle? defaultVehicle;

  const LandscapeLayout({
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
    required this.cityRule, this.defaultVehicle,
  });

  @override
  ConsumerState<LandscapeLayout> createState() => _LandscapeLayoutState();
}

class _LandscapeLayoutState extends ConsumerState<LandscapeLayout> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: VehiclesSelectorButton(
                    selected: widget.selectedVehicle,
                    onSelected: widget.onSelectedVehicle,
                  ),
                ),
                const SizedBox(height: 5),
                TableCalendarPanel(
                  calDays: widget.calDays,
                  focused: widget.focused,
                  selectedDate: widget.selectedDate,
                  onDaySelected: widget.onDaySelected,
                  onPageChanged: widget.onPageChanged,
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DayDetailPanel(
                  date: DateTime(
                    widget.selectedDate.year,
                    widget.selectedDate.month,
                    widget.selectedDate.day,
                  ),
                  city: widget.cityRule,
                  vehicle: widget.selectedVehicle ?? widget.vehicle,
                  plates: widget.vehiclePlates,
                  isSytemColors: widget.colorsScheduleEnabled,
                ),
                const SizedBox(height: 10),
                ColorsSchedulePanel(
                  plates: widget.vehiclePlates,
                  platesRestriction: widget.restricted.restrictedPlates,
                  lastDigitPlate: '${widget.vehicle.lastDigit}',
                  isEnabledSystemColors: widget.colorsScheduleEnabled,
                  onChangedSwitch: widget.onChangedSwitch,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
