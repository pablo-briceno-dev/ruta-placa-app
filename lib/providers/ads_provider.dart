import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final adsFreeProvider = StateNotifierProvider<AdsFreeNotifier, bool>(
  (ref) => AdsFreeNotifier(),
);

class AdsFreeNotifier extends StateNotifier<bool> {
  AdsFreeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('ads_free') ?? false;
  }

  // Se llamará desde IAP en Fase 2
  Future<void> setFree() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ads_free', true);
    state = true;
  }
}
