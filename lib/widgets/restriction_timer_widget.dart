import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/models/plate_origin.dart';
import 'package:ruta_placa/models/time_range.dart';
import 'package:ruta_placa/providers/restriction_timer_provider.dart';
import 'package:ruta_placa/widgets/schedule_modal.dart';

class RestrictionTimerWidget extends ConsumerStatefulWidget {
  final bool isRestricted;
  final List<TimeRange> ranges;
  final Map<PlateOrigin, List<TimeRange>>? rangesByOrigin;
  final String? vehiclePlate;

  const RestrictionTimerWidget({
    super.key,
    required this.isRestricted,
    required this.ranges,
    this.rangesByOrigin,
    this.vehiclePlate,
  });

  @override
  ConsumerState<RestrictionTimerWidget> createState() =>
      _RestrictionTimerWidgetState();
}

class _RestrictionTimerWidgetState
    extends ConsumerState<RestrictionTimerWidget> {
  TimerState? _localState;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.vehiclePlate == null) {
      _startLocalTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLocalTimer() {
    _updateLocal();
    if (!_isAllDay()) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _updateLocal(),
      );
    }
  }

  void _updateLocal() {
    if (mounted) {
      setState(
        () => _localState = RestrictionTimerNotifier.compute(
          widget.isRestricted,
          widget.ranges,
        ),
      );
    }
  }

  bool _isAllDay() =>
      widget.ranges.length == 1 &&
      widget.ranges.first.start.hour == 0 &&
      widget.ranges.first.start.minute == 0 &&
      widget.ranges.first.end.hour == 23 &&
      widget.ranges.first.end.minute == 59;

  @override
  Widget build(BuildContext context) {
    // Si hay placa → usar el provider centralizado
    final TimerState? s = widget.vehiclePlate != null
        ? ref.watch(restrictionTimerProvider(widget.vehiclePlate!))
        : _localState;

    if (s == null) return const SizedBox.shrink();
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
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
      case TimerStatus.active:
        badgeBg = scheme.error.withValues(alpha: 0.10);
        badgeBorder = scheme.error;
        badgeText = scheme.error;
        label = 'Termina en';
        timeStr = _format(s.remaining);
      case TimerStatus.upcoming:
        badgeBg = Colors.orange.withValues(alpha: 0.10);
        badgeBorder = Colors.orange.shade700;
        badgeText = Colors.orange.shade800;
        label = 'Inicia en';
        timeStr = _format(s.remaining);
      case TimerStatus.allDay:
        badgeBg = scheme.error.withValues(alpha: 0.10);
        badgeBorder = scheme.error;
        badgeText = scheme.error;
        label = 'Restricción';
        timeStr = 'Todo el día';
      case TimerStatus.free:
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
                      s.status == TimerStatus.free ||
                          s.status == TimerStatus.allDay
                      ? 13
                      : 18,
                  fontWeight: FontWeight.bold,
                  color: badgeText,
                ),
              ),
              if (s.status == TimerStatus.active ||
                  s.status == TimerStatus.upcoming)
                Text(
                  s.status == TimerStatus.active
                      ? 'hasta las ${_fmt(s.currentRange.end, use24h)}'
                      : 'a las ${_fmt(s.currentRange.start, use24h)}',
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
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rango actual
              Text(
                s.status == TimerStatus.free
                    ? 'Sin restricción hoy'
                    : '${_fmt(s.currentRange.start, use24h)}'
                          ' — ${_fmt(s.currentRange.end, use24h)}',
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
                      color: s.status == TimerStatus.active
                          ? scheme.error
                          : s.status == TimerStatus.upcoming
                          ? Colors.orange
                          : scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _statusSubtitle(s, use24h),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: s.status == TimerStatus.active
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

  // ── Método de formato con flag ────────────────────────────────
  String _fmt(TimeOfDay t, bool use24h) {
    if (use24h) {
      final h = t.hour.toString().padLeft(2, '0');
      final m = t.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final pm = t.period == DayPeriod.pm ? 'pm' : 'am';
    return '$h:$m $pm';
  }

  String _statusSubtitle(TimerState s, bool use24h) {
    switch (s.status) {
      case TimerStatus.active:
        return 'Restricción activa ahora';
      case TimerStatus.upcoming:
        return s.nextRange != null
            ? 'Próximo: ${_fmt(s.nextRange!.start, use24h)}'
            : 'Sin más franjas hoy';
      case TimerStatus.allDay:
        return 'Aplica todo el día';
      case TimerStatus.free:
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
}
