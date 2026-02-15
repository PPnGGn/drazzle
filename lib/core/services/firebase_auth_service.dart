import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drazzle/core/errors/auth_exception.dart';
import 'package:drazzle/core/services/auth_service.dart';

import 'package:drazzle/core/services/network_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Реализация AuthService через Firebase
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Talker _talker;
  final NetworkService _networkService;

  FirebaseAuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required Talker talker,
    required NetworkService networkService,
  }) : _auth = auth,
       _firestore = firestore,
       _talker = talker,
       _networkService = networkService;

  Talker get talker => _talker;

  NetworkService get networkService => _networkService;

  @override
  Future<User> registerViaEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      talker.info('Проверка подключения к сети перед регистрацией');

      // проверка сети
      if (!await networkService.isConnected()) {
        talker.warning('Нет подключения к интернету при попытке регистрации');
        throw AuthException(
          'no-internet-connection',
          'Отсутствует подключение к интернету',
        );
      }

      talker.info('Попытка регистрации пользователя: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        talker.error(
          'Не удалось создать пользователя: credential.user == null',
        );
        throw AuthException('unknown', 'Не удалось создать пользователя');
      }

      // Обновление displayName
      if (displayName != null && displayName.isNotEmpty) {
        try {
          await credential.user!.updateDisplayName(displayName);
          await credential.user!.reload();
          talker.info('DisplayName обновлен: $displayName');
        } catch (e) {
          talker.warning('Не удалось обновить display name: $e');
        }
      }

      // Сохранение в Firestore
      try {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'displayName': displayName ?? 'Без имени',
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        talker.info('Данные пользователя сохранены в Firestore');
      } catch (e) {
        talker.error('Ошибка сохранения в Firestore: $e');
        throw AuthException(
          'firestore-error',
          'Не удалось сохранить данные пользователя',
        );
      }

      talker.info('Регистрация выполнена успешно для ${credential.user!.uid}');
      return credential.user!;
    } on AuthException catch (e) {
      talker.error(
        'Ошибка регистрации (AuthException): ${e.code} - ${e.message}',
      );
      throw AuthException(e.code, e.message);
    } on FirebaseAuthException catch (e) {
      talker.error('Ошибка регистрации (Firebase): ${e.code} - ${e.message}');
      throw AuthException(e.code, e.message ?? 'Unknown Firebase error');
    } catch (e, stackTrace) {
      talker.handle(e, stackTrace, 'Непредвиденная ошибка при регистрации');
      throw AuthException(
        'unknown',
        'Произошла непредвиденная ошибка при регистрации',
      );
    }
  }

  @override
  Future<User> loginViaEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      talker.info('Проверка подключения к сети перед входом');

      // проверка сети
      if (!await networkService.isConnected()) {
        talker.warning('Нет подключения к интернету при попытке входа');
        throw AuthException(
          'no-internet-connection',
          'Отсутствует подключение к интернету',
        );
      }

      talker.info('Попытка входа пользователя: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        talker.error('Не удалось войти: credential.user == null');
        throw AuthException('unknown', 'Не удалось войти');
      }

      talker.info('Вход выполнен успешно для ${credential.user!.uid}');
      return credential.user!;
    } on AuthException catch (e) {
      talker.error('Ошибка входа (AuthException): ${e.code} - ${e.message}');
      throw AuthException(e.code, e.message);
    } on FirebaseAuthException catch (e) {
      talker.error('Ошибка входа (Firebase): ${e.code} - ${e.message}');
      throw AuthException(e.code, e.message ?? 'Unknown Firebase error');
    } catch (e, stackTrace) {
      talker.handle(e, stackTrace, 'Непредвиденная ошибка при входе');
      throw AuthException(
        'unknown',
        'Произошла непредвиденная ошибка при входе',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      talker.info('Попытка выхода из системы');
      await _auth.signOut();
      talker.info('Выход выполнен успешно');
    } on FirebaseAuthException catch (e) {
      talker.error('Ошибка выхода: ${e.code}');
      throw AuthException(e.code, e.message ?? 'Не удалось выйти');
    }
  }
}
