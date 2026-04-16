import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ruta_placa/core/utils/default_models_utils.dart';
import 'package:ruta_placa/core/utils/strings_utils.dart';
import 'package:ruta_placa/data/colors_plates.dart';
import 'package:ruta_placa/logic/calendar_generator.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/route_city.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/route/legend_item.dart';
import 'package:ruta_placa/widgets/calendar/table_calendar_panel.dart';

class CityCalendarSheet extends ConsumerStatefulWidget {
  final RouteCity city;
  final CityRule? cityRule;
  final Vehicle? vehicle;

  const CityCalendarSheet({
    super.key,
    required this.city,
    this.cityRule,
    this.vehicle,
  });

  @override
  ConsumerState<CityCalendarSheet> createState() => _CityCalendarSheetState();
}

class _CityCalendarSheetState extends ConsumerState<CityCalendarSheet> {
  DateTime _focused = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultVehicle = ref.watch(defaultVehicleProvider);
    final calDays = CalendarGenerator.generateMonth(
      year: _focused.year,
      month: _focused.month,
      cityRule: widget.cityRule ?? cityRuleUtils,
      vehicleType: widget.vehicle?.vehicleType ?? VehicleType.particular,
      plate: widget.vehicle?.plate ?? defaultVehicle?.plate ?? '',
      isSystemColors: false,
    );
    final formatted = capitalizeString(
      DateFormat("EEE d", 'es_ES').format(_selectedDate),
    );
    final restricted = PicoPlacaCalculator.checkPlate(
      cityRule: widget.cityRule ?? cityRuleUtils,
      plate: widget.vehicle?.plate ?? defaultVehicle?.plate ?? '',
      vehicleType: widget.vehicle?.vehicleType ?? VehicleType.particular,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  widget.city.cityEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(widget.city.cityName, style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  '$formatted - ${restricted.hasRestriction ? 'Con' : 'Sin'} pico y placa',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TableCalendarPanel(
              calDays: calDays,
              focused: _focused,
              selectedDate: _selectedDate,
              onDaySelected: (sel, foc) => setState(() {
                _selectedDate = sel;
                _focused = foc;
              }),
              onPageChanged: (p0) => setState(() => _focused = p0),
            ),
          ),

          // Leyenda
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendItem(
                  color: Colors.green,
                  label: 'Libre',
                  isApplyBackground: false,
                ),
                const SizedBox(width: 16),
                LegendItem(color: colorScheme.error, label: 'Restricción'),
                const SizedBox(width: 16),
                LegendItem(color: holidayColor, label: 'Festivos'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
