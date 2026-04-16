import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ruta_placa/models/plate_origin.dart';
import 'package:ruta_placa/models/time_range.dart';
import 'package:ruta_placa/widgets/schedule_modal.dart';

enum _TimerStatus { active, upcoming, allDay, free }

class _TimerState {
  final _TimerStatus status;
  final Duration remaining;
  final TimeRange currentRange;
  final TimeRange? nextRange;

  const _TimerState({
    required this.status,
    required this.remaining,
    required this.currentRange,
    this.nextRange,
  });
}

class RestrictionTimerWidget extends StatefulWidget {
  final bool isRestricted;
  final List<TimeRange> ranges;
  final Map<PlateOrigin, List<TimeRange>>? rangesByOrigin;

  const RestrictionTimerWidget({
    super.key,
    required this.isRestricted,
    required this.ranges,
    this.rangesByOrigin,
  });

  @override
  State<RestrictionTimerWidget> createState() => _RestrictionTimerWidgetState();
}

class _RestrictionTimerWidgetState extends State<RestrictionTimerWidget> {
  _TimerState? _state;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _update();
    if (!_isAllDay()) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isAllDay() =>
      widget.ranges.length == 1 &&
      widget.ranges.first.start.hour == 0 &&
      widget.ranges.first.start.minute == 0 &&
      widget.ranges.first.end.hour == 23 &&
      widget.ranges.first.end.minute == 59;

  void _update() {
    final state = _computeState(widget.ranges);
    if (mounted) setState(() => _state = state);
  }

  _TimerState _computeState(List<TimeRange> ranges) {
    if (!widget.isRestricted) {
      final first = ranges.isNotEmpty ? ranges.first : null;
      return _TimerState(
        status: _TimerStatus.free,
        remaining: Duration.zero,
        currentRange:
            first ??
            TimeRange(
              start: const TimeOfDay(hour: 0, minute: 0),
              end: const TimeOfDay(hour: 0, minute: 0),
            ),
      );
    }

    if (_isAllDay()) {
      return _TimerState(
        status: _TimerStatus.allDay,
        remaining: Duration.zero,
        currentRange: ranges.first,
      );
    }

    final now = DateTime.now();

    for (int i = 0; i < ranges.length; i++) {
      final r = ranges[i];
      final start = _toDateTime(r.start);
      final end = _toDateTime(r.end);

      if (now.isBefore(start)) {
        return _TimerState(
          status: _TimerStatus.upcoming,
          remaining: start.difference(now),
          currentRange: r,
          nextRange: i + 1 < ranges.length ? ranges[i + 1] : null,
        );
      }

      if (now.isAfter(start) && now.isBefore(end)) {
        return _TimerState(
          status: _TimerStatus.active,
          remaining: end.difference(now),
          currentRange: r,
          nextRange: i + 1 < ranges.length ? ranges[i + 1] : null,
        );
      }
    }

    // Todos los rangos pasaron → mostrar cuenta para mañana
    final first = ranges.first;
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day + 1,
      first.start.hour,
      first.start.minute,
    );
    return _TimerState(
      status: _TimerStatus.upcoming,
      remaining: tomorrow.difference(now),
      currentRange: first,
    );
  }

  DateTime _toDateTime(TimeOfDay t) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, t.hour, t.minute);
  }

  @override
  Widget build(BuildContext context) {
    if (_state == null) return const SizedBox.shrink();
    final s = _state!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasMultiOrigin =
        widget.rangesByOrigin != null && widget.rangesByOrigin!.length > 1;

    final Color badgeBg;
    final Color badgeBorder;
    final Color badgeText;
    final String label;
    final String timeStr;

    switch (s.status) {
      case _TimerStatus.active:
        badgeBg = scheme.error.withValues(alpha: 0.10);
        badgeBorder = scheme.error;
        badgeText = scheme.error;
        label = 'Termina en';
        timeStr = _format(s.remaining);
      case _TimerStatus.upcoming:
        badgeBg = Colors.orange.withValues(alpha: 0.10);
        badgeBorder = Colors.orange.shade700;
        badgeText = Colors.orange.shade800;
        label = 'Inicia en';
        timeStr = _format(s.remaining);
      case _TimerStatus.allDay:
        badgeBg = scheme.error.withValues(alpha: 0.10);
        badgeBorder = scheme.error;
        badgeText = scheme.error;
        label = 'Restricción';
        timeStr = 'Todo el día';
      case _TimerStatus.free:
        badgeBg = scheme.primary.withValues(alpha: 0.10);
        badgeBorder = scheme.primary;
        badgeText = scheme.primary;
        label = 'Sin pico';
        timeStr = 'Hoy libre';
    }

    return Row(
      children: [
        // Badge con countdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: badgeBg,
            border: Border.all(color: badgeBorder, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: badgeText,
                ),
              ),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize:
                      s.status == _TimerStatus.free ||
                          s.status == _TimerStatus.allDay
                      ? 13
                      : 18,
                  fontWeight: FontWeight.bold,
                  color: badgeText,
                ),
              ),
              if (s.status == _TimerStatus.active ||
                  s.status == _TimerStatus.upcoming)
                Text(
                  s.status == _TimerStatus.active
                      ? 'hasta las ${_formatTime(s.currentRange.end)}'
                      : 'a las ${_formatTime(s.currentRange.start)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: badgeText.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Info lateral
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rango actual
              Text(
                s.status == _TimerStatus.free
                    ? 'Sin restricción hoy'
                    : '${_formatTime(s.currentRange.start)}'
                          ' — ${_formatTime(s.currentRange.end)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              // Indicador de estado
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: s.status == _TimerStatus.active
                          ? scheme.error
                          : s.status == _TimerStatus.upcoming
                          ? Colors.orange
                          : scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _statusSubtitle(s),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: s.status == _TimerStatus.active
                            ? scheme.error
                            : scheme.onSurface.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Botón ver todos los horarios (solo si hay múltiples)
              if (hasMultiOrigin) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showScheduleModal(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 13,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ver todos los horarios',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _statusSubtitle(_TimerState s) {
    switch (s.status) {
      case _TimerStatus.active:
        return 'Restricción activa ahora';
      case _TimerStatus.upcoming:
        return s.nextRange != null
            ? 'Próximo: ${_formatTime(s.nextRange!.start)}'
            : 'Sin más franjas hoy';
      case _TimerStatus.allDay:
        return 'Aplica todo el día';
      case _TimerStatus.free:
        return 'Puedes circular libremente';
    }
  }

  // ── Modal de horarios múltiples ─────────────────────────
  void _showScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScheduleModal(
        rangesByOrigin: widget.rangesByOrigin!,
        isRestricted: widget.isRestricted,
      ),
    );
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final pm = t.period == DayPeriod.pm ? 'pm' : 'am';
    return '$h:$m $pm';
  }
}
