import 'package:flutter/material.dart';

class DigitLegend extends StatelessWidget {
  /// Un grupo de dígitos — puede ser [2,3] o [1]
  final List<int> digits;

  /// Color base del grupo (de colorsPlates[index])
  final Color color;

  /// Si alguno de los dígitos del grupo coincide con la placa del usuario
  /// se pinta ese dígito específico en rojo
  final int? userDigit;

  const DigitLegend({
    super.key,
    required this.digits,
    required this.color,
    this.userDigit,
  });

  @override
  Widget build(BuildContext context) {
    final isGrouped = digits.length > 1;

    if (isGrouped) {
      return _GroupedChip(digits: digits, color: color, userDigit: userDigit);
    } else {
      return _SingleChip(
        digit: digits.first,
        color: color,
        userDigit: userDigit,
      );
    }
  }
}

// ── Chip para un solo dígito: "2" ─────────────────────────────────────────
class _SingleChip extends StatelessWidget {
  final int digit;
  final Color color;
  final int? userDigit;

  const _SingleChip({required this.digit, required this.color, this.userDigit});

  @override
  Widget build(BuildContext context) {
    final isUser = userDigit != null && digit == userDigit;
    final c = isUser ? Colors.red : color;

    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (!isUser ? color : Colors.black).withValues(alpha: 0.75),
        border: isUser ? Border.all(color: c, width: 2) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$digit',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}

// ── Chip para grupo de dígitos: "2 - 3" ───────────────────────────────────
class _GroupedChip extends StatelessWidget {
  final List<int> digits;
  final Color color;
  final int? userDigit;

  const _GroupedChip({
    required this.digits,
    required this.color,
    this.userDigit,
  });

  @override
  Widget build(BuildContext context) {
    // El borde del chip usa el color del grupo a menos que
    // alguno de los dígitos sea el del usuario → rojo
    final hasUserDigit = userDigit != null && digits.contains(userDigit);
    final borderColor = hasUserDigit ? Colors.red : color;

    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: (!hasUserDigit ? color : Colors.black).withValues(alpha: 0.75),
        border: hasUserDigit ? Border.all(color: borderColor, width: 2) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(digits.length * 2 - 1, (i) {
          // Índices impares = separador " - "
          if (i.isOdd) {
            return Text(
              ' - ',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            );
          }
          final digit = digits[i ~/ 2];

          return Text(
            '$digit',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          );
        }),
      ),
    );
  }
}
