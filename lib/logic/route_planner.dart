import 'package:ruta_placa/data/cities_repository.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
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
      final city = CitiesRepository.getCityRule(stop.cityId);
      final result = PicoPlacaCalculator.checkPlate(
        cityId: stop.cityId,
        plate: stop.plateNumber,
        date: stop.arrivalDate,
      );
      return StopResult(
        stop: stop,
        cityName: city?.name ?? stop.cityId,
        picoPlaca: result,
      );
    }).toList();

    return RoutePlannerResult()..stops.addAll(results);
  }
}
