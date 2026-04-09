enum RestrictionReason {
  normal, // día laboral normal
  holidayAll, // festivo — aplica para todos los dígitos
  holidaySundayAll, // domingo compensatorio — aplica para todos
  holidayFriday, // festivo viernes — no aplica
  weekend, // fin de semana normal — no aplica
  noRule, // no hay regla para este tipo de vehículo
}

class PicoPlacaResult {
  final bool hasRestriction;
  final List<int> restrictedPlates;
  final RestrictionReason reason;
  final String? note;
  final bool appliesToAll; // true cuando es festivo especial

  const PicoPlacaResult({
    required this.hasRestriction,
    required this.restrictedPlates,
    required this.reason,
    this.note,
    this.appliesToAll = false,
  });
}