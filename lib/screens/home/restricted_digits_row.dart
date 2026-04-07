import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/core/utils/date_utils.dart';
import 'package:ruta_placa/data/cities_repository.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
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
    final rule = CitiesRepository.getCityRule(vehicle?.cityId ?? cityId);
    final resultPlate = PicoPlacaCalculator.checkPlate(
      cityId: vehicle?.cityId ?? cityId,
      plate: vehicle?.plate ?? plate,
      vehicleType: vehicle?.vehicleType ?? vehicleType,
      date: DateTime.now(),
    );
    debugPrint('resultPlate: ${rule?.restrictions[vehicleType]?.morningStart}');

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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    cityId: cityId,
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
                  child: !resultPlate.hasRestriction
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.chipTheme.selectedColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Sin restricción ${resultPlate.reason != null ? ': ${resultPlate.reason})' : ''}${resultPlate.note != null ? '\n${resultPlate.note}' : ''}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : Text(''),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${formatTime(context, rule?.restrictions[vehicleType]?.morningStart ?? TimeOfDay.now())} - ${formatTime(context, rule?.restrictions[vehicleType]?.morningEnd ?? TimeOfDay.now())}',
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
