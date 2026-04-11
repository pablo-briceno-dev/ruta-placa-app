import 'package:flutter/foundation.dart';
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Título
          Row(
            children: [
              Icon(Icons.palette, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Sistema de colores',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Switch(value: isEnabledSystemColors, onChanged: onChangedSwitch),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 Leyenda
          if (isEnabledSystemColors) ...[
            Wrap(
              spacing: 24,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: plates.asMap().entries.map((e) {
                final index = e.key;
                final digits = e.value;
                final isEqual = listEquals(digits, platesRestriction);
                final isLastDigit = e.value.contains(int.parse(lastDigitPlate));

                return DigitLegend(
                  color: (isEqual || isLastDigit)
                      ? Colors.red
                      : colorsPlates[index],
                  digits: digits.join(' - '),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Más información
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadiusGeometry.circular(5),
                ),
              ),
              const SizedBox(width: 10),
              Text('Con restricción - Para el dígito $lastDigitPlate'),
            ],
          ),

          if (!isEnabledSystemColors) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.green, width: 1.5),
                    borderRadius: BorderRadiusGeometry.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Sin restricción - Último dígito $lastDigitPlate'),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: holidayColor.withValues(alpha: 0.15),
                  border: Border.all(color: holidayColor, width: 1.5),
                  borderRadius: BorderRadiusGeometry.circular(5),
                ),
              ),
              const SizedBox(width: 10),
              Text('Días festivos'),
            ],
          ),
        ],
      ),
    );
  }
}
