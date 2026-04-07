// lib/models/route_stop.dart
class RouteStop {
  final String cityId;
  final DateTime arrivalDate;
  final String plateNumber; // ej: "ABC-123"

  const RouteStop({
    required this.cityId,
    required this.arrivalDate,
    required this.plateNumber,
  });
}