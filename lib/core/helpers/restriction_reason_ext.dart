import 'package:ruta_placa/models/pico_placa_result.dart';

extension RestrictionReasonExt on RestrictionReason {
  String get shortMessage => switch (this) {
    RestrictionReason.normal => 'Día laboral',
    RestrictionReason.holidayAll => 'Festivo',
    RestrictionReason.holidaySundayAll => 'Domingo compensatorio',
    RestrictionReason.holidayFriday => 'Sin restricción',
    RestrictionReason.weekend => 'Fin de semana',
    RestrictionReason.noRule => 'Sin regla',
    RestrictionReason.endOfMonth => 'Fin de mes', // ← nuevo
  };
}
