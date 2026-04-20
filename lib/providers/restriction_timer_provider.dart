import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ruta_placa/models/time_range.dart';

enum TimerStatus { active, upcoming, allDay, free }

class TimerState {
  final TimerStatus status;
  final Duration remaining;
  final TimeRange currentRange;
  final TimeRange? nextRange;

  const TimerState({
    required this.status,
    required this.remaining,
    required this.currentRange,
    this.nextRange,
  });

  /// Color semáforo según el estado
  Color borderColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      TimerStatus.active => scheme.error, // rojo
      TimerStatus.upcoming => Colors.orange.shade700, // amarillo
      TimerStatus.allDay => scheme.error, // rojo
      TimerStatus.free => scheme.primary, // verde
    };
  }
}

class RestrictionTimerNotifier extends StateNotifier<TimerState?> {
  RestrictionTimerNotifier() : super(null);

  Timer? _timer;

  void start({required bool isRestricted, required List<TimeRange> ranges}) {
    _timer?.cancel();
    _tick(isRestricted, ranges);

    final isAllDay =
        ranges.length == 1 &&
        ranges.first.start.hour == 0 &&
        ranges.first.start.minute == 0 &&
        ranges.first.end.hour == 23 &&
        ranges.first.end.minute == 59;

    if (!isAllDay) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _tick(isRestricted, ranges),
      );
    }
  }

  void _tick(bool isRestricted, List<TimeRange> ranges) {
    state = compute(isRestricted, ranges);
  }

  static TimerState compute(bool isRestricted, List<TimeRange> ranges) {
    final emptyRange = TimeRange(
      start: const TimeOfDay(hour: 0, minute: 0),
      end: const TimeOfDay(hour: 0, minute: 0),
    );

    if (!isRestricted) {
      return TimerState(
        status: TimerStatus.free,
        remaining: Duration.zero,
        currentRange: ranges.isNotEmpty ? ranges.first : emptyRange,
      );
    }

    final isAllDay =
        ranges.length == 1 &&
        ranges.first.start.hour == 0 &&
        ranges.first.start.minute == 0 &&
        ranges.first.end.hour == 23 &&
        ranges.first.end.minute == 59;

    if (isAllDay) {
      return TimerState(
        status: TimerStatus.allDay,
        remaining: Duration.zero,
        currentRange: ranges.first,
      );
    }

    final now = DateTime.now();

    for (int i = 0; i < ranges.length; i++) {
      final r = ranges[i];
      final start = _dt(r.start);
      final end = _dt(r.end);

      if (now.isBefore(start)) {
        return TimerState(
          status: TimerStatus.upcoming,
          remaining: start.difference(now),
          currentRange: r,
          nextRange: i + 1 < ranges.length ? ranges[i + 1] : null,
        );
      }

      if (now.isAfter(start) && now.isBefore(end)) {
        return TimerState(
          status: TimerStatus.active,
          remaining: end.difference(now),
          currentRange: r,
          nextRange: i + 1 < ranges.length ? ranges[i + 1] : null,
        );
      }
    }

    final first = ranges.first;
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day + 1,
      first.start.hour,
      first.start.minute,
    );
    return TimerState(
      status: TimerStatus.upcoming,
      remaining: tomorrow.difference(now),
      currentRange: first,
    );
  }

  static DateTime _dt(TimeOfDay t) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, t.hour, t.minute);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final restrictionTimerProvider =
    StateNotifierProvider.family<RestrictionTimerNotifier, TimerState?, String>(
      (ref, plate) => RestrictionTimerNotifier(),
    );
