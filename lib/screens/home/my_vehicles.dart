import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/home/form_vehicle_screen.dart';
import 'package:ruta_placa/screens/home/my_vehicle_card.dart';

class MyVehicles extends ConsumerWidget {
  const MyVehicles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vehicles = ref.watch(vehiclesProvider);
    final defaultVehicle = ref.watch(defaultVehicleProvider);

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (defaultVehicle == null) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Aún no tienes ningún vehículo guardado. Añade uno a continuación.',
                    style: TextStyle(
                      fontSize: theme.textTheme.titleLarge?.fontSize,
                      fontWeight: theme.textTheme.titleLarge?.fontWeight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FormVehicleScreen(),
                    ),
                  ),
                  label: Text('Agregar vehículo'),
                  icon: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.chipTheme.selectedColor,
                  ),
                ),
              ),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: defaultVehicle != null
                  ? MyVehicleCard(
                      key: ValueKey(defaultVehicle.plate), // 🔥 CLAVE
                      vehicle: defaultVehicle,
                      isDefault: true,
                    )
                  : const SizedBox(),
            ),
            ...vehicles.entries.map((vehicle) {
              if (defaultVehicle?.plate != vehicle.value.plate) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1,
                  child: MyVehicleCard(vehicle: vehicle.value),
                );
              }
              return const SizedBox();
            }),
          ],
        ),
      ),
    );
  }
}
