import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/calendar/vehicles_selector_sheet.dart';

class VehiclesSelectorButton extends ConsumerWidget {
  final Vehicle? selected;
  final Function(Vehicle) onSelected;

  const VehiclesSelectorButton({
    super.key,
    required this.onSelected,
    this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultVehicle = ref.watch(defaultVehicleProvider);
    final vehicles = ref.watch(vehiclesProvider);
    final vehicle =
        selected ??
        defaultVehicle ??
        (vehicles.isNotEmpty ? vehicles.values.first : null);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final result = await showModalBottomSheet<Vehicle>(
          context: context,
          isScrollControlled: true,
          builder: (_) => VehiclesSelectorSheet(
            vehicles: vehicles.entries.map((e) => e.value).toList(),
          ),
        );

        if (result != null) {
          onSelected(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vehicle != null) ...[
              vehicle.getIcon(vehicleType: vehicle.vehicleType),
              const SizedBox(width: 6),
              Text('${vehicle.alias} (${vehicle.plate})'),
            ] else ...[
              const Icon(Icons.directions_car),
              const SizedBox(width: 6),
              const Text('Consultar vehículo'),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}
