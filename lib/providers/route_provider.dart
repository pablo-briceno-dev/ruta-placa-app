import 'package:flutter_riverpod/legacy.dart';
import 'package:ruta_placa/models/route_city.dart';
import 'package:ruta_placa/services/database_service.dart';

class RouteState {
  final List<RouteCity> cities;
  final bool isLoading;

  const RouteState({required this.cities, required this.isLoading});

  RouteState copyWith({List<RouteCity>? cities, bool? isLoading}) => RouteState(
    cities: cities ?? this.cities,
    isLoading: isLoading ?? this.isLoading,
  );
}

final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>(
  (ref) => RouteNotifier(),
);

class RouteNotifier extends StateNotifier<RouteState> {
  RouteNotifier() : super(const RouteState(cities: [], isLoading: false)) {
    _load();
  }

  final _db = DatabaseService.instance;

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final cities = await _db.getAll();
    state = state.copyWith(cities: cities, isLoading: false);
  }

  Future<void> addCity(RouteCity city) async {
    final nextOrder = state.cities.isEmpty
        ? 0
        : state.cities.map((c) => c.order).reduce((a, b) => a > b ? a : b) + 1;
    final inserted = await _db.insert(city.copyWith(order: nextOrder));
    state = state.copyWith(cities: [...state.cities, inserted]);
  }

  Future<void> removeCity(int id) async {
    await _db.delete(id);
    state = state.copyWith(
      cities: state.cities.where((c) => c.id != id).toList(),
    );
  }

  // Elimina una por una con delay, preservando la última
  Future<void> autoCleanup({
    Duration delay = const Duration(seconds: 2),
  }) async {
    final sorted = [...state.cities]
      ..sort((a, b) => a.order.compareTo(b.order));
    // Preservar la última
    final toDelete = sorted.take(sorted.length - 1).toList();

    for (final city in toDelete) {
      await Future.delayed(delay);
      await removeCity(city.id!);
    }
  }

  Future<void> clearAll() async {
    await _db.deleteAll();
    state = state.copyWith(cities: []);
  }
}
