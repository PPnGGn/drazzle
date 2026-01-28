// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:draw_hub/core/errors/auth_exception.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:talker_flutter/talker_flutter.dart';
//
// class AuthService {
//   final FirebaseAuth _auth;
//   final FirebaseFirestore _firestore;
//   final Talker _talker;
//
//   AuthService({
//     FirebaseAuth? auth,
//     FirebaseFirestore? firestore, required this._talker,
//   })  : _auth = auth ?? FirebaseAuth.instance,
//         _firestore = firestore ?? FirebaseFirestore.instance;
//
//
//   Future<User> registerViaEmailPassword({
//     required String email,
//     required String password,
//     String? displayName,
//   }) async {
//     _talker.info('Начало регистрации пользователя: $email');
//     try {
//       final credential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       if (credential.user == null) {
//         _talker.error('Не удалось создать пользователя - credential.user is null');
//         throw AuthException('unknown', 'Не удалось создать пользователя');
//       }
//
//       if (displayName != null && displayName.isNotEmpty) {
//         _talker.debug('Обновление displayName: $displayName');
//         await credential.user!.updateDisplayName(displayName);
//         await credential.user!.reload();
//       }
//
//       _talker.debug('Сохранение пользователя в Firestore');
//       await _firestore.collection('users').doc(credential.user!.uid).set({
//         'displayName': displayName ?? 'Без имени',
//         'email': email,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       _talker.info('Пользователь успешно зарегистрирован: ${credential.user!.uid}');
//       return credential.user!;
//     } on FirebaseAuthException catch (e) {
//       _talker.error('Ошибка Firebase при регистрации: ${e.code} - ${e.message}');
//       throw AuthException(e.code, e.message ?? 'Unknown Firebase error');
//     } catch (e, stackTrace) {
//       _talker.handle(e, stackTrace, 'Неизвестная ошибка при регистрации');
//       rethrow;
//     }
//   }
//
//   Future<User> loginViaEmailPassword({
//     required String email,
//     required String password,
//   }) async {
//     _talker.info('Начало входа пользователя: $email');
//     try {
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       if (credential.user == null) {
//         _talker.error('Не удалось войти - credential.user is null');
//         throw AuthException('unknown', 'Не удалось войти');
//       }
//
//       _talker.info('Пользователь успешно вошел: ${credential.user!.uid}');
//       return credential.user!;
//     } on FirebaseAuthException catch (e) {
//       _talker.error('Ошибка Firebase при входе: ${e.code} - ${e.message}');
//       throw AuthException(e.code, e.message ?? 'Unknown Firebase error');
//     } catch (e, stackTrace) {
//       _talker.handle(e, stackTrace, 'Неизвестная ошибка при входе');
//       rethrow;
//     }
//   }
//
//   Future<void> logout() async {
//     _talker.info('Начало выхода пользователя');
//     try {
//       await _auth.signOut();
//       _talker.info('Пользователь успешно вышел');
//     } on FirebaseAuthException catch (e) {
//       _talker.error('Ошибка Firebase при выходе: ${e.code} - ${e.message}');
//       throw AuthException(e.code, e.message ?? 'Не удалось выйти');
//     } catch (e, stackTrace) {
//       _talker.handle(e, stackTrace, 'Неизвестная ошибка при выходе');
//       rethrow;
//     }
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';

/// Абстрактный сервис аутентификации
/// Определяет контракт для любой реализации (Firebase, Supabase, etc.)
abstract class AuthService {
  /// Регистрация через email и пароль
  Future<User> registerViaEmailPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Вход через email и пароль
  Future<User> loginViaEmailPassword({
    required String email,
    required String password,
  });

  /// Выход из аккаунта
  Future<void> logout();
}
