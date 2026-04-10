import 'package:flutter/material.dart';
import 'package:ruta_placa/core/helpers/restriction_reason_ext.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle.dart';

class DayDetailPanel extends StatelessWidget {
  final DateTime date;
  final CityRule city;
  final Vehicle vehicle;

  const DayDetailPanel({
    super.key,
    required this.date,
    required this.city,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final r = PicoPlacaCalculator.checkPlate(
      cityRule: city,
      plate: vehicle.plate,
      vehicleType: vehicle.vehicleType,
      date: date,
    );

    return ListTile(
      leading: Icon(
        r.hasRestriction ? Icons.block : Icons.check_circle,
        color: r.hasRestriction ? Colors.red : Colors.green,
      ),
      title: Text(
        r.hasRestriction ? 'Tiene restricción ese día' : r.reason.shortMessage,
      ),
      subtitle: r.restrictedPlates.isNotEmpty
          ? Text('Dígitos restringidos: ${r.restrictedPlates.join(', ')}')
          : null,
    );
  }
}
