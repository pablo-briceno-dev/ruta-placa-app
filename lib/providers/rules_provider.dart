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
  RulesNotifier() : super(RulesState(status: RulesStatus.loading));

  // ── Llamado desde SplashScreen con mensajes de progreso ──
  Future<void> loadWithProgress({
    required void Function(String) onProgress,
  }) async {
    try {
      onProgress('Verificando datos locales...');
      await Future.delayed(const Duration(milliseconds: 300));

      final hasCached = await RulesService.instance.hasCachedRules();

      if (!hasCached) {
        onProgress('Descargando reglas de pico y placa...');
      } else {
        onProgress('Cargando reglas guardadas...');
      }

      final cities = await RulesService.instance.loadRules(
        onDownloadStart:    () => onProgress('Conectando con el servidor...'),
        onDownloadComplete: () => onProgress('Reglas actualizadas ✓'),
        onUsingCache:       () => onProgress('Usando datos guardados...'),
        onProgress:         (_) {},
      );

      onProgress('Listo');
      await Future.delayed(const Duration(milliseconds: 400));

      state = RulesState(
        status: RulesStatus.ready,
        cities: _sorted(cities),
      );
    } catch (e) {
      // Intentar con caché aunque haya fallado la red
      final cached = await RulesService.instance.loadFromCacheOnly();

      if (cached.isNotEmpty) {
        onProgress('Sin conexión — usando datos guardados');
        await Future.delayed(const Duration(milliseconds: 600));
        state = RulesState(
          status: RulesStatus.ready,
          cities: _sorted(cached),
        );
      } else {
        state = RulesState(
          status: RulesStatus.error,
          error:  e.toString(),
        );
      }
    }
  }

  // ── Forzar actualización desde Settings ──────────────────
  Future<void> refresh() async {
    state = RulesState(status: RulesStatus.loading);
    try {
      final cities = await RulesService.instance.forceRefresh(
        onProgress: (p) => state = RulesState(
          status:   RulesStatus.downloading,
          progress: p,
        ),
      );
      state = RulesState(
        status: RulesStatus.ready,
        cities: _sorted(cities),
      );
    } catch (e) {
      state = RulesState(status: RulesStatus.error, error: e.toString());
    }
  }

  // ── Verificar si hay actualización disponible ─────────────
  Future<void> checkForUpdates() async {
    state = RulesState(
      status: RulesStatus.checking,
      cities: state.cities, // mantener ciudades actuales
    );
    final hasUpdate = await RulesService.instance.hasNewVersion();
    state = RulesState(
      status: hasUpdate ? RulesStatus.updateAvailable : RulesStatus.ready,
      cities: state.cities,
    );
  }

  Future<void> downloadUpdate() async {
    state = RulesState(status: RulesStatus.downloading, progress: 0.0);
    try {
      final cities = await RulesService.instance.forceRefresh(
        onProgress: (p) => state = RulesState(
          status:   RulesStatus.downloading,
          progress: p,
        ),
      );
      state = RulesState(
        status: RulesStatus.ready,
        cities: _sorted(cities),
      );
    } catch (_) {
      state = RulesState(status: RulesStatus.error);
    }
  }

  List<CityRule> _sorted(List<CityRule> cities) =>
      [...cities]..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}
