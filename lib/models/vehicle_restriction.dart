import 'package:flutter/material.dart';
import 'package:ruta_placa/data/holidays_co.dart' as holidays;
import 'package:ruta_placa/models/holiday_behavior.dart';
import 'package:ruta_placa/models/plate_origin.dart';
import 'package:ruta_placa/models/plates_result.dart';
import 'package:ruta_placa/models/rotation_rule.dart';
import 'package:ruta_placa/models/schedule_type.dart';
import 'package:ruta_placa/models/time_range.dart';

class VehicleRestriction {
  final ScheduleType scheduleType;
  final Map<int, List<int>> schedule; // Solo para scheduleType = fixedWeekly
  final RotationRule? rotation; // Solo para rotatingWeekly / rotatingDaily
  final TimeOfDay morningStart;
  final TimeOfDay morningEnd;
  final TimeOfDay? afternoonStart;
  final TimeOfDay? afternoonEnd;
  final String?
  note; // Nota informativa para mostrar en UI Ej: "Solo en corredores viales principales"
  final HolidayBehavior holidayBehavior;

  /// Franjas horarias — reemplaza morning/afternoon cuando hay 3+
  /// Si está vacío se usan morningStart/morningEnd como fallback
  final List<TimeRange> timeRanges;

  /// Franjas distintas por origen de placa
  /// Si está vacío aplica timeRanges para todas las placas
  final Map<PlateOrigin, List<TimeRange>> timeRangesByOrigin;

  /// Si es true, el último día hábil calendario del mes
  /// aplica restricción para TODOS los dígitos,
  /// independientemente del scheduleType
  final bool endOfMonthAllDigits;

  const VehicleRestriction({
    required this.scheduleType,
    required this.schedule,
    required this.morningStart,
    required this.morningEnd,
    this.rotation,
    this.afternoonStart,
    this.afternoonEnd,
    this.note,
    this.holidayBehavior = HolidayBehavior.noRestriction,
    this.timeRanges = const [],
    this.timeRangesByOrigin = const {},
    this.endOfMonthAllDigits = false,
  });

  bool get hasRestriction =>
      schedule.isNotEmpty ||
      rotation != null ||
      scheduleType == ScheduleType.fixedWeeklyWithRotatingSaturday;

  List<List<int>> getPlates() {
    if (schedule.isNotEmpty) return schedule.values.toList();
    if (rotation != null) return rotation!.rotationCycle;
    return [];
  }

  // ---- Metodo principal -----------------------
  // Llamado desde el calculador con contexto de festivo
  PlatesResult platesForDayWithContext({
    required DateTime date,
    required bool isHoliday,
  }) {
    switch (scheduleType) {
      case ScheduleType.fixedWeekly:
        if (!_weekdayApplies(date)) return PlatesResult.empty();
        return PlatesResult(plates: schedule[date.weekday] ?? []);

      case ScheduleType.rotatingWeekly:
        if (!_weekdayApplies(date)) return PlatesResult.empty();
        return PlatesResult(plates: _rotatingWeeklyPlates(date));

      case ScheduleType.rotatingDaily:
        if (!_weekdayApplies(date)) return PlatesResult.empty();
        return PlatesResult(plates: _rotatingDailyPlates(date));

      case ScheduleType.rotatingWeeklyDaily:
        if (!_weekdayApplies(date)) return PlatesResult.empty();
        final idx = _rotatingWeeklyDailyIndex(date);
        return PlatesResult(plates: rotation!.rotationCycle[idx]);

      case ScheduleType.rotatingAlternating:
        return _alternatingResult(date: date, isHoliday: isHoliday);

      case ScheduleType.rotatingDailyByGroup:
        if (!_weekdayApplies(date)) return PlatesResult.empty();
        return _rotatingDailyByGroupIndex(date);

      case ScheduleType.fixedWeeklyWithRotatingSaturday:
        return _fixedWeeklyWithRotatingSaturdayResult(date);

      case ScheduleType.rotatingWeeklyDailyWithWeekend:
        return _rotatingWeeklyDailyWithWeekendResult(date);

      case ScheduleType.isoWeekWeekendWithHolidayBridge:
        return _isoWeekWeekendResult(date);
    }
  }

