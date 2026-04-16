enum HolidayBehavior {
  noRestriction, // Festivo = sin restricción (comportamiento por defecto)
  appliesNormal, // Festivo = aplica igual que un día laboral normal (el ciclo avanza normalmente)
  customBogota, // Festivo aplica solo si cae lunes (Bogotá) y el viernes festivo no aplica pero el domingo sí
  appliesToAll, // Festivo = aplica para TODOS los dígitos
  countsButNoRestriction, // ← nuevo: festivo avanza el ciclo pero no aplica
}
