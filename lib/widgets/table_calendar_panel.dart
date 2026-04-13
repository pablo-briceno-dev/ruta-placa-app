import 'package:flutter/material.dart';
import 'package:ruta_placa/logic/calendar_generator.dart';
import 'package:table_calendar/table_calendar.dart';

class TableCalendarPanel extends StatelessWidget {
  final List<CalendarDay> calDays;
  final DateTime focused;
  final DateTime selectedDate;
  final void Function(DateTime, DateTime)? onDaySelected;
  final void Function(DateTime)? onPageChanged;

  const TableCalendarPanel({
    super.key,
    required this.calDays,
    required this.focused,
    required this.selectedDate,
    this.onDaySelected,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateNow = DateTime.now();

    final firstAllowedMonth = DateTime(dateNow.year, dateNow.month);
    final lastAllowedMonth = DateTime(dateNow.year, dateNow.month + 3);
    final isLeftDisabled = isBeforeOrSameMonth(focused, firstAllowedMonth);
    final isRightDisabled = isAfterOrSameMonth(focused, lastAllowedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      child: TableCalendar(
        locale: 'es_CO',
        firstDay: DateTime.utc(dateNow.year, dateNow.month, dateNow.day),
        lastDay: DateTime.utc(dateNow.year, dateNow.month + 3, dateNow.day),
        focusedDay: focused,
        selectedDayPredicate: (d) => isSameDay(d, selectedDate),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (ctx, day, _) {
            final calDay = calDays.firstWhere(
              (d) => isSameDay(d.date, day),
              orElse: () => CalendarDay(date: day, status: DayStatus.noData),
            );

            final color = calDay.color;

            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: color != Colors.transparent
                    ? Border.all(color: color, width: 1.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontWeight: color != Colors.transparent
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: color != Colors.transparent ? color : null,
                ),
              ),
            );
          },
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,

          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: isLeftDisabled
                ? theme.colorScheme.inverseSurface.withValues(alpha: 0.5)
                : theme.colorScheme.inverseSurface,
          ),

          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: isRightDisabled
                ? theme.colorScheme.inverseSurface.withValues(alpha: 0.5)
                : theme.colorScheme.inverseSurface,
          ),
        ),
      ),
    );
  }

  bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  bool isBeforeOrSameMonth(DateTime a, DateTime b) {
    return a.year < b.year || (a.year == b.year && a.month <= b.month);
  }

  bool isAfterOrSameMonth(DateTime a, DateTime b) {
    return a.year > b.year || (a.year == b.year && a.month >= b.month);
  }
}
