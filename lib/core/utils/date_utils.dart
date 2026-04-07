import 'package:flutter/material.dart';

String formatTime(BuildContext context, TimeOfDay time) {
  final localizations = MaterialLocalizations.of(context);
  return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
}
