import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/vehicle.dart';

class MyVehicleCard extends ConsumerWidget {
  final Vehicle vehicle;

  const MyVehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resultPlate = PicoPlacaCalculator.checkPlate(
      cityId: vehicle.cityId,
      plate: vehicle.plate,
      vehicleType: vehicle.vehicleType,
      date: DateTime.now(),
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              child: Icon(
                Icons.directions_car,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(width: 16),

            // 📄 Info
            Expanded(
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

            if (!resultPlate.hasRestriction)
              Text(
                'Sin pico y placa ${resultPlate.reason != null ? ': ${resultPlate.reason})' : ''}${resultPlate.note != null ? '\n${resultPlate.note}' : ''}'
                    .toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),

            if (resultPlate.hasRestriction)
              Text(
                'Con pico y placa ${resultPlate.reason != null ? ': ${resultPlate.reason})' : ''}${resultPlate.note != null ? '\n${resultPlate.note}' : ''}'
                    .toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),

            // ➡️ Flecha
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
    // return Card(
    //   child: Container(
    //     width: double.infinity,
    //     padding: const EdgeInsets.all(10),
    //     decoration: BoxDecoration(
    //       color: theme.colorScheme.surface,
    //       borderRadius: BorderRadiusGeometry.circular(10),
    //     ),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(vehicle.alias),
    //         const Divider(),
    //         Row(
    //           children: [
    //             Expanded(flex: 1, child: Icon(Icons.abc)),
    //             Expanded(flex: 1, child: Row(children: [Text(vehicle.plate)])),
    //             Expanded(flex: 1, child: Icon(Icons.abc)),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
