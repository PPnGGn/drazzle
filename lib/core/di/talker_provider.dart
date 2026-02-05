import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Провайдер для логера
final talkerProvider = Provider<Talker>((ref) {
  return TalkerFlutter.init();
});
