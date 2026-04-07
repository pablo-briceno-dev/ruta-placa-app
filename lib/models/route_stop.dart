import 'package:ruta_placa/models/vehicle_type.dart';

class RouteStop {
  final String cityId;
  final DateTime arrivalDate;
  final String plateNumber; // ej: "ABC-123"
  final VehicleType vehicleType;

  const RouteStop({
    required this.cityId,
    required this.arrivalDate,
    required this.plateNumber,
    required this.vehicleType,
  });
}
