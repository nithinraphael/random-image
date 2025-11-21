import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BRotatingText extends HookWidget {
  const BRotatingText({
    super.key,
    required this.text,
    required this.radius,
    required this.textStyle,
    required this.rotationDuration,
  });

  final String text;
  final double radius;
  final TextStyle textStyle;
  final Duration rotationDuration;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: rotationDuration)
      ..repeat();

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        size: Size(radius * 2, radius * 2),
        painter: _CircularTextPainter(
          text: text,
          radius: radius,
          textStyle: textStyle,
          progress: controller.value,
        ),
      ),
    );
  }
}

class _CircularTextPainter extends CustomPainter {
  const _CircularTextPainter({
    required this.text,
    required this.radius,
    required this.textStyle,
    required this.progress,
  });

  final String text;
  final double radius;
  final TextStyle textStyle;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const kTotalAngle = 2 * math.pi;
    var startAngle = -math.pi / 2 + (progress * kTotalAngle);

    final textWidth = _calculateTextWidth(text);
    final dotWidth = textStyle.fontSize!;
    final totalWidth = textWidth + dotWidth;

    var repetitions = (kTotalAngle * radius / totalWidth).floor();
    repetitions = math.max(1, repetitions);

    final segmentAngle = kTotalAngle / repetitions;
    final textAngle = (textWidth / totalWidth) * segmentAngle;
    final dotAngle = segmentAngle - textAngle;

    for (var rep = 0; rep < repetitions; rep++) {
      _drawDot(canvas, centerX, centerY, startAngle, radius);

      final textStartAngle = startAngle + dotAngle / 2;
      final charWidths = <double>[];
      var totalCharWidth = 0.0;

      for (var i = 0; i < text.length; i++) {
        final textPainter = TextPainter(
          text: TextSpan(text: text[i], style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        charWidths.add(textPainter.width);
        totalCharWidth += textPainter.width;
      }

      var currentAngle = textStartAngle;
      for (var i = 0; i < text.length; i++) {
        final textPainter = TextPainter(
          text: TextSpan(text: text[i], style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        final charProportion = charWidths[i] / totalCharWidth;
        final charAngle = textAngle * charProportion;
        final charCenterAngle = currentAngle + (charAngle / 2);

        final x = centerX + radius * math.cos(charCenterAngle);
        final y = centerY + radius * math.sin(charCenterAngle);

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(charCenterAngle + math.pi / 2);

        textPainter.paint(
          canvas,
          Offset(-charWidths[i] / 2, -textPainter.height / 2),
        );

        canvas.restore();
        currentAngle += charAngle;
      }

      startAngle += segmentAngle;
    }
  }

  double _calculateTextWidth(String text) => (TextPainter(
    text: TextSpan(text: text, style: textStyle),
    textDirection: TextDirection.ltr,
  )..layout()).width;

  void _drawDot(
    Canvas canvas,
    double centerX,
    double centerY,
    double angle,
    double radius,
  ) {
    final dotRadius = textStyle.fontSize! / 4;
    final dotPaint = Paint()
      ..color = textStyle.color!
      ..style = PaintingStyle.fill;

    final dotX = centerX + radius * math.cos(angle);
    final dotY = centerY + radius * math.sin(angle);

    canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
