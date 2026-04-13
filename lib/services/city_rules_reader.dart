import 'package:ruta_placa/models/city_rule.dart';

class CityRulesReader {
  final List<CityRule> _cities;

  const CityRulesReader(this._cities);

  CityRule? getCity(String id) {
    try {
      return _cities.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<CityRule> get all => _cities;
}
