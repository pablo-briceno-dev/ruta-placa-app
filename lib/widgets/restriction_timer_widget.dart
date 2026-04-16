import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ruta_placa/core/utils/date_utils.dart';
import 'package:ruta_placa/models/time_range.dart';

class CurrentState {
  final String label;
  final Duration remaining;
  final bool isRestricted;
  final TimeRange range;

  const CurrentState({
    required this.label,
    required this.remaining,
    required this.isRestricted,
    required this.range,
  });
}

class RestrictionTimerWidget extends StatefulWidget {
  final bool isRestricted;
  final List<TimeRange> ranges;
  final bool viewRange;

  const RestrictionTimerWidget({
    super.key,
    required this.isRestricted,
    required this.ranges,
    this.viewRange = true,
  });

  @override
  State<RestrictionTimerWidget> createState() => _RestrictionTimerWidgetState();
}

class _RestrictionTimerWidgetState extends State<RestrictionTimerWidget> {
  late Duration remaining;
  late String label;
  late bool isRestricted;
  late TimeRange range;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    bool isTodayAll = false;
    for (final range in widget.ranges) {
      if (isFullDay(range.start, range.end)) {
        isTodayAll = true;
        break;
      }
    }

    if (!isTodayAll) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateTime();
      });
    }
  }

  void _updateTime() {
    final state = getCurrentState(widget.ranges);

    setState(() {
      remaining = state.remaining.isNegative ? Duration.zero : state.remaining;
      label = state.label;
      isRestricted = state.isRestricted;
      range = state.range;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Text(
            '${formatTime(context, range.start)} - ${formatTime(context, range.end)}',
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: (isFullDay(range.start, range.end) ? 15 : 1),
            ),
            decoration: BoxDecoration(
              color: widget.isRestricted
                  ? theme.colorScheme.error.withValues(alpha: 0.55)
                  : theme.chipTheme.selectedColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: theme.textTheme.bodyMedium?.fontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!isFullDay(range.start, range.end))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: widget.isRestricted
                    ? theme.colorScheme.error.withValues(alpha: 0.55)
                    : theme.chipTheme.selectedColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                formatDuration(remaining),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: theme.textTheme.bodyMedium?.fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  CurrentState getCurrentState(List<TimeRange> ranges) {
    final now = DateTime.now();

    for (final range in ranges) {
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

      if (now.isBefore(start)) {
        return CurrentState(
          label: "Inicia en",
          remaining: start.difference(now),
          isRestricted: false,
          range: range,
        );
      }

      if (now.isAfter(start) &&
          now.isBefore(end) &&
          isFullDay(range.start, range.end)) {
        return CurrentState(
          label: "Todo el día",
          remaining: end.difference(now),
          isRestricted: widget.isRestricted,
          range: range,
        );
      }

      if (now.isAfter(start) && now.isBefore(end)) {
        return CurrentState(
          label: "Termina en",
          remaining: end.difference(now),
          isRestricted: widget.isRestricted,
          range: range,
        );
      }
    }

    final first = ranges.first;

    final tomorrowStart = DateTime(
      now.year,
      now.month,
      now.day + 1,
      first.start.hour,
      first.start.minute,
    );

    return CurrentState(
      label: "Inicia en",
      remaining: tomorrowStart.difference(now),
      isRestricted: false,
      range: range,
    );
  }

  bool isFullDay(TimeOfDay start, TimeOfDay end) {
    return start.hour == 0 &&
        start.minute == 0 &&
        end.hour == 23 &&
        end.minute == 59;
  }
}
