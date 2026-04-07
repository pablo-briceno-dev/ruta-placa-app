import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/models/vehicle_type.dart';

class CityRule {
  final String id;
  final String name;
  final String emoji;
  final Map<VehicleType, VehicleRestriction> restrictions;

  const CityRule({
    required this.id,
    required this.name,
    required this.emoji,
    required this.restrictions,
  });

  // Obtener la restricción para un tipo específico
  // Si no existe en el mapa = no aplica restricción
  VehicleRestriction restrictionFor(VehicleType type) =>
      restrictions[type] ?? VehicleRestriction.none;

  // ¿Aplica alguna restricción para este tipo?
  bool appliesTo(VehicleType type) =>
      restrictions.containsKey(type) &&
      restrictions[type]!.hasRestriction;

  // Lista de tipos que SÍ tienen restricción (para mostrar en UI)
  List<VehicleType> get restrictedTypes => restrictions.keys
      .where((t) => restrictions[t]!.hasRestriction)
      .toList();
}
