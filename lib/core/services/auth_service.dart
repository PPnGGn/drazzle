import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Future<User> registerViaEmailPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<User> loginViaEmailPassword({
    required String email,
    required String password,
  });

  Future<void> logout();
}
