import 'package:flutter/material.dart';

String formatTime(BuildContext context, TimeOfDay time) {
  final localizations = MaterialLocalizations.of(context);
  return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
}

DateTime toDateTime(TimeOfDay time) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, time.hour, time.minute);
}

Duration getRemainingTime(TimeOfDay endTime) {
  final now = DateTime.now();
  final end = toDateTime(endTime);
  return end.difference(now);
}

String formatDuration(Duration d) {
  if (d.isNegative) return 'Finalizado';

  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  } else {
    return '${minutes}m';
  }
}
