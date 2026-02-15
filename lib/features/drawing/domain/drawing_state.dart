import 'dart:typed_data';
import 'package:drazzle/features/drawing/domain/drawing_operation_state.dart';
import 'package:drazzle/features/drawing/domain/drawing_point.dart';
import 'package:flutter/material.dart';

class DrawingState {
  final List<List<DrawingPoint>> strokes;
  final List<DrawingPoint> currentStroke;
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraserMode;
  final Uint8List? backgroundImage;
  final DrawingOperationState operationState;

  const DrawingState({
    this.strokes = const [],
    this.currentStroke = const [],
    this.selectedColor = Colors.black,
    this.selectedWidth = 5.0,
    this.isEraserMode = false,
    this.backgroundImage,
    this.operationState = const DrawingOperationIdle(),
  });

  DrawingState copyWith({
    List<List<DrawingPoint>>? strokes,
    List<DrawingPoint>? currentStroke,
    Color? selectedColor,
    double? selectedWidth,
    bool? isEraserMode,
    Uint8List? backgroundImage,
    DrawingOperationState? operationState,
  }) {
    return DrawingState(
      strokes: strokes ?? this.strokes,
      currentStroke: currentStroke ?? this.currentStroke,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedWidth: selectedWidth ?? this.selectedWidth,
      isEraserMode: isEraserMode ?? this.isEraserMode,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      operationState: operationState ?? this.operationState,
    );
  }
}
