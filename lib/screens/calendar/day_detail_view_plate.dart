import 'package:flutter/material.dart';

class DayDetailViewPlate extends StatelessWidget {
  final List<int> plates;
  final Color colorPlate;
  final String textContent;

  const DayDetailViewPlate({
    super.key,
    required this.plates,
    required this.colorPlate,
    this.textContent = 'Dígitos restringidos:',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(textContent),
        const SizedBox(width: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colorPlate.withValues(alpha: 0.15),
            border: Border.all(color: colorPlate, width: 1.5),
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
          child: Text(
            plates.join(' - '),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    );
  }
}
