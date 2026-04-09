import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/core/utils/date_utils.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';

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
    final theme = Theme.of(context);
    final vehicle = ref.watch(defaultVehicleProvider);
    final city = ref.watch(cityByIdProvider(cityId));
    final resultPlate = PicoPlacaCalculator.checkPlate(
      cityRule: city,
      plate: vehicle?.plate ?? plate,
      vehicleType: vehicle?.vehicleType ?? vehicleType,
      date: DateTime.now(),
    );

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        child: Column(
          children: [
            const Text(
              'Dígitos restringidos hoy',
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
                    cityRule: city,
                    plate: digit,
                    vehicleType: vehicleType, // ← automático desde el modelo
                    date: DateTime.now(),
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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: resultPlate.hasRestriction
                          ? theme.colorScheme.error.withValues(alpha: 0.55)
                          : theme.chipTheme.selectedColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${resultPlate.hasRestriction ? 'Con pico y placa' : 'Sin pico y placa'} ${plate.isEmpty ? '' : ' $plate'}'
                              .toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (resultPlate.reason != null)
                          Text(
                            resultPlate.reason!.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (resultPlate.note != null)
                          Text(
                            resultPlate.note!.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      '${formatTime(context, city?.restrictions[vehicleType]?.morningStart ?? TimeOfDay.now())} - ${formatTime(context, city?.restrictions[vehicleType]?.morningEnd ?? TimeOfDay.now())}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
