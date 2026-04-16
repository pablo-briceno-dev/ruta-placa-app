import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ruta_placa/core/helpers/restriction_reason_ext.dart';
import 'package:ruta_placa/core/utils/strings_utils.dart';
import 'package:ruta_placa/data/colors_plates.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/screens/calendar/digit_legend.dart';

class DayDetailPanel extends StatelessWidget {
  final DateTime date;
  final CityRule city;
  final Vehicle vehicle;
  final List<List<int>> plates;
  final bool isSytemColors;

  const DayDetailPanel({
    super.key,
    required this.date,
    required this.city,
    required this.vehicle,
    required this.plates,
    required this.isSytemColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final r = PicoPlacaCalculator.checkPlate(
      cityRule: city,
      plate: vehicle.plate,
      vehicleType: vehicle.vehicleType,
      date: date,
    );

    final borderColor = r.hasRestriction ? Colors.red : Colors.green;
    final iconData = r.hasRestriction
        ? Icons.block_rounded
        : Icons.check_circle_rounded;
    final iconColor = borderColor;

    final dateLabel = capitalizeString(
      DateFormat("EEE d MMMM", 'es_ES').format(date),
    );
    final statusLabel = r.hasRestriction
        ? 'Con restricción'
        : r.reason.shortMessage;
    final rotations = city.restrictions[vehicle.vehicleType]?.rotation;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono de estado
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 12),
            child: Icon(iconData, color: iconColor, size: 28),
          ),

          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fecha y estado
                Text(
                  '$dateLabel — $statusLabel',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),

                // Dígitos restringidos — solo si hay restricción
                if (r.restrictedPlates.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _buildDigitLegends(
                      r.restrictedPlates,
                      r.hasRestriction,
                    ),
                  ),
                ],

                // Nota extra para domingos con dos dígitos
                if (r.note != null &&
                    rotations != null &&
                    rotations.groupDays.contains(date.weekday)) ...[
                  const SizedBox(height: 6),
                  Text(
                    r.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Añadir este método en DayDetailPanel
  List<Widget> _buildDigitLegends(
    List<int> restrictedPlates,
    bool hasRestriction,
  ) {
    final userDigit = vehicle.lastDigit;

    // Rastrear índices de grupos ya añadidos para no duplicar
    final addedGroupIndexes = <int>{};
    final legends = <Widget>[];

    for (final digit in restrictedPlates) {
      final groupIndex = plates.indexWhere((group) => group.contains(digit));

      // Si el grupo ya fue añadido → saltar
      if (groupIndex >= 0 && addedGroupIndexes.contains(groupIndex)) {
        continue;
      }

      if (groupIndex >= 0) addedGroupIndexes.add(groupIndex);

      final group = groupIndex >= 0 ? plates[groupIndex] : [digit];
      final color = isSytemColors && groupIndex >= 0
          ? colorsPlates[groupIndex]
          : (hasRestriction ? Colors.red : Colors.green);

      legends.add(
        DigitLegend(digits: group, color: color, userDigit: userDigit),
      );
    }

    return legends;
  }
}
