import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ruta_placa/core/utils/date_utils.dart';

class RestrictionTimerWidget extends StatefulWidget {
  final TimeOfDay endTime;
  final bool isRestricted;

  const RestrictionTimerWidget({
    super.key,
    required this.endTime,
    required this.isRestricted,
  });

  @override
  State<RestrictionTimerWidget> createState() => _RestrictionTimerWidgetState();
}

class _RestrictionTimerWidgetState extends State<RestrictionTimerWidget> {
  late Duration remaining;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _updateTime();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final end = DateTime(
      now.year,
      now.month,
      now.day,
      widget.endTime.hour,
      widget.endTime.minute,
    );

    setState(() {
      remaining = end.difference(now);
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
            'Termina en',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: theme.textTheme.bodyMedium?.fontSize,
            ),
            textAlign: TextAlign.center,
          ),
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
}
