import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
// Сохранение в галерею устройства 
class DrawingLocalSaveService {
  Future<Map?> saveBoundaryToGallery({
    required RenderRepaintBoundary boundary,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    final ui.Image image = await boundary.toImage();
    final byteData = await image.toByteData(format: format);
    if (byteData == null) {
      throw Exception('Не удалось получить byteData для сохранения');
    }

    final Uint8List bytes = byteData.buffer.asUint8List();
    final result = await ImageGallerySaverPlus.saveImage(bytes);
    return result;
  }
}
