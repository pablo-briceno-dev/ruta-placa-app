import 'package:ruta_placa/data/cities/bogota.dart';
import 'package:ruta_placa/data/cities/cali.dart';
import 'package:ruta_placa/data/cities/medellin.dart';
import 'package:ruta_placa/models/city_rule.dart';

class CitiesRepository {
  CitiesRepository._();

  // Mapa interno: id → CityRule
  static final Map<String, CityRule> _cities = {
    'bogota': bogotaRule,
    'medellin': medellinRule,
    'cali': caliRule,
  };

  static CityRule? getCityRule(String cityId) => _cities[cityId];

  static List<CityRule> getCityRules() => _cities.values.toList();

  static List<String> get allIds => _cities.keys.toList();
}
