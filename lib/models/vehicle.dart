import 'package:flutter/material.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

class Vehicle {
  final String plate;
  final String alias;
  final String cityId;
  int vehicleTypeIndex;

  Vehicle({
    required this.plate,
    required this.alias,
    required this.cityId,
    this.vehicleTypeIndex = 0,
  });

  VehicleType get vehicleType => VehicleType.values[vehicleTypeIndex];

  set vehicleType(VehicleType t) => vehicleTypeIndex = t.index;

  Icon getIcon({required VehicleType vehicleType, Color? color}) {
    switch (vehicleType) {
      case VehicleType.particular:
        return Icon(Icons.directions_car, color: color);
      case VehicleType.taxi:
        return Icon(Icons.local_taxi, color: color);
      case VehicleType.moto:
        return Icon(Icons.two_wheeler, color: color);
      case VehicleType.camion:
        return Icon(Icons.local_shipping, color: color);
      case VehicleType.bus:
        return Icon(Icons.directions_bus, color: color);
    }
  }

  Map<String, dynamic> toJson() => {
    'plate': plate,
    'vehicleTypeIndex': vehicleTypeIndex,
    'alias': alias,
  };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    plate: json['plate'] ?? '',
    vehicleTypeIndex: json['vehicleTypeIndex'] ?? 0,
    alias: json['alias'] ?? '',
    cityId: json['cityId'] ?? 'bogota',
  );

  int get lastDigit {
    final clean = plate.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return -1;
    return int.parse(clean[clean.length - 1]);
  }
}
