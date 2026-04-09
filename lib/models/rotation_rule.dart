class RotationRule {
  // Fecha desde la cual empieza a contar el ciclo
  final DateTime cycleStartDate;
  // Cuántas semanas (o días) dura un ciclo completo
  final int cycleLength;
  // Qué días de la semana aplica (1=lunes…5=viernes)
  final List<int> weekdaysApply;
  // Lista de grupos de dígitos que rotan en orden
  // Ej: [[1,2], [3,4], [5,6], [7,8],[9, 0]]
  final List<List<int>> rotationCycle;

  const RotationRule({
    required this.cycleStartDate,
    required this.cycleLength,
    required this.weekdaysApply,
    required this.rotationCycle,
  });

  factory RotationRule.fromJson(Map<String, dynamic> json) {
    return RotationRule(
      cycleStartDate: DateTime.parse(json['cycleStartDate']),
      // Lee cycleLengthDays si existe, si no cycleLengthWeeks
      cycleLength: json['cycleLengthDays'] ?? json['cycleLengthWeeks'] ?? 5,
      weekdaysApply: List<int>.from(json['weekdaysApply']),
      rotationCycle: (json['rotationCycle'] as List)
          .map((e) => List<int>.from(e as List))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'cycleStartDate': cycleStartDate.toIso8601String().split('T')[0],
    'cycleLengthWeeks': cycleLength,
    'weekdaysApply': weekdaysApply,
    'rotationCycle': rotationCycle,
  };
}
