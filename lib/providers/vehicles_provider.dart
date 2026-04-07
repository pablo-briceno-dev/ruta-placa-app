import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ruta_placa/domain/vehicle.dart';
import 'package:ruta_placa/domain/vehicle_local_datasource.dart';

final vehicleDataSourceProvider = Provider((ref) {
  return VehicleLocalDatasource();
});

final vehiclesProvider =
    StateNotifierProvider<VehiclesNotifier, Map<String, Vehicle>>((ref) {
      final dataSource = ref.watch(vehicleDataSourceProvider);
      return VehiclesNotifier(dataSource)..loadVehicles();
    });

class VehiclesNotifier extends StateNotifier<Map<String, Vehicle>> {
  final VehicleLocalDatasource dataSource;

  VehiclesNotifier(this.dataSource) : super({});

  Future<void> loadVehicles() async {
    final vehiclesMap = await dataSource.getVehiclesMap();
    state = vehiclesMap;
  }

  Future<void> addOrUpdateVehicle(Vehicle vehicle) async {
    final updated = {...state, vehicle.plate: vehicle};

    state = updated;
    await dataSource.saveVehiclesMap(updated);
  }

  Future<void> removeVehicle(String plate) async {
    final updated = Map<String, Vehicle>.from(state);
    updated.remove(plate);

    state = updated;
    await dataSource.saveVehiclesMap(updated);
  }
}
