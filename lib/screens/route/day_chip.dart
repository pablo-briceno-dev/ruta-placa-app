import 'package:flutter/material.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';

class DayChip extends StatelessWidget {
  final DateTime date;
  final PicoPlacaResult result;

  const DayChip({super.key, required this.date, required this.result});

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
      label = result.restrictedPlates.join(' - ');
    } else {
      bgColor = Colors.green.withValues(alpha: 0.12);
      textColor = Colors.green.shade700;
      label = 'Libre';
    }

    final dayLabel = isToday ? 'Hoy' : _weekdayShort(date.weekday);

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
        children: [
          Text(
            dayLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _weekdayShort(int weekday) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }
}
