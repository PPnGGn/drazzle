import 'package:drazzle/core/services/notification_service.dart';
import 'package:drazzle/features/drawing/domain/drawing_export_service.dart';
import 'package:drazzle/features/drawing/domain/drawing_import_service.dart';
import 'package:drazzle/features/drawing/domain/drawing_local_save_service.dart';
import 'package:drazzle/features/drawing/domain/drawing_persistence_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для DrawingImportService
final drawingImportServiceProvider = Provider<DrawingImportService>((ref) {
  return DrawingImportService();
});

// Провайдер для DrawingExportService
final drawingExportServiceProvider = Provider<DrawingExportService>((ref) {
  return DrawingExportService();
});

// Провайдер для DrawingLocalSaveService
final drawingLocalSaveServiceProvider = Provider<DrawingLocalSaveService>((
  ref,
) {
  return DrawingLocalSaveService();
});

// Провайдер для DrawingPersistenceService
final drawingPersistenceServiceProvider = Provider<DrawingPersistenceService>((
  ref,
) {
  return DrawingPersistenceService();
});

// Провайдер для NotificationService
final drawingNotificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
