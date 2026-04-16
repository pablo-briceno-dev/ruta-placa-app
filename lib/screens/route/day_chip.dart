import 'package:flutter/material.dart';
import 'package:ruta_placa/core/helpers/digits_label.dart';
import 'package:ruta_placa/core/utils/date_utils.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';

class DayChip extends StatelessWidget {
  final DateTime date;
  final PicoPlacaResult result;
  final bool hasMultipleOrigins;

  const DayChip({
    super.key,
    required this.date,
    required this.result,
    this.hasMultipleOrigins = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final hasRestriction = result.hasRestriction;
    final appliesToAll = result.appliesToAll;
    final Color bgColor;
    final Color textColor;
    final String label;

    if (appliesToAll) {
      bgColor = Colors.orange.withValues(alpha: 0.15);
      textColor = Colors.orange.shade800;
      label = 'Todos';
    } else if (hasRestriction) {
      bgColor = theme.colorScheme.error.withValues(alpha: 0.12);
      textColor = theme.colorScheme.error;
      label = buildDigitsLabel(result.restrictedPlates);
    } else {
      bgColor = Colors.green.withValues(alpha: 0.12);
      textColor = Colors.green.shade700;
      label = 'Libre';
    }

    final dayLabel = isToday ? 'Hoy' : weekdayShortUtils(date.weekday);

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: textColor.withValues(alpha: 0.4), width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Día
          Text(
            dayLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          const SizedBox(height: 4),

          // Dígitos o estado
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // ✅ Indicador de horario múltiple por origen
          if (hasMultipleOrigins && result.hasRestriction) ...[
            const SizedBox(height: 3),
            Icon(
              Icons.info_outline,
              size: 11,
              color: textColor.withValues(alpha: 0.6),
            ),
          ],
        ],
      ),
    );
  }
}
