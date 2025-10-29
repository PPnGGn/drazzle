import 'package:drazzle/ui/auth/riverpod/auth_provider.dart';
import 'package:drazzle/core/services/auth_service.dart';
import 'package:drazzle/ui/auth/riverpod/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends Notifier<AuthState> {
  late final AuthService authService;

  @override
  AuthState build() {
    authService = ref.read(authServiceProvider);
    return AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await authService.signIn(email, password);
      state = state.copyWith(isLoading: false, error: null);
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'wrong-password':
          errorMsg = 'Неверный пароль';
          break;
        case 'user-not-found':
          errorMsg = 'Пользователь не найден';
          break;
        case 'invalid-email':
          errorMsg = 'Некорректный email';
          break;
        default:
          errorMsg = e.message ?? 'Ошибка входа';
      }
      state = state.copyWith(isLoading: false, error: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await authService.signUp(email, password);
      state = state.copyWith(isLoading: false, error: null);
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = 'Пользователь уже существует';
          break;
        case 'invalid-email':
          errorMsg = 'Некорректный email';
          break;
        case 'weak-password':
          errorMsg = 'Слабый пароль';
          break;
        default:
          errorMsg = e.message ?? 'Ошибка регистрации';
      }
      state = state.copyWith(isLoading: false, error: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await authService.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  () => AuthController(),
);
