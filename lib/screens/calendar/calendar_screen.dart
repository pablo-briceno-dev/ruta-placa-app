import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/core/utils/default_models_utils.dart';
import 'package:ruta_placa/logic/calendar_generator.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/calendar/vehicles_selector_button.dart';
import 'package:ruta_placa/widgets/city_selector_button_widget.dart';
import 'package:ruta_placa/widgets/update_icon_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendaryScreenState();
}

class _CalendaryScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  Vehicle? selectedVehicle;
  bool _checked = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_checked) {
        ref.read(rulesProvider.notifier).checkForUpdates();
        _checked = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rules = ref.watch(rulesProvider);
    final defaultVehicle = ref.watch(defaultVehicleProvider);
    final selectedCity = ref.watch(selectedCityProvider);
    final city = ref.watch(cityByIdProvider(selectedCity ?? 'bogota'));
    final calDays = CalendarGenerator.generateMonth(
      year: _focused.year,
      month: _focused.month,
      cityRule: city ?? cityRuleUtils,
      vehicleType: selectedVehicle?.vehicleType ?? VehicleType.particular,
      plate: selectedVehicle?.plate ?? defaultVehicle?.plate ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          if (rules.status == RulesStatus.updateAvailable)
            const UpdateIconWidget(),
          CitySelectorButtonWidget(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: VehiclesSelectorButton(
                selected: selectedVehicle,
                onSelected: (vehicle) {
                  setState(() => selectedVehicle = vehicle);
                },
              ),
            ),
            const SizedBox(height: 16),
            TableCalendar(
              locale: 'es_CO',
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: _focused,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDate),
              onDaySelected: (sel, foc) => setState(() {
                _selectedDate = sel;
                _focused = foc;
              }),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (ctx, day, _) {
                  final calDay = calDays.firstWhere(
                    (d) => isSameDay(d.date, day),
                    orElse: () =>
                        CalendarDay(date: day, status: DayStatus.noData),
                  );
                  // debugPrint('calDays ${calDay.date} ${calDay.status}');

                  final color = switch (calDay.status) {
                    DayStatus.restricted => Colors.red,
                    DayStatus.holiday => Colors.orange,
                    DayStatus.weekend => Colors.transparent,
                    _ => Colors.transparent,
                  };

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: color != Colors.transparent
                          ? Border.all(color: color, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontWeight: color != Colors.transparent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: color != Colors.transparent ? color : null,
                      ),
                    ),
                  );
                },
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false),
            ),
            const Divider(),
            _DayDetailPanel(
              date: DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
              ),
              city: city ?? cityRuleUtils,
              vehicle: selectedVehicle ?? defaultVehicle ?? vehicleDefaultUtils,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDetailPanel extends StatelessWidget {
  final DateTime date;
  final CityRule city;
  final Vehicle vehicle;

  const _DayDetailPanel({
    required this.date,
    required this.city,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final r = PicoPlacaCalculator.checkPlate(
      cityRule: city,
      plate: vehicle.plate,
      vehicleType: vehicle.vehicleType,
      date: date,
    );
    debugPrint(
      'build _DayDetailPanel ${vehicle.plate} $date ${r.restrictedPlates.toString()} ${city.name}',
    );
    return ListTile(
      leading: Icon(
        r.hasRestriction ? Icons.block : Icons.check_circle,
        color: r.hasRestriction ? Colors.red : Colors.green,
      ),
      title: Text(
        r.hasRestriction
            ? 'Tiene restricción ese día'
            : (r.reason == 'festivo'
                  ? 'Festivo — sin restricción'
                  : 'Sin restricción'),
      ),
      subtitle: r.restrictedPlates.isNotEmpty
          ? Text('Dígitos restringidos: ${r.restrictedPlates.join(', ')}')
          : null,
    );
  }
}
