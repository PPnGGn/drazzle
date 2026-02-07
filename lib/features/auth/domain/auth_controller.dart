import 'package:drazzle/features/auth/domain/usecases/auth_usecase.dart';
import 'package:drazzle/features/auth/ui/providers/auth_providers.dart';
import 'package:drazzle/core/di/talker_provider.dart';
import 'package:drazzle/core/errors/auth_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

sealed class AuthOperationState {
  const AuthOperationState();
}

class AuthOperationInitial extends AuthOperationState {
  const AuthOperationInitial();
}

class AuthOperationLoading extends AuthOperationState {
  const AuthOperationLoading();
}

class AuthOperationSuccess extends AuthOperationState {
  const AuthOperationSuccess();
}

class AuthOperationError extends AuthOperationState {
  final String message;
  const AuthOperationError(this.message);
}

class AuthController extends Notifier<AuthOperationState> {
  late final AuthUseCase _authUseCase = ref.read(authUseCaseProvider);
  late final Talker _talker;

  @override
  AuthOperationState build() {
    _talker = ref.read(talkerProvider);
    _talker.info('Инициализация AuthController');
    return const AuthOperationInitial();
  }

  Future<void> login({required String email, required String password}) async {
    _talker.info('Начало процесса входа');
    state = const AuthOperationLoading();
    try {
      await _authUseCase.loginUseCase(email: email, password: password);
      _talker.info('Вход выполнен успешно');
      state = const AuthOperationSuccess();
    } on AuthException catch (e) {
      _talker.warning('Ошибка входа: ${e.userMessage}');
      state = AuthOperationError(e.userMessage);
    } catch (e, stackTrace) {
      _talker.handle(e, stackTrace, 'Непредвиденная ошибка при входе');
      state = const AuthOperationError('Произошла непредвиденная ошибка при входе');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _talker.info('Начало процесса регистрации');
    state = const AuthOperationLoading();
    try {
      await _authUseCase.registrationUseCase(
        email: email,
        password: password,
        displayName: displayName,
      );
      _talker.info('Регистрация выполнена успешно');
      state = const AuthOperationSuccess();
    } on AuthException catch (e) {
      _talker.warning('Ошибка регистрации: ${e.userMessage}');
      state = AuthOperationError(e.userMessage);
    } catch (e, stackTrace) {
      _talker.handle(e, stackTrace, 'Непредвиденная ошибка при регистрации');
      state = const AuthOperationError('Произошла непредвиденная ошибка при регистрации');
    }
  }

  Future<void> logout() async {
    _talker.info('Начало процесса выхода');
    state = const AuthOperationLoading();
    try {
      await _authUseCase.logoutUseCase();
      _talker.info('Выход выполнен успешно');
      state = const AuthOperationSuccess();
    } on AuthException catch (e) {
      _talker.warning('Ошибка выхода: ${e.userMessage}');
      state = AuthOperationError(e.userMessage);
    } catch (e, stackTrace) {
      _talker.handle(e, stackTrace, 'Непредвиденная ошибка при выходе');
      state = const AuthOperationError('Произошла непредвиденная ошибка при выходе');
    }
  }
}

// Провайдер для AuthController
final authControllerProvider =
    NotifierProvider<AuthController, AuthOperationState>(AuthController.new);
