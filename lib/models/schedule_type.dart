enum ScheduleType {
  fixedWeekly, // Bogotá: lunes siempre [9,0]
  rotatingWeekly, // Pasto: cada semana rotan los dígitos
  rotatingDaily, // Manizales: cada día laboral rotan
  rotatingWeeklyDaily, // ← nuevo: semana rota + dentro de semana avanza por día
}
