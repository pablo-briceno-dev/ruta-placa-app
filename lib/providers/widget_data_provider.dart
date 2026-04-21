import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/shared_preferences_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';

final widgetDataProvider = Provider((ref) {
  final vehicle = ref.watch(defaultVehicleProvider);
  final selectedCity = ref.watch(selectedCityProvider);
  final prefsCity = ref.watch(preferencesProvider);

  if (vehicle == null) return null;

  final city = ref.watch(
    cityByIdProvider(prefsCity ?? selectedCity ?? vehicle.cityId),
  );

  return (vehicle, city);
});
