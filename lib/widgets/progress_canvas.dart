import 'package:flutter/material.dart';
import 'dart:math';

// Widget sin estado que usa CustomPaint
class HabitProgressIndicator extends StatelessWidget {
  final int progress; // Puede ser el número de veces completado

  const HabitProgressIndicator({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: ProgressPainter(progress: progress),
      ),
    );
  }
}

class ProgressPainter extends CustomPainter {
  final int progress;

  ProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Fondo del círculo (Gris claro)
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, bgPaint);

    // Progreso del círculo (Lila principal)
    final progressPaint = Paint()
      ..color = const Color(0xFFB39DDB) // Lila
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    // Calculamos el ángulo basado en el progreso (cada vez que hace el hábito, suma un poco)
    // Para el MVP, digamos que cada ejecución es un 10% de una meta, con un máximo de 100%
    double percentage = (progress * 10).clamp(0, 100) / 100;
    double sweepAngle = 2 * pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Empieza arriba
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}