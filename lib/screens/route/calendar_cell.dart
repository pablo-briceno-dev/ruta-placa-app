import 'package:flutter/material.dart';

class CalendarCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool hasRestriction;
  final bool appliesToAll;
  final List<int> restrictedPlates;

  const CalendarCell({
    required this.day,
    required this.isToday,
    this.hasRestriction = false,
    this.appliesToAll = false,
    this.restrictedPlates = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color bg;
    if (appliesToAll) {
      bg = Colors.orange.withValues(alpha: 0.2);
    } else if (hasRestriction) {
      bg = colorScheme.error.withValues(alpha: 0.15);
    } else {
      bg = Colors.green.withValues(alpha: 0.12);
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}
