import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

// импорт из галереи
class DrawingImportService {
  final ImagePicker _imagePicker;

  DrawingImportService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  Future<Uint8List?> pickBackgroundImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return null;
    return image.readAsBytes();
  }
}