  // Devuelve los dígitos restringidos para una fecha dada
  List<int> platesForDay(DateTime date) {
    return platesForDayWithContext(
      date: date,
      isHoliday: holidays.isHoliday(date),
    ).plates;
  }

  // ----- Rotación semanal -----------------
  // Calcula en qué semana del ciclo cae la fecha
  List<int> _rotatingWeeklyPlates(DateTime date) {
    if (rotation == null) return [];

    // Inicio de la semana (lunes) de cyclesStartDate
    final startMonday = _mondayOf(rotation!.cycleStartDate);
    // Inicio de la semana (lunes) de date
    final dateMonday = _mondayOf(date);

    final weeksDiff = dateMonday.difference(startMonday).inDays ~/ 7;
    if (weeksDiff < 0) return [];

    final cycleIndex = weeksDiff % rotation!.cycleLength;
    return rotation!.rotationCycle[cycleIndex];
  }

  // ------ Rotación diaria -------------------
  // Cuenta solo días laborales desde cycleStartDate
  List<int> _rotatingDailyPlates(DateTime date) {
    if (rotation == null) return [];

    int laboralDays = 0;
    DateTime cursor = rotation!.cycleStartDate;

    // Contar días laborales entre cycleStartDate y date (inclusive)
    while (!_isSameDay(cursor, date)) {
      if (cursor.isAfter(date)) return [];

      final isWeekday =
          cursor.weekday >= DateTime.monday &&
          cursor.weekday <= DateTime.friday;
      final cursorIsHoliday = holidays.isHoliday(cursor);

      if (isWeekday) {
        // ✅ Con countsButNoRestriction los festivos SÍ avanzan el ciclo
        if (!cursorIsHoliday ||
            holidayBehavior == HolidayBehavior.countsButNoRestriction ||
            holidayBehavior == HolidayBehavior.appliesNormal) {
          laboralDays++;
        }
      }
    }

    final cycleIndex = laboralDays % rotation!.cycleLength;
    return rotation!.rotationCycle[cycleIndex];
  }

  // --- rotating_weekly_daily -----------------
  int _rotatingWeeklyDailyIndex(DateTime date) {
    if (rotation == null) return 0;
    final startMonday = _mondayOf(rotation!.cycleStartDate);
    final dateMonday = _mondayOf(date);
    final weeksDiff = dateMonday.difference(startMonday).inDays ~/ 7;
    if (weeksDiff < 0) return 0;
    final daysFromMonday = rotation!.weekdaysApply
        .where((wd) => wd < date.weekday)
        .length;
    // El lunes de la semana N empieza en índice N (no N*5)
    // Dentro de la semana avanza día a día
    return (weeksDiff + daysFromMonday) % rotation!.rotationCycle.length;
  }

  // ----- rotating_alternating (Bogota) -----------------
  PlatesResult _alternatingResult({
    required DateTime date,
    required bool isHoliday,
  }) {
    if (rotation == null) return PlatesResult.empty();
    final weekday = date.weekday;
    // Sabado normal -> no aplica
    if (weekday == DateTime.saturday) return PlatesResult.empty();
    // Domingo -> solo aplica si el viernes de esa semana fue festivo
    if (weekday == DateTime.sunday) {
      final fridayOfWeek = date.subtract(const Duration(days: 2));
      final fridayWasHoliday = holidays.isHoliday(fridayOfWeek);
      return fridayWasHoliday ? PlatesResult.all() : PlatesResult.empty();
    }
    // Festivo viernes -> no aplica pico (el domingo sí, pero eso se
    // maneja en el caso domingo de arriba)
    if (isHoliday && weekday == DateTime.friday) {
      return PlatesResult.empty();
    }
    // Festivo lunes-jueves -> aplica para TODOS, NO avanza el ciclo
    if (isHoliday) return PlatesResult.all();
    // Dia laboral normal -> calcular índice alternante
    final index = _alternatingIndex(date);
    return PlatesResult(plates: rotation!.rotationCycle[index]);
  }

