import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drazzle/core/services/auth_service.dart';
import 'package:drazzle/core/services/firebase_auth_service.dart';
import 'package:drazzle/core/services/firebase_storage_service.dart';
import 'package:drazzle/core/services/image_service.dart';
import 'package:drazzle/core/services/network_service.dart';
import 'package:drazzle/core/di/talker_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Провайдер для FirebaseFirestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
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

// Провайдер для ImageService
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

// Провайдер для FirebaseStorageService
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});
