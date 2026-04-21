import 'package:flutter_riverpod/legacy.dart';
import 'package:ruta_placa/data/key_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, String?>(
  (ref) => PreferencesNotifier()..load(),
);

class PreferencesNotifier extends StateNotifier<String?> {
  late SharedPreferences _prefs;

  PreferencesNotifier() : super(null) {
    load();
  }

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs.getString(selectedCityNotify);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
    state = value;
  }
}
