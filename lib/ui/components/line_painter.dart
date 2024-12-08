import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final List<Offset> points;
  final Offset? currentDragPosition;

  LinePainter({required this.points, this.currentDragPosition});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.6)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (currentDragPosition != null && points.isNotEmpty) {
      path.lineTo(currentDragPosition!.dx, currentDragPosition!.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.currentDragPosition != currentDragPosition;
  }
}
