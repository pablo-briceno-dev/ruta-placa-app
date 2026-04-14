import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/settings_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/providers/widget_data_provider.dart';
import 'package:ruta_placa/services/city_rules_reader.dart';
import 'package:ruta_placa/services/notification_service.dart';
import 'package:ruta_placa/services/widget_service.dart';

class GlobalListeners extends ConsumerWidget {
  final Widget child;

  const GlobalListeners({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔹 Widget (vehículo + ciudad)
    ref.listen(widgetDataProvider, (_, data) async {
      if (data == null) return;

      final (vehicle, city) = data;

      await WidgetService.instance.updateWidget(
        vehicle: vehicle,
        cityRule: city,
      );
    });
    // 🔹 Notificaciones
    ref.listen(notificationSettingsProvider, (_, next) async {
      if (!next.notificationsEnabled) return;
      final vehicles = ref.read(vehiclesProvider).vehicles;
      final rules = ref.read(rulesProvider);
      await NotificationService.instance.scheduleAll(
        vehicles: vehicles,
        settings: next,
        rulesReader: CityRulesReader(rules.cities),
      );
    });
    return child;
  }
}
