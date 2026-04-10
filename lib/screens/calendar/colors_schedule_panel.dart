import 'package:flutter/material.dart';

class ColorsSchedulePanel extends StatelessWidget {
  const ColorsSchedulePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      child: Text('Colores de las Placas'),
    );
  }
}
