import 'dart:typed_data';
import 'package:drazzle/features/drawing/domain/drawing_export_service.dart';
import 'package:drazzle/features/drawing/domain/drawing_import_service.dart';
import 'package:drazzle/features/drawing/domain/drawing_local_save_service.dart';
import 'package:drazzle/features/drawing/domain/drawing_persistence_service.dart';
import 'package:drazzle/features/drawing/domain/drawing_operation_state.dart';
import 'package:drazzle/features/drawing/domain/drawing_point.dart';
import 'package:drazzle/features/drawing/domain/drawing_state.dart';
import 'package:drazzle/core/di/drawing_providers.dart';
import 'package:drazzle/core/services/notification_service.dart';
import 'package:drazzle/core/di/talker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Контроллер для рисования
class DrawingController extends Notifier<DrawingState> {
  late final DrawingImportService _importService;
  late final DrawingExportService _exportService;
  late final DrawingLocalSaveService _localSaveService;
  late final DrawingPersistenceService _persistenceService;
  late final NotificationService _notificationService;
  late final Talker _talker;

  @override
  DrawingState build() {
    _talker = ref.read(talkerProvider);
    _importService = ref.read(drawingImportServiceProvider);
    _exportService = ref.read(drawingExportServiceProvider);
    _localSaveService = ref.read(drawingLocalSaveServiceProvider);
    _persistenceService = ref.read(drawingPersistenceServiceProvider);
    _notificationService = ref.read(drawingNotificationServiceProvider);
    
    _talker.info('Инициализация DrawingController');
    return DrawingState();
  }

  // Инициализация с фоновым изображением
  void initializeEditor({Uint8List? backgroundImage}) {
    state = state.copyWith(
      strokes: [],
      currentStroke: [],
      backgroundImage: backgroundImage,
      clearBackground: backgroundImage == null,
      operationState: const DrawingOperationIdle(),
    );
  }

  // Создание точки для рисования
  DrawingPoint _createPoint(Offset position) {
    return DrawingPoint.create(
      offset: position,
      color: state.selectedColor,
      strokeWidth: state.selectedWidth,
      isEraser: state.isEraserMode,
    );
  }

  // Начало штриха
  void startStroke(Offset position) {
    final point = _createPoint(position);
    state = state.copyWith(currentStroke: [point]);
  }

  // Обновление штриха
  void updateStroke(Offset position) {
    final point = _createPoint(position);
    final updatedStroke = [...state.currentStroke, point];
    state = state.copyWith(currentStroke: updatedStroke);
  }

  // Завершение штриха
  void endStroke() {
    if (state.currentStroke.isNotEmpty) {
      final updatedStrokes = [
        ...state.strokes,
        List<DrawingPoint>.from(state.currentStroke),
      ];
      state = state.copyWith(strokes: updatedStrokes, currentStroke: []);
    }
  }

  // Изменение цвета
  void changeColor(Color color) {
    state = state.copyWith(selectedColor: color, isEraserMode: false);
  }

  // Изменение толщины кисти
  void changeBrushWidth(double width) {
    state = state.copyWith(selectedWidth: width, isEraserMode: false);
  }

  // Переключение ластика
  void toggleEraser() {
    state = state.copyWith(isEraserMode: !state.isEraserMode);
  }

  // Очистка холста
  void clearCanvas() {
    state = state.copyWith(strokes: [], currentStroke: []);
  }

  // Отмена последнего штриха
  void undoLastStroke() {
    if (state.strokes.isNotEmpty) {
      final updatedStrokes = List<List<DrawingPoint>>.from(state.strokes);
      updatedStrokes.removeLast();
      state = state.copyWith(strokes: updatedStrokes);
    }
  }

  // Импорт изображения
  Future<void> importImage() async {
    try {
      state = state.copyWith(operationState: const DrawingOperationLoading());

      final imageData = await _importService.pickBackgroundImage();
      if (imageData == null) {
        state = state.copyWith(operationState: const DrawingOperationIdle());
        return;
      }

      state = state.copyWith(
        backgroundImage: imageData,
        operationState: const DrawingOperationSuccess(operation: 'import'),
      );
    } catch (e) {
      state = state.copyWith(
        operationState: DrawingOperationError('Ошибка импорта: $e'),
      );
    }
  }

