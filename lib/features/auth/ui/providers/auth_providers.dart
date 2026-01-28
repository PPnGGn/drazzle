import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draw_hub/core/services/firebase_auth_service.dart';
import 'package:draw_hub/features/auth/domain/usecases/auth_usecase.dart';
import 'package:draw_hub/features/auth/models/auth_user.dart';
import 'package:draw_hub/core/services/auth_service.dart';
import 'package:draw_hub/core/di/talker_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//  доступ к FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Провайдер для AuthService (возвращает реализацию Firebase)
final authServiceProvider = Provider<AuthService>((ref) {
  final talker = ref.watch(talkerProvider);

  return FirebaseAuthService(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    talker: talker,
  );
});

// Провайдер для AuthUseCase
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthUseCase(authService);
});

// ЕДИНСТВЕННЫЙ источник истины для auth state
// Автоматически обновляется при любых изменениях в Firebase
final authUserProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges().map(
    (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
  );
});
