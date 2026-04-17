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
  // Día o días donde se agrupan dígitos
  final List<int> groupDays;
  // Cuantos dígitos o index de rotationCycle se agrupan en cada día
  final int groupDigits;
  final int bridgeStartDigit; // dígito inicial del ciclo de puentes

  const RotationRule({
    required this.cycleStartDate,
    required this.cycleLength,
    required this.weekdaysApply,
    required this.rotationCycle,
    this.groupDays = const [],
    this.groupDigits = 0,
    this.bridgeStartDigit = 0,
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
      groupDays: (json['groupDays'] as List? ?? [])
          .map((e) => e as int)
          .toList(),
      groupDigits: json['groupDigits'] ?? 0,
      bridgeStartDigit: json['bridgeStartDigit'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'cycleStartDate': cycleStartDate.toIso8601String().split('T')[0],
    'cycleLengthWeeks': cycleLength,
    'weekdaysApply': weekdaysApply,
    'rotationCycle': rotationCycle,
    'groupDays': groupDays,
    'groupDigits': groupDigits,
  };
}
