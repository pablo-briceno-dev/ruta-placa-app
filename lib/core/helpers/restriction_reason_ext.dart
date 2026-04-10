import 'package:ruta_placa/models/pico_placa_result.dart';

extension RestrictionReasonExt on RestrictionReason {
  String get shortMessage {
    switch (this) {
      case RestrictionReason.normal:
        return 'Día laboral normal';
      case RestrictionReason.holidayAll:
        return 'Festivo — aplica para todos los dígitos';
      case RestrictionReason.holidaySundayAll:
        return 'Domingo compensatorio — aplica para todos';
      case RestrictionReason.holidayFriday:
        return 'Festivo — no aplica';
      case RestrictionReason.weekend:
        return 'Fin de semana — no aplica';
      case RestrictionReason.noRule:
        return 'Sin restricción';
    }
  }
}
