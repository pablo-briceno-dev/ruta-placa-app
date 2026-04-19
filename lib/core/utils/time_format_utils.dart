import 'package:flutter/material.dart';

// Formatea un TimeOfDay respetando la configuración del dispositivo
// Si el dispositivo usa 24h -> "14:30"
// Si usa 12h -> "2:30 pm"
String formatTimeOfDay(BuildContext context, TimeOfDay time) {
  final use24h = MediaQuery.alwaysUse24HourFormatOf(context);

  if (use24h) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  } else {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final pm = time.period == DayPeriod.pm ? 'pm' : 'am';
    return '$h:$m $pm';
  }
}

// Igual pero sin contexto - útil en lógica fuera de widgets
// Recibe el flag directamente
String formatTimeOfDayRaw(TimeOfDay time, {required bool use24h}) {
  if (use24h) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  } else {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.pm ? 'pm' : 'am';
    return '$h:$m $period';
  }
}