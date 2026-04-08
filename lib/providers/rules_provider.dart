// Estado de carga
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/services/rules_service.dart';

enum RulesStatus { loading, ready, error }

class RulesState {
  final RulesStatus status;
  final List<CityRule> cities;
  final String? error;

  RulesState({required this.status, this.cities = const [], this.error});
}

final rulesProvider = StateNotifierProvider<RulesNotifier, RulesState>(
  (ref) => RulesNotifier(),
);

// Provider derivado - buscar ciudad por id
final cityByIdProvider = Provider.family<CityRule?, String>((ref, id) {
  final rules = ref.watch(rulesProvider);
  if (rules.status != RulesStatus.ready) return null;
  try {
    return rules.cities.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

class RulesNotifier extends StateNotifier<RulesState> {
  RulesNotifier() : super(RulesState(status: RulesStatus.loading)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final cities = await RulesService.instance.loadRules();
      state = RulesState(status: RulesStatus.ready, cities: cities);
    } catch (e) {
      state = RulesState(status: RulesStatus.error, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = RulesState(status: RulesStatus.loading);
    try {
      final cities = await RulesService.instance.forceRefresh();
      state = RulesState(status: RulesStatus.ready, cities: cities);
    } catch (e) {
      state = RulesState(status: RulesStatus.error, error: e.toString());
    }
  }
}