  // Cuenta días laborales normales (sin festivos) desde cyclesStartDate
  // Los festivos NO avanzan el índice
  int _alternatingIndex(DateTime date) {
    if (rotation == null) return 0;
    if (_isSameDay(rotation!.cycleStartDate, date)) return 0;

    int laboralCount = 0;
    DateTime cursor = rotation!.cycleStartDate.add(const Duration(days: 1));

    // Incluir 'date' en el loop para tratarlo igual que los demás días
    while (!cursor.isAfter(date)) {
      final isWeekday = cursor.weekday <= DateTime.friday;
      final cursorIsHoliday = holidays.isHoliday(cursor);

      if (isWeekday && !cursorIsHoliday) {
        // Si es lunes y el viernes anterior fue festivo → no avanza
        if (cursor.weekday == DateTime.monday) {
          final fridayBefore = cursor.subtract(const Duration(days: 3));
          final fridayBeforeHoliday = holidays.isHoliday(fridayBefore);
          if (!fridayBeforeHoliday) laboralCount++;
          // Si el viernes fue festivo, no sumamos → el índice se mantiene
        } else {
          laboralCount++;
        }
      }

      cursor = cursor.add(const Duration(days: 1));
    }

    return laboralCount % rotation!.rotationCycle.length;
  }

  // ----- rotating_daily_by_group -----------------
  PlatesResult _rotatingDailyByGroupIndex(DateTime date) {
    if (rotation == null) return PlatesResult.empty();
    // Contar días calendario desde cycleStartDate hasta date (inclusive)
    // Cada día normal avanza 1 posición
    // Cada domingo avanza 2 posiciones (agrupa actual + siguiente)
    // Por tanto debemos simular el avance día a día
    final cycleLen = rotation!.rotationCycle.length;
    int position = 0;
    DateTime cursor = rotation!.cycleStartDate;

    while (!_isSameDay(cursor, date)) {
      if (cursor.isAfter(date)) return PlatesResult.empty();
      if (rotation!.groupDays.isNotEmpty &&
          (rotation!.groupDays.contains(cursor.weekday) ||
              cursor.weekday == DateTime.sunday)) {
        position =
            (position + rotation!.groupDigits) % cycleLen; // domingo consume 2
      } else {
        position = (position + 1) % cycleLen; // día normal consume 1
      }

      cursor = cursor.add(const Duration(days: 1));
    }
    // En el día actual devolver los dígitos
    final current = rotation!.rotationCycle[position];

    if (rotation!.groupDays.isNotEmpty &&
        (rotation!.groupDays.contains(cursor.weekday) ||
            cursor.weekday == DateTime.sunday)) {
      // Domingo o día de agrupación: agrupar posición actual + siguiente
      final next = rotation!
          .rotationCycle[(position + (rotation!.groupDigits - 1)) % cycleLen];
      return PlatesResult(plates: [...current, ...next]);
    }

    return PlatesResult(plates: current);
  }

  // ----- fixed_weekly_with_rotating_saturday -----------------
  PlatesResult _fixedWeeklyWithRotatingSaturdayResult(DateTime date) {
    // Lunes a viernes → schedule fijo
    if (date.weekday != DateTime.saturday) {
      if (!schedule.containsKey(date.weekday)) return PlatesResult.empty();
      return PlatesResult(plates: schedule[date.weekday] ?? []);
    }

    // Sábado → rotar semanalmente usando rotation
    if (rotation == null) return PlatesResult.empty();

    final startMonday = _mondayOf(rotation!.cycleStartDate);
    final dateMonday = _mondayOf(date); // lunes de la semana del sábado
    final weeksDiff = dateMonday.difference(startMonday).inDays ~/ 7;
    if (weeksDiff < 0) return PlatesResult.empty();

    final index = weeksDiff % rotation!.rotationCycle.length;
    return PlatesResult(plates: rotation!.rotationCycle[index]);
  }

