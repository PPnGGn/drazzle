import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Нативный share
class DrawingExportService {
  Future<void> shareImage({
    required String imagePath,
    required BuildContext context,
  }) async {
    if (!context.mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    final rect = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.zero;

    final params = ShareParams(
      files: [XFile(imagePath)],
      sharePositionOrigin: rect,
    );

    await SharePlus.instance.share(params);
  }

  Future<File> exportFromBoundary({
    required GlobalKey repaintBoundaryKey,
    double pixelRatio = 2.0,
  }) async {
    final boundary =
        repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Не удалось получить boundary для экспорта');
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Не удалось получить byteData при экспорте');
    }

    return _createTempFile(byteData.buffer.asUint8List());
  }

  Future<File> _createTempFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    return file;
  }
}
