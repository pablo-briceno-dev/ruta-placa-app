import 'package:flutter/material.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

class Vehicle {
  final int? id;
  final String plate;
  final String alias;
  final String cityId;
  final int vehicleTypeIndex;
  final bool isDefault;

  Vehicle({
    this.id,
    required this.plate,
    required this.alias,
    required this.cityId,
    this.vehicleTypeIndex = 0,
    this.isDefault = false,
  });

  VehicleType get vehicleType => VehicleType.values[vehicleTypeIndex];

  Icon getIcon({required VehicleType vehicleType, Color? color}) {
    switch (vehicleType) {
      case VehicleType.particular:
        return Icon(Icons.directions_car, color: color);
      case VehicleType.taxi:
        return Icon(Icons.local_taxi, color: color);
      case VehicleType.moto:
        return Icon(Icons.two_wheeler, color: color);
      // case VehicleType.camion:
      //   return Icon(Icons.local_shipping, color: color);
      // case VehicleType.bus:
      //   return Icon(Icons.directions_bus, color: color);
    }
  }

  int get lastDigit {
    final clean = plate.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return -1;
    return int.parse(clean[clean.length - 1]);
  }

  Vehicle copyWith({
    int? id,
    String? plate,
    String? alias,
    String? cityId,
    int? vehicleTypeIndex,
    bool? isDefault,
  }) => Vehicle(
    id: id ?? this.id,
    plate: plate ?? this.plate,
    alias: alias ?? this.alias,
    cityId: cityId ?? this.cityId,
    vehicleTypeIndex: vehicleTypeIndex ?? this.vehicleTypeIndex,
    isDefault: isDefault ?? this.isDefault,
  );

  factory Vehicle.fromMap(Map<String, dynamic> map) => Vehicle(
    id: map['id'] as int?,
    plate: map['plate'] as String,
    alias: map['alias'] as String,
    cityId: map['city_id'] as String,
    vehicleTypeIndex: map['vehicle_type_index'] as int,
    isDefault: (map['is_default'] as int) == 1,
  );
}
