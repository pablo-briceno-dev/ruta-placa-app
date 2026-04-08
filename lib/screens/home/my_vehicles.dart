import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/screens/home/my_vehicle_card.dart';

class MyVehicles extends ConsumerWidget {
  const MyVehicles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(2, (index) {
        return MyVehicleCard(
          vehicle: Vehicle(
            plate: 'ABC-123',
            alias: 'Mi Carro',
            cityId: 'bogota',
          ),
        );
      }),
    );
  }
}
