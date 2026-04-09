import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/home/form_vehicle_screen.dart';

class MyVehicleCard extends ConsumerWidget {
  final Vehicle vehicle;
  final bool isDefault;

  const MyVehicleCard({
    super.key,
    required this.vehicle,
    this.isDefault = false,
  });

  Icon _getIcon(VehicleType vehicleType, ThemeData theme, Color color) {
    switch (vehicleType) {
      case VehicleType.particular:
        return Icon(Icons.directions_car, color: color);
      case VehicleType.taxi:
        return Icon(Icons.local_taxi, color: color);
      case VehicleType.moto:
        return Icon(Icons.two_wheeler, color: color);
      case VehicleType.camion:
        return Icon(Icons.local_shipping, color: color);
      case VehicleType.bus:
        return Icon(Icons.directions_bus, color: color);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCity = ref.watch(selectedCityProvider);
    final city = ref.watch(cityByIdProvider(vehicle.cityId));
    final cityRule = ref.watch(
      cityByIdProvider(selectedCity ?? vehicle.cityId),
    );
    final resultPlate = PicoPlacaCalculator.checkPlate(
      cityRule: cityRule,
      plate: vehicle.plate,
      vehicleType: vehicle.vehicleType,
      date: DateTime.now(),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
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
                child: _getIcon(
                  vehicle.vehicleType,
                  theme,
                  resultPlate.hasRestriction
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
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
                      city?.name ?? vehicle.cityId,
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: Icon(
                            isDefault ? Icons.star : Icons.star_border,
                            size: 30,
                          ),
                          color: theme.colorScheme.primaryContainer,
                          onPressed: () {
                            if (!isDefault) {
                              debugPrint('isDefault = false');
                              ref.read(setDefaultVehicleProvider)(
                                vehicle.plate,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FormVehicleScreen(vehicle: vehicle),
                              ),
                            );
                          },
                          icon: Icon(Icons.chevron_right, size: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
