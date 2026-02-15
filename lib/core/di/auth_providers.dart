import 'package:drazzle/core/di/firebase_providers.dart';
import 'package:drazzle/features/auth/domain/usecases/auth_usecase.dart';
import 'package:drazzle/features/auth/models/auth_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для AuthUseCase
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthUseCase(authService);
});

// Провайдер для auth state
final authUserProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges().map(
    (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
  );
});
