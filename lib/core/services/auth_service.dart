import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // регистрация
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // вход
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // выход
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // обновление пользователя
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // проверка подтверждения почты
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // текущий пользователь
  User? get currentUser => _auth.currentUser;
}
