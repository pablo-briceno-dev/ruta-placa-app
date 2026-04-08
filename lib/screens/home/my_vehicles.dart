import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/home/my_vehicle_card.dart';

class MyVehicles extends ConsumerWidget {
  const MyVehicles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeText = Theme.of(context).textTheme;
    final vehicles = ref.watch(vehiclesProvider);
    final defaultVehicle = ref.watch(defaultVehicleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (defaultVehicle == null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Aún no tienes ningún vehículo guardado. Añade uno a continuación.',
                style: TextStyle(
                  fontSize: themeText.titleLarge?.fontSize,
                  fontWeight: themeText.titleLarge?.fontWeight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (defaultVehicle != null) MyVehicleCard(vehicle: defaultVehicle),
        ...vehicles.entries.map((vehicle) {
          return MyVehicleCard(vehicle: vehicle.value);
        }),
      ],
    );
  }
}
