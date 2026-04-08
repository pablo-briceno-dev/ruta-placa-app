import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/rules_provider.dart';

class MyVehicleCard extends ConsumerWidget {
  final Vehicle vehicle;

  const MyVehicleCard({super.key, required this.vehicle});

  Icon _getIcon(VehicleType vehicleType, ThemeData theme) {
    switch (vehicleType) {
      case VehicleType.particular:
        return Icon(Icons.directions_car, color: theme.colorScheme.primary);
      case VehicleType.taxi:
        return Icon(Icons.directions_bike, color: theme.colorScheme.primary);
      case VehicleType.moto:
        return Icon(Icons.directions_run, color: theme.colorScheme.primary);
      case VehicleType.camion:
        return Icon(Icons.directions_boat, color: theme.colorScheme.primary);
      case VehicleType.bus:
        return Icon(Icons.directions_bus, color: theme.colorScheme.primary);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final city = ref.watch(cityByIdProvider(vehicle.cityId));
    final resultPlate = PicoPlacaCalculator.checkPlate(
      cityRule: city,
      plate: vehicle.plate,
      vehicleType: vehicle.vehicleType,
      date: DateTime.now(),
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: resultPlate.hasRestriction
              ? theme.colorScheme.error.withValues(alpha: 0.6)
              : theme.colorScheme.primary.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 🚗 Icono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _getIcon(vehicle.vehicleType, theme),
            ),

            const SizedBox(width: 16),

            // 📄 Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.alias,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.plate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.cityId,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (resultPlate.hasRestriction
                            ? 'Con pico y placa'
                            : 'Sin pico y placa')
                        .toUpperCase(),
                    style: TextStyle(
                      color: resultPlate.hasRestriction
                          ? theme.colorScheme.error.withValues(alpha: 0.8)
                          : theme.colorScheme.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                    ),
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
            // ➡️ Flecha
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