  // ----- rotating_weekly_daily_with_weekend -----------------
  PlatesResult _rotatingWeeklyDailyWithWeekendResult(DateTime date) {
    if (rotation == null) return PlatesResult.empty();

    final weekday = date.weekday;

    // ── Sábado y domingo ────────────────────────────────
    // Toman el índice del lunes de la SIGUIENTE semana
    // pero solo un dígito del grupo
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      // Lunes de la semana siguiente
      final daysToNextMonday = weekday == DateTime.saturday ? 2 : 1;
      final nextMonday = date.add(Duration(days: daysToNextMonday));

      final mondayIndex = _weeklyDailyIndex(nextMonday);
      final group = rotation!.rotationCycle[mondayIndex];

      if (group.isEmpty) return PlatesResult.empty();

      // Sábado → primer dígito, domingo → segundo dígito
      if (weekday == DateTime.saturday) {
        return PlatesResult(plates: [group[0]]);
      } else {
        // Si el grupo solo tiene un dígito, domingo no aplica
        if (group.length < 2) return PlatesResult.empty();
        return PlatesResult(plates: [group[1]]);
      }
    }

    // ── Lunes a viernes → grupo completo ────────────────
    final index = _weeklyDailyIndex(date);
    return PlatesResult(plates: rotation!.rotationCycle[index]);
  }

  /// Mismo cálculo que _rotatingWeeklyDailyIndex
  /// separado para poder reutilizarlo con nextMonday
  int _weeklyDailyIndex(DateTime date) {
    if (rotation == null) return 0;
    final startMonday = _mondayOf(rotation!.cycleStartDate);
    final dateMonday = _mondayOf(date);
    final weeksDiff = dateMonday.difference(startMonday).inDays ~/ 7;
    if (weeksDiff < 0) return 0;
    final daysFromMonday = rotation!.weekdaysApply
        .where((wd) => wd < date.weekday)
        .length;
    return (weeksDiff + daysFromMonday) % rotation!.rotationCycle.length;
  }

  // ----- iso_week_weekend -----------------
  PlatesResult _isoWeekWeekendResult(DateTime date) {
    if (rotation == null) return PlatesResult.empty();

    final weekday = date.weekday;

    // ── Lunes a viernes → no aplica ─────────────────────
    if (weekday >= DateTime.monday &&
        weekday <= DateTime.friday &&
        !holidays.isHoliday(date)) {
      return PlatesResult.empty();
    }

    // ── Verificar si es parte de un puente festivo ───────
    // Un puente = sábado + domingo + lunes festivo
    // O lunes festivo solo
    // O viernes festivo + fin de semana (puente largo)
    final bridgePlates = _getBridgePlates(date);
    if (bridgePlates != null) {
      // En puente: restringidos = todos EXCEPTO los que circulan
      final circulan = bridgePlates;
      final restringidos = List.generate(
        10,
        (i) => i,
      ).where((d) => !circulan.contains(d)).toList();
      return PlatesResult(plates: restringidos);
    }

    // ── Fin de semana normal → ISO week par/impar ────────
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      final isoWeek = _isoWeekNumber(date);
      if (isoWeek.isOdd) {
        return PlatesResult(plates: [1, 3, 5, 7, 9]); // impares
      } else {
        return PlatesResult(plates: [0, 2, 4, 6, 8]); // pares
      }
    }

    // ── Festivo solo (sin puente) ────────────────────────
    // Aplicar ISO week igual que el fin de semana
    if (holidays.isHoliday(date)) {
      final isoWeek = _isoWeekNumber(date);
      if (isoWeek.isOdd) {
        return PlatesResult(plates: [1, 3, 5, 7, 9]);
      } else {
        return PlatesResult(plates: [0, 2, 4, 6, 8]);
      }
    }

    return PlatesResult.empty();
  }

  /// Obtiene los dígitos que CIRCULAN en el puente
  /// Si la fecha no es parte de un puente, retorna null
  List<int>? _getBridgePlates(DateTime date) {
    if (rotation == null) return null;

    // Detectar si la fecha forma parte de un puente:
    // Sáb-Dom-Lun(festivo) o Vie(festivo)-Sáb-Dom
    final weekday = date.weekday;
    DateTime? mondayFestivo;

    if (weekday == DateTime.monday && holidays.isHoliday(date)) {
      mondayFestivo = date;
    } else if (weekday == DateTime.sunday) {
      final nextMonday = date.add(const Duration(days: 1));
      if (holidays.isHoliday(nextMonday)) {
        mondayFestivo = nextMonday;
      }
    } else if (weekday == DateTime.saturday) {
      final nextMonday = date.add(const Duration(days: 2));
      if (holidays.isHoliday(nextMonday)) {
        mondayFestivo = nextMonday;
      }
    }

    if (mondayFestivo == null) return null;

    // Calcular qué número de puente es este
    // desde el cycleStartDate
    final bridgeIndex = _bridgeIndexFor(mondayFestivo);
    if (bridgeIndex < 0) return null;

    // Los dígitos que circulan avanzan 3 cada puente
    // startDigit = rotation!.bridgeStartDigit (del JSON)
    final startDigit = rotation!.bridgeStartDigit; // ej: 6 para abr-2026
    final startPosition = startDigit;

    final position = (startPosition + bridgeIndex * 3) % 10;
    return [position % 10, (position + 1) % 10, (position + 2) % 10];
  }

  /// Cuenta cuántos lunes festivos hay entre
  /// cycleStartDate y el lunes festivo dado
  int _bridgeIndexFor(DateTime mondayFestivo) {
    if (rotation?.cycleStartDate == null) return -1;

    int count = 0;
    DateTime cursor = rotation!.cycleStartDate;

    while (cursor.isBefore(mondayFestivo)) {
      if (cursor.weekday == DateTime.monday && holidays.isHoliday(cursor)) {
        count++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    // El índice 0 es el cycleStartDate mismo
    return count;
  }

  /// Calcula el número de semana ISO
  int _isoWeekNumber(DateTime date) {
    // Semana ISO: la semana que contiene el primer jueves del año
    final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
    final firstDayOfYear = DateTime(thursday.year, 1, 1);
    final firstThursday = firstDayOfYear.add(
      Duration(days: (DateTime.thursday - firstDayOfYear.weekday + 7) % 7),
    );
    return ((thursday.difference(firstThursday).inDays) ~/ 7) + 1;
  }

  // ----- Helpers -----------------
  bool _weekdayApplies(DateTime date) {
    switch (scheduleType) {
      case ScheduleType.fixedWeekly:
        return schedule.containsKey(date.weekday);
      case ScheduleType.rotatingWeekly:
      case ScheduleType.rotatingDaily:
      case ScheduleType.rotatingWeeklyDaily:
      case ScheduleType.rotatingAlternating:
      case ScheduleType.rotatingDailyByGroup:
      case ScheduleType.isoWeekWeekendWithHolidayBridge:
        // Para rotación: aplica si el weekday está en weekdaysApply
        if (rotation == null) return false;
        return rotation!.weekdaysApply.contains(date.weekday);
      case ScheduleType.fixedWeeklyWithRotatingSaturday:
        // Lunes a viernes → verificar en schedule
        if (date.weekday != DateTime.saturday) {
          return schedule.containsKey(date.weekday);
        }
        // Sábado → verificar que rotation existe
        return rotation != null;
      case ScheduleType.rotatingWeeklyDailyWithWeekend:
        // Aplica todos los días incluyendo fines de semana
        return true;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _mondayOf(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // --- fromJson ------------------------
  factory VehicleRestriction.fromJson(Map<String, dynamic> json) {
    final typeStr = json['scheduleType'] as String;
    final type = switch (typeStr) {
      'fixed_weekly' => ScheduleType.fixedWeekly,
      'rotating_weekly' => ScheduleType.rotatingWeekly,
      'rotating_daily' => ScheduleType.rotatingDaily,
      'rotating_weekly_daily' => ScheduleType.rotatingWeeklyDaily,
      'rotating_alternating' => ScheduleType.rotatingAlternating,
      'rotating_daily_by_group' => ScheduleType.rotatingDailyByGroup,
      'fixed_weekly_with_rotating_saturday' =>
        ScheduleType.fixedWeeklyWithRotatingSaturday,
      'rotating_weekly_daily_with_weekend' =>
        ScheduleType.rotatingWeeklyDailyWithWeekend,
      _ => ScheduleType.fixedWeekly,
    };

    Map<int, List<int>> schedule = {};
    if (type == ScheduleType.fixedWeekly) {
      final raw = json['schedule'] as Map<String, dynamic>? ?? {};
      schedule = raw.map(
        (key, value) => MapEntry(int.parse(key), List<int>.from(value as List)),
      );
    }

    RotationRule? rotation;
    if (type != ScheduleType.fixedWeekly && json['rotation'] != null) {
      rotation = RotationRule.fromJson(
        json['rotation'] as Map<String, dynamic>,
      );
    }

    // Parsear holidayBehavior del JSON
    final holidayStr = json['holidayBehavior'] as String? ?? 'no_restriction';
    final holidayBehavior = switch (holidayStr) {
      'no_restriction' => HolidayBehavior.noRestriction,
      'applies_normal' => HolidayBehavior.appliesNormal,
      'custom_bogota' => HolidayBehavior.customBogota,
      'applies_to_all' => HolidayBehavior.appliesToAll,
      'counts_but_no_restriction' => HolidayBehavior.countsButNoRestriction,
      'handled_by_schedule_type'    => HolidayBehavior.handledByScheduleType,
      _ => HolidayBehavior.noRestriction,
    };
    // Parsear timeRanges simples
    final rawRanges = json['timeRanges'] as List<dynamic>? ?? [];
    final timeRanges = rawRanges
        .map((r) => TimeRange.fromJson(r as Map<String, dynamic>))
        .toList();

    // Parsear timeRangesByOrigin
    final rawByOrigin =
        json['timeRangesByOrigin'] as Map<String, dynamic>? ?? {};
    final timeRangesByOrigin = <PlateOrigin, List<TimeRange>>{};

    rawByOrigin.forEach((key, value) {
      final origin = switch (key) {
        'metropolitan' => PlateOrigin.metropolitan,
        'nationalOrForeign' => PlateOrigin.nationalOrForeign,
        _ => PlateOrigin.any,
      };
      final ranges = (value as List)
          .map((r) => TimeRange.fromJson(r as Map<String, dynamic>))
          .toList();
      timeRangesByOrigin[origin] = ranges;
    });

    return VehicleRestriction(
      scheduleType: type,
      schedule: schedule,
      rotation: rotation,
      morningStart: _parseTime(json['morningStart']),
      morningEnd: _parseTime(json['morningEnd']),
      afternoonStart: json['afternoonStart'] != null
          ? _parseTime(json['afternoonStart'])
          : null,
      afternoonEnd: json['afternoonEnd'] != null
          ? _parseTime(json['afternoonEnd'])
          : null,
      note: json['note'] as String?,
      holidayBehavior: holidayBehavior,
      timeRanges: timeRanges,
      timeRangesByOrigin: timeRangesByOrigin,
      endOfMonthAllDigits: (json['endOfMonthAllDigits'] as bool?) ?? false,
    );
  }

  // Sin restricción para este tipo de vehículo
  static const none = VehicleRestriction(
    scheduleType: ScheduleType.fixedWeekly,
    schedule: {},
    morningStart: TimeOfDay(hour: 0, minute: 0),
    morningEnd: TimeOfDay(hour: 0, minute: 0),
    holidayBehavior: HolidayBehavior.noRestriction,
    endOfMonthAllDigits: false,
  );

  // "07:30" → TimeOfDay(hour: 7, minute: 30)
  static TimeOfDay _parseTime(String raw) {
    final parts = raw.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
