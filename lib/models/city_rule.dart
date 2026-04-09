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
      restrictions[type]?.hasRestriction ?? false;

  // Lista de tipos que SÍ tienen restricción (para mostrar en UI)
  List<VehicleType> get restrictedTypes => restrictions.entries
      .where((e) => e.value.hasRestriction)
      .map((e) => e.key)
      .toList();

  factory CityRule.fromJson(Map<String, dynamic> json) {
    final restrictionsList = json['restrictions'] as List<dynamic>;
    final restrictions = <VehicleType, VehicleRestriction>{};
    for (final r in restrictionsList) {
      final type = VehicleType.values.firstWhere(
        (t) => t.name == r['vehicleType'],
        orElse: () => VehicleType.particular,
      );
      restrictions[type] = VehicleRestriction.fromJson(
        r as Map<String, dynamic>,
      );
    }

    return CityRule(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      restrictions: restrictions,
    );
  }
}
