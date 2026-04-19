import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/notification_settings_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/services/city_rules_reader.dart';
import 'package:ruta_placa/services/notification_service.dart';

class VehiclesSwitchListSheet extends ConsumerStatefulWidget {
  const VehiclesSwitchListSheet({super.key});

  @override
  ConsumerState<VehiclesSwitchListSheet> createState() =>
      _VehiclesSwitchListSheetState();
}

class _VehiclesSwitchListSheetState
    extends ConsumerState<VehiclesSwitchListSheet> {
  final _searchController = TextEditingController();

  String query = '';

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vehicles = ref.watch(vehiclesProvider).vehicles;
    final filtered = vehicles
        .where(
          (v) =>
              v.alias.toLowerCase().contains(query.toLowerCase()) ||
              v.plate.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

            // 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar vehículo...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => query = value);
                },
              ),
            ),

            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final vehicle = filtered[index];

                  return Column(
                    children: [
                      if (index > 0) const Divider(height: 1),
                      SwitchListTile(
                        value: notifState.isVehicleEnabled(vehicle.id!),
                        onChanged: (enabled) async {
                          await ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleVehicle(vehicle.id!, enabled);

                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );

                          final updatedSettings = ref.read(
                            notificationSettingsProvider,
                          );
                          final allVehicles = ref
                              .read(vehiclesProvider)
                              .vehicles;
                          final rules = ref.read(rulesProvider);

                          await NotificationService.instance.scheduleAll(
                            vehicles: allVehicles,
                            settings: updatedSettings,
                            rulesReader: CityRulesReader(rules.cities),
                          );
                        },
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: vehicle.getIcon(
                              vehicleType: vehicle.vehicleType,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(vehicle.alias, style: textTheme.titleSmall),
                        subtitle: Text(
                          '${vehicle.plate} · ${vehicle.vehicleType.label}',
                          style: textTheme.bodySmall,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
