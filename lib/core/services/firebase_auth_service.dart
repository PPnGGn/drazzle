import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drazzle/core/errors/auth_exception.dart';
import 'package:drazzle/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Реализация AuthService через Firebase
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Talker _talker;

  FirebaseAuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required Talker talker,
  })  : _auth = auth,
        _firestore = firestore,
        _talker = talker;

  @override
  Future<User> registerViaEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _talker.info('Attempting registration for $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('unknown', 'Не удалось создать пользователя');
      }

      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'displayName': displayName ?? 'Без имени',
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _talker.info('Registration successful for ${credential.user!.uid}');
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      _talker.error('Registration failed: ${e.code}');
      throw AuthException(e.code, e.message ?? 'Unknown Firebase error');
    }
  }

  @override
  Future<User> loginViaEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _talker.info('Attempting login for $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('unknown', 'Не удалось войти');
      }

      _talker.info('Login successful for ${credential.user!.uid}');
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      _talker.error('Login failed: ${e.code}');
      throw AuthException(e.code, e.message ?? 'Unknown Firebase error');
    }
  }

  @override
  Future<void> logout() async {
    try {
      _talker.info('Attempting logout');
      await _auth.signOut();
      _talker.info('Logout successful');
    } on FirebaseAuthException catch (e) {
      _talker.error('Logout failed: ${e.code}');
      throw AuthException(e.code, e.message ?? 'Не удалось выйти');
    }
  }
}
