import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/core/utils/default_models_utils.dart';
import 'package:ruta_placa/logic/calendar_generator.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/plate_origin.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/calendar/colors_schedule_panel.dart';
import 'package:ruta_placa/screens/calendar/day_detail_panel.dart';
import 'package:ruta_placa/widgets/calendar/table_calendar_panel.dart';
import 'package:ruta_placa/screens/calendar/vehicles_selector_button.dart';
import 'package:ruta_placa/widgets/city_selector_button_widget.dart';
import 'package:ruta_placa/widgets/update_icon_widget.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendaryScreenState();
}

class _CalendaryScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  Vehicle? selectedVehicle;
  bool _colorsScheduleEnabled = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rulesProvider.notifier).checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rules = ref.watch(rulesProvider);
    final defaultVehicle = ref.watch(defaultVehicleProvider);
    final selectedCity = ref.watch(selectedCityProvider);
    final city = ref.watch(cityByIdProvider(selectedCity));
    final vehicle = Vehicle(
      plate: selectedVehicle?.plate ?? defaultVehicle?.plate ?? '',
      alias: selectedVehicle?.alias ?? defaultVehicle?.alias ?? 'Test',
      cityId: city?.id ?? cityRuleUtils.id,
    );
    final vehiclePlates =
        city
            ?.restrictions[selectedVehicle?.vehicleType ??
                VehicleType.particular]
            ?.getPlates() ??
        cityRuleUtils.restrictions[VehicleType.particular]?.getPlates() ??
        [];
    final calDays = CalendarGenerator.generateMonth(
      year: _focused.year,
      month: _focused.month,
      cityRule: city ?? cityRuleUtils,
      vehicleType: selectedVehicle?.vehicleType ?? VehicleType.particular,
      plate: selectedVehicle?.plate ?? defaultVehicle?.plate ?? '',
      isSystemColors: _colorsScheduleEnabled,
      plateOrigin: selectedVehicle?.plateOrigin ?? PlateOrigin.any,
    );
    final restricted = PicoPlacaCalculator.checkPlate(
      cityRule: city ?? cityRuleUtils,
      plate: selectedVehicle?.plate ?? defaultVehicle?.plate ?? '',
      vehicleType: selectedVehicle?.vehicleType ?? VehicleType.particular,
      date: DateTime.now(),
      plateOrigin: vehicle.plateOrigin,
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
      body: SingleChildScrollView(
        child: Padding(
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
              const SizedBox(height: 5),
              TableCalendarPanel(
                calDays: calDays,
                focused: _focused,
                selectedDate: _selectedDate,
                onDaySelected: (sel, foc) => setState(() {
                  _selectedDate = sel;
                  _focused = foc;
                }),
                onPageChanged: (p0) => setState(() => _focused = p0),
              ),
              const Divider(),
              DayDetailPanel(
                date: DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                ),
                city: city ?? cityRuleUtils,
                vehicle:
                    selectedVehicle ?? defaultVehicle ?? vehicleDefaultUtils,
                plates: vehiclePlates,
                isSytemColors: _colorsScheduleEnabled,
              ),
              const SizedBox(height: 10),
              ColorsSchedulePanel(
                plates: vehiclePlates,
                platesRestriction: restricted.restrictedPlates,
                lastDigitPlate: '${vehicle.lastDigit}',
                isEnabledSystemColors: _colorsScheduleEnabled,
                onChangedSwitch: (v) =>
                    setState(() => _colorsScheduleEnabled = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
