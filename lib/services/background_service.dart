import 'package:flutter/material.dart';
import 'package:ruta_placa/services/city_rules_reader.dart';
import 'package:ruta_placa/services/database_service.dart';
import 'package:ruta_placa/services/rules_service.dart';
import 'package:ruta_placa/services/widget_service.dart';
import 'package:workmanager/workmanager.dart';

const taskName = 'updatePicoPlacaWidget';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskName) {
      try {
        // Cargar datos sin el árbol de widgets
        final db = DatabaseService.instance;
        final vehicles = await db.getAllVehicles();
        if (vehicles.isEmpty) return true;

        final defaultVehicle = vehicles.firstWhere(
          (v) => v.isDefault,
          orElse: () => vehicles.first,
        );

        final rules = await RulesService.instance.loadRules();
        final reader = CityRulesReader(rules);
        final city = reader.getCity(defaultVehicle.cityId);

        await WidgetService.instance.updateWidget(
          vehicle: defaultVehicle,
          cityRule: city,
        );
      } catch (e) {
        debugPrint('Widget update error: $e');
      }
    }
    return true;
  });
}
