import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Провайдер для логера с ленивой инициализацией
final talkerProvider = Provider<Talker>((ref) {
  return TalkerFlutter.init();
});
