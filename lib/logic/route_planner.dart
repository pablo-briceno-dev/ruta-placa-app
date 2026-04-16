import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';
import 'package:ruta_placa/models/route_stop.dart';

class StopResult {
  final RouteStop stop;
  final String cityName;
  final PicoPlacaResult picoPlaca;
  const StopResult({
    required this.stop,
    required this.cityName,
    required this.picoPlaca,
  });
}

class RoutePlannerResult {
  final List<StopResult> stops = [];
  bool get hasAnyRestriction => stops.any((s) => s.picoPlaca.hasRestriction);
  List<StopResult> get blockedStops =>
      stops.where((s) => s.picoPlaca.hasRestriction).toList();
}

class RoutePlanner {
  static RoutePlannerResult evaluate({required List<RouteStop> stops}) {
    final results = stops.map((stop) {
      final result = PicoPlacaCalculator.checkPlate(
        cityRule: stop.cityRule,
        plate: stop.plateNumber,
        vehicleType: stop.vehicleType,
        date: stop.arrivalDate,
        plateOrigin: stop.plateOrigin,
      );
      return StopResult(
        stop: stop,
        cityName: stop.cityRule.name,
        picoPlaca: result,
      );
    }).toList();

    return RoutePlannerResult()..stops.addAll(results);
  }
}
