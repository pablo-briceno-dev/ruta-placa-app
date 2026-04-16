import 'package:flutter/material.dart';
import 'package:ruta_placa/data/colors_plates.dart';
import 'package:ruta_placa/screens/calendar/digit_legend.dart';

class ColorsSchedulePanel extends StatelessWidget {
  final List<List<int>> plates;
  final List<int> platesRestriction;
  final String lastDigitPlate;
  final bool isEnabledSystemColors;
  final void Function(bool)? onChangedSwitch;

  const ColorsSchedulePanel({
    super.key,
    required this.plates,
    required this.platesRestriction,
    required this.lastDigitPlate,
    this.isEnabledSystemColors = false,
    this.onChangedSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con switch
          Row(
            children: [
              Icon(Icons.palette_outlined, color: scheme.primary),
              const SizedBox(width: 8),
              Text('Sistema de colores', style: theme.textTheme.titleMedium),
              const Spacer(),
              Switch(value: isEnabledSystemColors, onChanged: onChangedSwitch),
            ],
          ),

          const SizedBox(height: 12),

          // Leyenda de grupos de dígitos
          if (isEnabledSystemColors) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.start,
              children: plates.asMap().entries.map((entry) {
                final index = entry.key;
                final groupDigits = entry.value;
                final userDigit = int.tryParse(lastDigitPlate);

                return DigitLegend(
                  digits: groupDigits, // [2,3] o [1] tal como viene
                  color: colorsPlates[index], // color del grupo por índice
                  userDigit: userDigit, // dígito de la placa del usuario
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Referencias visuales
          _LegendRef(
            color: Colors.red,
            label: 'Con restricción — dígito $lastDigitPlate',
          ),

          if (!isEnabledSystemColors) ...[
            const SizedBox(height: 8),
            _LegendRef(
              color: Colors.green,
              label: 'Sin restricción — dígito $lastDigitPlate',
              isApplyBackground: false,
            ),
          ],

          const SizedBox(height: 8),
          _LegendRef(color: holidayColor, label: 'Días festivos'),
        ],
      ),
    );
  }
}

class _LegendRef extends StatelessWidget {
  final Color color;
  final String label;
  final bool isApplyBackground;

  const _LegendRef({
    required this.color,
    required this.label,
    this.isApplyBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isApplyBackground ? Colors.black : color,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
