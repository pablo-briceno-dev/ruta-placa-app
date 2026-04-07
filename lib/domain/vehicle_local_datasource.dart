import 'dart:convert';

import 'package:ruta_placa/domain/vehicle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleLocalDatasource {
  static const _key = 'vehicles_map';

  Future<Map<String, Vehicle>> getVehiclesMap() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return {};

    final decoded = jsonDecode(data) as Map<String, dynamic>;

    return decoded.map((key, value) => MapEntry(key, Vehicle.fromJson(value)));
  }

  Future<void> saveVehiclesMap(Map<String, Vehicle> vehiclesMap) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = vehiclesMap.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString(_key, jsonEncode(jsonMap));
  }
}
