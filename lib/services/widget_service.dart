import 'package:home_widget/home_widget.dart';
import 'package:ruta_placa/core/helpers/digits_label.dart';
import 'package:ruta_placa/core/utils/date_utils.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';
import 'package:ruta_placa/models/vehicle.dart';

class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  static const _providerSmall = 'HomeWidgetProvider';

  Future<void> init() async {
    await HomeWidget.setAppGroupId('group.com.pablobricenodev.rutaplaca');
  }

  Future<void> updateWidget({
    required Vehicle vehicle,
    required CityRule? cityRule,
  }) async {
    final now = DateTime.now();
    final days = List.generate(3, (i) => now.add(Duration(days: i)));

    // Calcular los 3 días
    final results = days.map((date) {
      if (cityRule == null) return null;
      return PicoPlacaCalculator.checkPlate(
        cityRule: cityRule,
        plate: vehicle.plate,
        vehicleType: vehicle.vehicleType,
        date: date,
        plateOrigin: vehicle.plateOrigin,
      );
    }).toList();

    // Guardar cada día
    for (int i = 0; i < 3; i++) {
      final prefix = i == 0
          ? 'today'
          : i == 1
          ? 'day2'
          : 'day3';
      final result = results[i];
      final date = days[i];

      await Future.wait([
        HomeWidget.saveWidgetData(
          'widget_${prefix}_label',
          i == 0 ? 'Hoy' : weekdayShortUtils(date.weekday),
        ),
        HomeWidget.saveWidgetData(
          'widget_${prefix}_digits',
          _digitsText(result),
        ),
        HomeWidget.saveWidgetData('widget_${prefix}_type', _chipType(result)),
      ]);
    }

    // Datos generales
    await Future.wait([
      HomeWidget.saveWidgetData('widget_city', cityRule?.name ?? '---'),
      HomeWidget.saveWidgetData('widget_plate', vehicle.plate),
    ]);

    // Actualizar ambos providers
    await Future.wait([HomeWidget.updateWidget(androidName: _providerSmall)]);
  }

  // "restricted" | "free" | "all" | "none"
  String _chipType(PicoPlacaResult? result) {
    if (result == null) return 'none';
    if (result.appliesToAll) return 'all';
    if (result.hasRestriction) return 'restricted';
    return 'free';
  }

  String _digitsText(PicoPlacaResult? result) {
    if (result == null) return 'Sin datos';
    if (result.appliesToAll) return 'Todos';
    if (result.hasRestriction) {
      return buildDigitsLabel(result.restrictedPlates);
    }
    return 'Libre';
  }
}
