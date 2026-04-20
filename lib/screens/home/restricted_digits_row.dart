import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ruta_placa/core/utils/default_models_utils.dart';
import 'package:ruta_placa/core/utils/strings_utils.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';
import 'package:ruta_placa/models/plate_origin.dart';
import 'package:ruta_placa/models/time_range.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/widgets/restriction_timer_widget.dart';

class RestrictedDigitsRow extends ConsumerWidget {
  final String cityId;
  final String plate;
  final VehicleType vehicleType;

  static const _allPlates = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  const RestrictedDigitsRow({
    super.key,
    required this.cityId,
    this.vehicleType = VehicleType.particular,
    required this.plate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.now();
    final theme = Theme.of(context);
    final vehicle = ref.watch(defaultVehicleProvider);
    final city = ref.watch(cityByIdProvider(cityId));
    final resultPlate = PicoPlacaCalculator.checkPlate(
      cityRule: city ?? cityRuleUtils,
      plate: vehicle?.plate ?? plate,
      vehicleType: vehicle?.vehicleType ?? vehicleType,
      date: date,
      // time: TimeOfDay(hour: date.hour, minute: date.minute),
      plateOrigin: vehicle?.plateOrigin ?? PlateOrigin.any,
    );
    final formatted = capitalizeString(
      DateFormat("EEE d", 'es_ES').format(date),
    );
    final effectiveVehicleType = vehicle?.vehicleType ?? vehicleType;
    final morningStart =
        city?.restrictions[vehicle?.vehicleType ?? vehicleType]?.morningStart ??
        TimeOfDay.now();
    final morningEnd =
        city?.restrictions[vehicle?.vehicleType ?? vehicleType]?.morningEnd ??
        TimeOfDay(hour: date.hour + 6, minute: 0);
    final afternoonStart =
        city?.restrictions[vehicle?.vehicleType ?? vehicleType]?.afternoonStart;
    final afternoonEnd =
        city?.restrictions[vehicle?.vehicleType ?? vehicleType]?.afternoonEnd;

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (resultPlate.reason == RestrictionReason.comingSoon)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.construction_outlined,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información en desarrollo',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.amber.shade800,
                            ),
                          ),
                          if (resultPlate.note != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              resultPlate.note!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                'Dígitos restringidos hoy - $formatted',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 6,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 20,
                  children: List.generate(_allPlates.length, (index) {
                    final digit = _allPlates[index];
                    final result = PicoPlacaCalculator.checkPlate(
                      cityRule: city ?? cityRuleUtils,
                      plate: digit,
                      vehicleType:
                          vehicle?.vehicleType ??
                          vehicleType, // ← automático desde el modelo
                      date: DateTime.now(),
                      plateOrigin: vehicle?.plateOrigin ?? PlateOrigin.any,
                    );
                    return Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.all(0.5),
                      decoration: BoxDecoration(
                        color: result.hasRestriction
                            ? theme.colorScheme.error.withValues(alpha: 0.55)
                            : theme.chipTheme.selectedColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          digit,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: RestrictionTimerWidget(
                  isRestricted: resultPlate.hasRestriction,
                  ranges:
                      city
                              ?.restrictions[effectiveVehicleType]
                              ?.timeRanges
                              .isNotEmpty ==
                          true
                      ? city!.restrictions[effectiveVehicleType]!.timeRanges
                      : [
                          TimeRange(start: morningStart, end: morningEnd),
                          if (afternoonStart != null)
                            TimeRange(
                              start: afternoonStart,
                              end: afternoonEnd!,
                            ),
                        ],
                  // Rangos por origen (activa el botón del modal)
                  rangesByOrigin:
                      city
                              ?.restrictions[effectiveVehicleType]
                              ?.timeRangesByOrigin
                              .isNotEmpty ==
                          true
                      ? city!
                            .restrictions[effectiveVehicleType]!
                            .timeRangesByOrigin
                      : null,
                  vehiclePlate: vehicle?.plate,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
