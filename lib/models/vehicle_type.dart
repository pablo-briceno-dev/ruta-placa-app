enum VehicleType {
  particular,
  taxi,
  moto;
  // camion,
  // bus;

  String get label {
    switch (this) {
      case VehicleType.particular:
        return 'Particular';
      case VehicleType.taxi:
        return 'Taxi';
      case VehicleType.moto:
        return 'Moto';
      // case VehicleType.camion:
      //   return 'Camión';
      // case VehicleType.bus:
      //   return 'Bus / Buseta';
    }
  }

  String get icon {
    switch (this) {
      case VehicleType.particular:
        return '🚗';
      case VehicleType.taxi:
        return '🚕';
      case VehicleType.moto:
        return '🏍️';
      // case VehicleType.camion:
      //   return '🚛';
      // case VehicleType.bus:
      //   return '🚌';
    }
  }
}
