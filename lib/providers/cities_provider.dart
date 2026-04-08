import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedCityProvider =
    StateNotifierProvider<SelectedCityNotifier, String?>(
      (ref) => SelectedCityNotifier(),
    );

class SelectedCityNotifier extends StateNotifier<String?> {
  SelectedCityNotifier() : super(null);

  Future<void> loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selected_city');
  }

  Future<void> setCity(String city) async {
    state = city;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', city);
  }
}
