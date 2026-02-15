import 'package:flutter/material.dart';
// Точка для рисования
class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final bool isEraser;

  DrawingPoint({
    required this.offset,
    required this.paint,
    required this.isEraser,
  });

  factory DrawingPoint.create({
    required Offset offset,
    Color color = Colors.black,
    double strokeWidth = 3.0,
    bool isEraser = false,
  }) {
    return DrawingPoint(
      offset: offset,
      paint: Paint()
        ..color = isEraser ? Colors.white : color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
      isEraser: isEraser,
    );
  }
}
