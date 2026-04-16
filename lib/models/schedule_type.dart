enum ScheduleType {
  fixedWeekly, // Bogotá: lunes siempre [9,0]
  rotatingWeekly, // Pasto: cada semana rotan los dígitos
  rotatingDaily, // Manizales: cada día laboral rotan
  rotatingWeeklyDaily, // semana rota + dentro de semana avanza por día
  rotatingAlternating,
  rotatingDailyByGroup, // rotación por día y agrupación de dígitos en un día (Armenia)
  fixedWeeklyWithRotatingSaturday, // reglas fijas con sábado rotativo
  rotatingWeeklyDailyWithWeekend,
}
