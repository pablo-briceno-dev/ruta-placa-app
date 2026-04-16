import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({required this.start, required this.end});

  bool contains(TimeOfDay time) {
    final t = _toMin(time);
    final s = _toMin(start);
    final e = _toMin(end);
    return t >= s && t <= e;
  }

  int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;

  factory TimeRange.fromJson(Map<String, dynamic> json) => TimeRange(
    start: _parseTime(json['start'] as String),
    end: _parseTime(json['end'] as String),
  );

  Map<String, dynamic> toJson() => {
    'start': _formatTime(start),
    'end': _formatTime(end),
  };

  static TimeOfDay _parseTime(String raw) {
    final parts = raw.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}
