import 'package:flutter/material.dart';
import 'package:ruta_placa/data/colors_plates.dart';
import 'package:ruta_placa/logic/calendar_generator.dart';
import 'package:ruta_placa/widgets/calendar/split_background.dart';

class BuildDay extends StatelessWidget {
  final DateTime day;
  final CalendarDay calendarDay;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  const BuildDay({
    super.key,
    required this.day,
    required this.calendarDay,
    this.isToday = false,
    this.isSelected = false,
    this.isOutside = false,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isOutside ? 0.3 : 1.0;
    final colors = calendarDay.colors;

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              )
            : colors.length == 1 &&
                  (colors[0] == Colors.red || colors[0] == holidayColor)
            ? BoxDecoration(
                border: Border.all(color: colors[0], width: 2),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Fondo — normal, dividido o vacío
              if (colors.length >= 2)
                SplitBackground(colors: colors)
              else if (colors.length == 1)
                Container(
                  color: (colors[0] == Colors.red || colors[0] == holidayColor)
                      ? Colors.black.withValues(alpha: 0.75)
                      : colors[0].withValues(alpha: 0.75),
                )
              else
                Container(color: Colors.transparent),

              // Número del día
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isToday || isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: colors.isNotEmpty
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // Borde especial para hoy
              if (isToday)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
