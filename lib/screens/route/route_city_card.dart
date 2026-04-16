import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/route_city.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/screens/route/day_chip.dart';

class RouteCityCard extends ConsumerWidget {
  final RouteCity city;
  final CityRule? cityRule;
  final Vehicle? vehicle;
  final bool isLast;
  final VoidCallback onDelete;
  final VoidCallback onCalendar;

  const RouteCityCard({
    super.key,
    required this.city,
    required this.cityRule,
    required this.vehicle,
    required this.isLast,
    required this.onDelete,
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateNow = DateTime.now();
    final days = [
      dateNow,
      dateNow.add(const Duration(days: 1)),
      dateNow.add(const Duration(days: 2)),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Text(city.cityEmoji, style: const TextStyle(fontSize: 24)),
            title: Text(city.cityName, style: theme.textTheme.titleMedium),
            subtitle: isLast
                ? Text(
                    'Ciudad final',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onCalendar,
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: 'Ver Calendario',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
          // 3 días ---------
          if (cityRule != null && vehicle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: days.map((day) {
                  final result = PicoPlacaCalculator.checkPlate(
                    cityRule: cityRule!,
                    plate: vehicle!.plate,
                    vehicleType: vehicle!.vehicleType,
                    date: day,
                    plateOrigin: vehicle!.plateOrigin,
                  );
                  // ✅ Detectar si la ciudad tiene horarios por origen
                  final restriction = cityRule!.restrictionFor(
                    vehicle!.vehicleType,
                  );
                  final hasMultiOrigin =
                      restriction.timeRangesByOrigin.length > 1;
                  return Expanded(
                    child: DayChip(
                      date: day,
                      result: result,
                      hasMultipleOrigins: hasMultiOrigin,
                    ),
                  );
                }).toList(),
              ),
            ),
          if (cityRule == null || vehicle == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Sin información de pico y placa',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