  // Экспорт рисунка через нативный share
  Future<void> exportDrawing(
    GlobalKey repaintBoundaryKey,
    BuildContext context,
  ) async {
    try {
      state = state.copyWith(operationState: const DrawingOperationLoading());

      final tempFile = await _exportService.exportFromBoundary(
        repaintBoundaryKey: repaintBoundaryKey,
        pixelRatio: 2.0,
      );

      try {
        if (context.mounted) {
          await _exportService.shareImage(
            imagePath: tempFile.path,
            context: context,
          );
        }
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }

      state = state.copyWith(operationState: const DrawingOperationSuccess());
    } catch (e) {
      state = state.copyWith(
        operationState: DrawingOperationError('Ошибка экспорта: $e'),
      );
    }
  }

  // Комплексное сохранение (и в базу, и локально)
  Future<void> saveDrawingComplete(
    GlobalKey repaintBoundaryKey, {
    String? title,
    String? drawingId,
    DateTime? createdAt,
  }) async {
    try {
      state = state.copyWith(operationState: const DrawingOperationLoading());

      final RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Сначала сохраняем в базу данных
      await _persistenceService.saveDrawing(
        boundary: boundary,
        talker: _talker,
        title: title,
        drawingId: drawingId,
        createdAt: createdAt,
      );

      // Затем сохраняем локально
      await _localSaveService.saveBoundaryToGallery(
        boundary: boundary,
      );

      state = state.copyWith(
        operationState: const DrawingOperationSuccess(operation: 'save'),
      );

      // Показываем уведомление об успешном сохранении
      await _notificationService.showSuccessNotification(talker: _talker);
    } catch (e) {
      state = state.copyWith(
        operationState: DrawingOperationError('Ошибка сохранения: $e'),
      );

      // Показываем уведомление об ошибке
      await _notificationService.showErrorNotification(
        'Ошибка сохранения: $e',
        talker: _talker,
      );
    }
  }

  Future<void> saveDrawing(
    GlobalKey repaintBoundaryKey, {
    String? title,
    String? drawingId,
    DateTime? createdAt,
  }) async {
    try {
      state = state.copyWith(operationState: const DrawingOperationLoading());

      final RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      await _persistenceService.saveDrawing(
        boundary: boundary,
        talker: _talker,
        title: title,
        drawingId: drawingId,
        createdAt: createdAt,
      );

      state = state.copyWith(
        operationState: const DrawingOperationSuccess(operation: 'save'),
      );

      // Показываем уведомление об успешном сохранении
      await _notificationService.showSuccessNotification(talker: _talker);
    } catch (e) {
      state = state.copyWith(
        operationState: DrawingOperationError('Ошибка сохранения: $e'),
      );

      // Показываем уведомление об ошибке
      await _notificationService.showErrorNotification(
        'Ошибка сохранения: $e',
        talker: _talker,
      );
    }
  }

  // Сохранение в галерею устройства
  Future<void> saveLocalImage(GlobalKey globalKey) async {
    try {
      state = state.copyWith(operationState: const DrawingOperationLoading());

      final boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final result = await _localSaveService.saveBoundaryToGallery(
        boundary: boundary,
      );
      
      state = state.copyWith(
        operationState: const DrawingOperationSuccess(operation: 'saveLocal'),
      );
      _talker.info('Изображение сохранено в галерею устройства: $result');
    } catch (e) {
      state = state.copyWith(
        operationState: DrawingOperationError('Ошибка сохранения в галерею: $e'),
      );
    }
  }

  // Сброс состояния операции
  void resetOperationState() {
    state = state.copyWith(operationState: const DrawingOperationIdle());
  }
}

// Provider для DrawingController
final drawingControllerProvider =
    NotifierProvider<DrawingController, DrawingState>(
      () => DrawingController(),
    );
