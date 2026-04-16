import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/plate_origin.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

class RouteStop {
  final CityRule cityRule;
  final DateTime arrivalDate;
  final String plateNumber; // ej: "ABC-123"
  final VehicleType vehicleType;
  final PlateOrigin plateOrigin;

  const RouteStop({
    required this.cityRule,
    required this.arrivalDate,
    required this.plateNumber,
    required this.vehicleType,
    required this.plateOrigin,
  });
}
