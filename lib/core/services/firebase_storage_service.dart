import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drazzle/features/drawing/models/drawing_model.dart';
import 'package:image/image.dart' as img;
import 'package:talker_flutter/talker_flutter.dart';

class FirebaseStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Сохранение рисунка (изображение в Base64)
  Future<DrawingModel> saveDrawing({
    required File imageFile,
    required String authorId,
    required String title,
    required String authorName,
    required Talker talker,
  }) async {
    try {
      //  Читаем файл
      final bytes = await imageFile.readAsBytes();

      //Декодируем изображение
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Не удалось декодировать изображение');
      }

      // уменьшенная версия для сетки
      img.Image thumbnail = img.copyResize(
        image,
        width: 400, // Ширина для превью
        height: (400 * image.height / image.width).round(),
      );

      // cжатие файла
      img.Image mainImage = image;
      if (image.width > 1024 || image.height > 1024) {
        mainImage = img.copyResize(
          image,
          width: 1024,
          height: (1024 * image.height / image.width).round(),
        );
      }

      // конвертация в джпг
      final thumbnailJpg = img.encodeJpg(thumbnail, quality: 80);
      final mainImageJpg = img.encodeJpg(mainImage, quality: 85);

      // конвертация в base64
      final thumbnailBase64 = base64Encode(thumbnailJpg);
      final imageBase64 = base64Encode(mainImageJpg);

      // проверка размера
      final thumbnailSize = thumbnailBase64.length;
      final imageSize = imageBase64.length;

      talker.info('Размер миниатюры: ${(thumbnailSize / 1024).toStringAsFixed(2)} KB');
      talker.info('Размер изображения: ${(imageSize / 1024).toStringAsFixed(2)} KB');

      if (imageSize > 900000) {
        // ~900 KB (оставляем запас)
        throw Exception(
          'Изображение слишком большое. Попробуйте упростить рисунок.',
        );
      }

      final drawing = DrawingModel(
        id: '',
        title: title,
        authorId: authorId,
        createdAt: DateTime.now(),
        imageUrl: 'data:image/jpeg;base64,$imageBase64',
        thumbnailUrl: 'data:image/jpeg;base64,$thumbnailBase64',
        authorName: authorName,
      );

      // сохранение в Firestore
      final docRef = await _firestore
          .collection('drawings')
          .add(drawing.toFirestore());

      // возвращаем объект с ID
      return DrawingModel(
        id: docRef.id,
        title: drawing.title,
        authorId: drawing.authorId,
        authorName: drawing.authorName,
        createdAt: drawing.createdAt,
        imageUrl: drawing.imageUrl,
        thumbnailUrl: drawing.thumbnailUrl,
      );
    } catch (e) {
      throw Exception('Ошибка сохранения: $e');
    }
  }

  // Удаление рисунка
  Future<void> deleteDrawing(String drawingId) async {
    try {
      await _firestore.collection('drawings').doc(drawingId).delete();
    } catch (e) {
      throw Exception('Ошибка удаления: $e');
    }
  }
}
