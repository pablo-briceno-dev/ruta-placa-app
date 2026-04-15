// Estado de carga
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ruta_placa/core/utils/default_models_utils.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/services/rules_service.dart';

enum RulesStatus {
  loading,
  ready,
  error,
  updateAvailable,
  checking,
  downloading,
}

class RulesState {
  final RulesStatus status;
  final List<CityRule> cities;
  final String? error;
  final double progress;

  RulesState({
    required this.status,
    this.cities = const [],
    this.error,
    this.progress = 0.0,
  });
}

final rulesProvider = StateNotifierProvider<RulesNotifier, RulesState>(
  (ref) => RulesNotifier(),
);

final rulesInitProvider = FutureProvider<List<CityRule>>((ref) async {
  return await RulesService.instance.loadRules();
});

// Provider derivado - buscar ciudad por id
final cityByIdProvider = Provider.family<CityRule?, String?>((ref, id) {
  final rules = ref.watch(rulesProvider);
  if (rules.status != RulesStatus.ready) return null;
  try {
    return id == null
        ? cityRuleUtils
        : rules.cities.firstWhere((c) => c.id == id);
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
      final cities = await RulesService.instance.loadRules(
        onProgress: (progress) {
          state = RulesState(
            status: RulesStatus.downloading,
            progress: progress,
          );
        },
      );
      state = RulesState(
        status: RulesStatus.ready,
        cities: [
          ...cities,
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
      );
    } catch (e) {
      state = RulesState(status: RulesStatus.error, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = RulesState(status: RulesStatus.loading);
    try {
      final cities = await RulesService.instance.forceRefresh(
        onProgress: (progress) {
          state = RulesState(
            status: RulesStatus.downloading,
            progress: progress,
          );
        },
      );
      state = RulesState(
        status: RulesStatus.ready,
        cities: [
          ...cities,
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
      );
    } catch (e) {
      state = RulesState(status: RulesStatus.error, error: e.toString());
    }
  }

  Future<void> checkForUpdates() async {
    state = RulesState(status: RulesStatus.checking);

    final hasUpdate = await RulesService.instance.hasNewVersion();
    final cities = await RulesService.instance.loadRules(
      onProgress: (progress) {
        state = RulesState(status: RulesStatus.downloading, progress: progress);
      },
    );

    state = RulesState(
      status: hasUpdate ? RulesStatus.updateAvailable : RulesStatus.ready,
      cities: [...cities]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    );
  }

  Future<void> downloadUpdate() async {
    state = RulesState(status: RulesStatus.downloading, progress: 0.0);
    try {
      final cities = await RulesService.instance.forceRefresh(
        onProgress: (progress) {
          state = RulesState(
            status: RulesStatus.downloading,
            progress: progress,
          );
        },
      );
      state = RulesState(
        status: RulesStatus.ready,
        cities: [
          ...cities,
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
      );
    } catch (_) {
      state = RulesState(status: RulesStatus.error);
    }
  }
}
