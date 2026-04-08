import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/screens/home/my_vehicles.dart';
import 'package:ruta_placa/screens/home/restricted_digits_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('RutaPlaca')),
      body: Column(
        children: [
          // !Banner Ad (parte superior o inferior de la pantalla)
          // const AdBannerWidget(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RestrictedDigitsRow(cityId: 'bogota', plate: 'ABC-123'),
                  const Divider(),
                  const Text(
                    'Mis Vehículos',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  MyVehicles(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
