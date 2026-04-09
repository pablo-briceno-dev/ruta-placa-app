import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ruta_placa/domain/vehicle_local_datasource.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _defaultVehicleKey = 'default_vehicle';

final vehicleDataSourceProvider = Provider((ref) {
  return VehicleLocalDatasource();
});

final vehiclesProvider =
    StateNotifierProvider<VehiclesNotifier, Map<String, Vehicle>>((ref) {
      final dataSource = ref.watch(vehicleDataSourceProvider);
      return VehiclesNotifier(dataSource)..loadVehicles();
    });

final defaultVehiclePlateProvider = StateProvider<String?>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getString(_defaultVehicleKey);
});

final defaultVehicleProvider = Provider<Vehicle?>((ref) {
  final vehicles = ref.watch(vehiclesProvider);
  final defaultPlate = ref.watch(defaultVehiclePlateProvider);

  if (defaultPlate != null && vehicles.containsKey(defaultPlate)) {
    return vehicles[defaultPlate];
  }

  return vehicles.isNotEmpty ? vehicles.values.first : null;
});

final setDefaultVehicleProvider = Provider((ref) {
  final prefs = ref.watch(sharedPrefsProvider);

  return (String plate) async {
    await prefs.setString(_defaultVehicleKey, plate);

    // 🔥 IMPORTANTE: actualizar estado reactivo
    ref.read(defaultVehiclePlateProvider.notifier).state = plate;
  };
});

class VehiclesNotifier extends StateNotifier<Map<String, Vehicle>> {
  final VehicleLocalDatasource dataSource;

  VehiclesNotifier(this.dataSource) : super({});

  Future<void> loadVehicles() async {
    final vehiclesMap = await dataSource.getVehiclesMap();
    state = vehiclesMap;
  }

  Future<void> addOrUpdateVehicle(Vehicle vehicle) async {
    final newState = <String, Vehicle>{};

    for (final entry in state.entries) {
      final v = entry.value;

      newState[entry.key] = Vehicle(
        plate: v.plate,
        alias: v.alias,
        cityId: v.cityId,
        vehicleTypeIndex: v.vehicleTypeIndex,
      );
    }

    newState[vehicle.plate] = vehicle;

    state = newState;
    await dataSource.saveVehiclesMap(newState);
  }

  Future<void> removeVehicle(String plate) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = Map<String, Vehicle>.from(state);
    updated.remove(plate);

    // si eliminas el default → limpiar
    final defaultPlate = prefs.getString(_defaultVehicleKey);
    if (defaultPlate == plate) {
      await prefs.remove(_defaultVehicleKey);
    }

    state = updated;
    await dataSource.saveVehiclesMap(updated);
  }
}
