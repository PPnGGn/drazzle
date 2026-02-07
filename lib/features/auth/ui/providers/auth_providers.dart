import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drazzle/features/auth/domain/usecases/auth_usecase.dart';
import 'package:drazzle/features/auth/models/auth_user.dart';
import 'package:drazzle/core/di/talker_provider.dart';
import 'package:drazzle/core/services/auth_service.dart';
import 'package:drazzle/core/services/firebase_auth_service.dart';
import 'package:drazzle/core/services/network_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//  доступ к FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Провайдер для NetworkService
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

// Провайдер для AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final talker = ref.watch(talkerProvider);
  final networkService = ref.watch(networkServiceProvider);

  return FirebaseAuthService(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    talker: talker,
    networkService: networkService,
  );
});

// Провайдер для AuthUseCase
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthUseCase(authService);
});

final authUserProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges().map(
    (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
  );
});
