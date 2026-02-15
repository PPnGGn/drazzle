import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drazzle/core/services/firebase_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Работает с Firestore
class DrawingPersistenceService {
  final FirebaseStorageService _firebaseStorageService;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DrawingPersistenceService({
    FirebaseStorageService? firebaseStorageService,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _firebaseStorageService =
           firebaseStorageService ?? FirebaseStorageService(),
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveDrawing({
    required RenderRepaintBoundary boundary,
    required Talker talker,
    String? title,
    String? drawingId,
    DateTime? createdAt,
    double pixelRatio = 3.0,
  }) async {
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) {
      throw Exception('Не удалось получить byteData для сохранения');
    }

    final Uint8List imageBytes = byteData.buffer.asUint8List();

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }

    final authorName = await _resolveAuthorName(user);

    final tempFile = await _createTempFile(imageBytes);
    try {
      final resolvedTitle =
          title ?? 'Рисунок ${DateTime.now().day}.${DateTime.now().month}';

      if (drawingId != null && drawingId.trim().isNotEmpty) {
        await _firebaseStorageService.updateDrawing(
          drawingId: drawingId,
          imageFile: tempFile,
          authorId: user.uid,
          title: resolvedTitle,
          authorName: authorName,
          createdAt: createdAt ?? DateTime.now(),
          talker: talker,
        );
      } else {
        await _firebaseStorageService.saveDrawing(
          imageFile: tempFile,
          authorId: user.uid,
          title: resolvedTitle,
          authorName: authorName,
          talker: talker,
        );
      }
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  Future<String> _resolveAuthorName(User user) async {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      final nameFromDb = (data?['displayName'] as String?)?.trim();
      if (nameFromDb != null && nameFromDb.isNotEmpty) {
        return nameFromDb;
      }
    } catch (_) {
      // ignore
    }

    return 'Без имени';
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
