import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class SplitBackground extends StatelessWidget {
  final List<Color> colors;

  const SplitBackground({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiagonalSplitPainter(colors: colors),
      child: const SizedBox.expand(),
    );
  }
}

class _DiagonalSplitPainter extends CustomPainter {
  final List<Color> colors;

  const _DiagonalSplitPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (var i = 0; i < colors.length; i++) {
      final color = colors[i];
      final path = Path();

      if (i == 0) {
        // Triángulo superior izquierdo — color1
        path
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(0, h)
          ..close();
      } else if (i == colors.length - 1) {
        path
          ..moveTo(w, 0)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_DiagonalSplitPainter old) =>
      !listEquals(old.colors, colors);
}
