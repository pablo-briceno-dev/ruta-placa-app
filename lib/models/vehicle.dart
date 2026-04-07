import 'package:ruta_placa/models/vehicle_type.dart';

class Vehicle {
  final String plate;
  final String alias;
  final String cityId;
  bool isDefault;
  int vehicleTypeIndex;

  Vehicle({
    required this.plate,
    required this.alias,
    required this.cityId,
    this.isDefault = false,
    this.vehicleTypeIndex = 0,
  });

  VehicleType get vehicleType => VehicleType.values[vehicleTypeIndex];

  set vehicleType(VehicleType t) => vehicleTypeIndex = t.index;

  Map<String, dynamic> toJson() => {
    'plate': plate,
    'vehicleTypeIndex': vehicleTypeIndex,
    'alias': alias,
  };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    plate: json['plate'],
    vehicleTypeIndex: json['vehicleTypeIndex'],
    alias: json['alias'],
    cityId: json['cityId'],
    isDefault: json['isDefault'],
  );

  int get lastDigit {
    final digits = plate.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return -1;
    return int.parse(digits[digits.length - 1]);
  }
}
