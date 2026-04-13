import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/services/database_service.dart';

class VehiclesState {
  final List<Vehicle> vehicles;
  final bool isLoading;

  const VehiclesState({required this.vehicles, required this.isLoading});

  VehiclesState copyWith({List<Vehicle>? vehicles, bool? isLoading}) =>
      VehiclesState(
        vehicles: vehicles ?? this.vehicles,
        isLoading: isLoading ?? this.isLoading,
      );
}

final vehiclesProvider = StateNotifierProvider<VehiclesNotifier, VehiclesState>(
  (ref) => VehiclesNotifier(),
);

// Provider derivado — vehículo por defecto
final defaultVehicleProvider = Provider<Vehicle?>((ref) {
  final state = ref.watch(vehiclesProvider);
  if (state.vehicles.isEmpty) return null;
  try {
    return state.vehicles.firstWhere((v) => v.isDefault);
  } catch (_) {
    return state.vehicles.first;
  }
});

class VehiclesNotifier extends StateNotifier<VehiclesState> {
  VehiclesNotifier()
    : super(const VehiclesState(vehicles: [], isLoading: false)) {
    _load();
  }

  final _db = DatabaseService.instance;

  Future<void> _load() async {
    final vehicles = await _db.getAllVehicles();
    state = state.copyWith(vehicles: vehicles, isLoading: false);
  }

  Future<void> add(Vehicle vehicle) async {
    final inserted = await _db.insertVehicle(vehicle);
    // Si es el primero, ya viene como default desde la BD
    state = state.copyWith(vehicles: [...state.vehicles, inserted]);
  }

  Future<void> remove(String plate) async {
    await _db.deleteVehicle(plate);
    // Recargar para reflejar posible cambio de default
    final updated = await _db.getAllVehicles();
    state = state.copyWith(vehicles: updated);
  }

  Future<void> setDefault(String plate) async {
    await _db.setDefaultVehicle(plate);
    state = state.copyWith(
      vehicles: state.vehicles
          .map((v) => v.copyWith(isDefault: v.plate == plate))
          .toList(),
    );
  }

  Future<void> update(Vehicle vehicle) async {
    await _db.updateVehicle(vehicle);
    state = state.copyWith(
      vehicles: state.vehicles
          .map((v) => v.id == vehicle.id ? vehicle : v)
          .toList(),
    );
  }
}
