import 'package:ruta_placa/models/pico_placa_result.dart';

extension RestrictionReasonExt on RestrictionReason {
  String get shortMessage {
    switch (this) {
      case RestrictionReason.normal:
        return 'Día laboral normal';
      case RestrictionReason.holidayAll:
        return 'Festivo — Aplica para todos los dígitos';
      case RestrictionReason.holidaySundayAll:
        return 'Domingo compensatorio — Aplica para todos';
      case RestrictionReason.holiday:
        return 'Festivo — No aplica';
      case RestrictionReason.weekend:
        return 'Fin de semana — No aplica';
      case RestrictionReason.noRule:
        return 'Sin restricción';
    }
  }
}
