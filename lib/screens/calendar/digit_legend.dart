import 'package:flutter/material.dart';

class DigitLegend extends StatelessWidget {
  final Color color;
  final String digits;

  const DigitLegend({super.key, required this.color, required this.digits});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            digits,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}
