// Puede vivir en el mismo archivo o en uno separado
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ruta_placa/models/plate_origin.dart';
import 'package:ruta_placa/models/time_range.dart';

class ScheduleModal extends StatefulWidget {
  final Map<PlateOrigin, List<TimeRange>> rangesByOrigin;
  final bool isRestricted;

  const ScheduleModal({
    super.key,
    required this.rangesByOrigin,
    required this.isRestricted,
  });

  @override
  State<ScheduleModal> createState() => _ScheduleModalState();
}

class _ScheduleModalState extends State<ScheduleModal> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text('Horarios de restricción', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            _todayLabel(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),

          // Sección por origen
          ...widget.rangesByOrigin.entries.map((entry) {
            final origin = entry.key;
            final ranges = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _originLabel(origin).toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                ...ranges.map(
                  (r) => _RangeRow(range: r, isRestricted: widget.isRestricted),
                ),
                const SizedBox(height: 14),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _originLabel(PlateOrigin o) => switch (o) {
    PlateOrigin.metropolitan => 'Placa área metropolitana',
    PlateOrigin.nationalOrForeign => 'Placa nacional o extranjera',
    PlateOrigin.any => 'Todas las placas',
  };

  String _todayLabel() {
    const days = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]} ${now.day} de ${months[now.month - 1]}';
  }
}

// ── Fila de un rango con estado ────────────────────────────────────────────
class _RangeRow extends StatelessWidget {
  final TimeRange range;
  final bool isRestricted;

  const _RangeRow({required this.range, required this.isRestricted});

  @override
  Widget build(BuildContext context) {
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
      range.start.hour,
      range.start.minute,
    );
    final end = DateTime(
      now.year,
      now.month,
      now.day,
      range.end.hour,
      range.end.minute,
    );

    final bool isActive = now.isAfter(start) && now.isBefore(end);
    final bool isUpcoming = now.isBefore(start);
    final bool isPast = now.isAfter(end);

    final Color dotColor;
    final Color borderColor;
    final Color bgColor;
    final String statusText;
    Duration? remaining;

    if (isActive) {
      dotColor = scheme.error;
      borderColor = scheme.error;
      bgColor = scheme.error.withValues(alpha: 0.06);
      remaining = end.difference(now);
      statusText = 'Activo · termina en ${_fmt(remaining)}';
    } else if (isUpcoming) {
      dotColor = Colors.orange.shade600;
      borderColor = Colors.orange.shade300;
      bgColor = Colors.orange.withValues(alpha: 0.06);
      remaining = start.difference(now);
      statusText = 'Inicia en ${_fmt(remaining)}';
    } else {
      dotColor = scheme.onSurface.withValues(alpha: 0.3);
      borderColor = scheme.onSurface.withValues(alpha: 0.1);
      bgColor = Colors.transparent;
      statusText = 'Finalizado';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_fmtTime(range.start, use24h)} — ${_fmtTime(range.end, use24h)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isPast
                        ? scheme.onSurface.withValues(alpha: 0.4)
                        : null,
                  ),
                ),
                Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isActive
                        ? scheme.error
                        : isUpcoming
                        ? Colors.orange.shade700
                        : scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),

          // Badge de tiempo solo si activo o próximo
          if ((isActive || isUpcoming) && remaining != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? scheme.error.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? scheme.error : Colors.orange.shade600,
                  width: 1,
                ),
              ),
              child: Text(
                _fmt(remaining),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActive ? scheme.error : Colors.orange.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String _fmtTime(TimeOfDay t, bool use24h) {
    if (use24h) {
      return '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}';
    }
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final pm = t.period == DayPeriod.pm ? 'pm' : 'am';
    return '$h:$m $pm';
  }
}
