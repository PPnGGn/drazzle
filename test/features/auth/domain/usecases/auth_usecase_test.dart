import 'package:draw_hub/core/errors/auth_exception.dart';
import 'package:draw_hub/features/auth/domain/usecases/auth_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/auth_mocks.mocks.dart';

void main() {
  late AuthUseCase authUseCase;
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    authUseCase = AuthUseCase(mockAuthService);
  });

  group('loginUseCase', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('успешно вызывает loginViaEmailPassword и возвращает User', () async {
      // ARRANGE
      when(
        mockAuthService.loginViaEmailPassword(email: email, password: password),
      ).thenAnswer((_) async => mockUser);

      // ACT
      final result = await authUseCase.loginUseCase(
        email: email,
        password: password,
      );

      // ASSERT
      expect(result, equals(mockUser));
      verify(
        mockAuthService.loginViaEmailPassword(email: email, password: password),
      ).called(1);
    });

    test('выбрасывает AuthException при неверном пароле', () async {
      // ARRANGE

      when(
        mockAuthService.loginViaEmailPassword(email: email, password: password),
      ).thenThrow(AuthException('wrong-password', 'Неверный пароль'));

      // ACT & ASSERT
      // Проверяем, что метод выбросит AuthException
      expect(
        () => authUseCase.loginUseCase(email: email, password: password),
        throwsA(isA<AuthException>()),
      );
    });

    test('выбрасывает AuthException с правильным сообщением', () async {
      // ARRANGE
      const errorMessage = 'Пользователь не найден';
      when(
        mockAuthService.loginViaEmailPassword(email: email, password: password),
      ).thenThrow(AuthException('user-not-found', errorMessage));

      // ACT & ASSERT
      try {
        await authUseCase.loginUseCase(email: email, password: password);
        fail('Должна была выброситься ошибка');
      } on AuthException catch (e) {
        expect(e.userMessage, equals(errorMessage));
        expect(e.code, equals('user-not-found'));
      }
    });
  });

  group('registrationUseCase', () {
    const displayName = 'test';
    const email = 'test@example.com';
    const password = 'password123';

    test('успешная регистрация', () async {
      // ARRANGE
      when(
        mockAuthService.registerViaEmailPassword(
          displayName: displayName,
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => mockUser);

      // ACT
      final result = await authUseCase.registrationUseCase(
        displayName: displayName,
        email: email,
        password: password,
      );

      // ASSERT
      expect(result, equals(mockUser));
      verify(
        mockAuthService.registerViaEmailPassword(
          displayName: displayName,
          email: email,
          password: password,
        ),
      ).called(1);
    });

    test('выбрасывает AuthException если email уже используется', () async {
      // ARRANGE
      when(
        mockAuthService.registerViaEmailPassword(
          displayName: displayName,
          email: email,
          password: password,
        ),
      ).thenThrow(
        AuthException('email-already-in-use', 'Email уже используется'),
      );

      // ACT & ASSERT
      expect(
        () => authUseCase.registrationUseCase(
          displayName: displayName,
          email: email,
          password: password,
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('logoutUseCase', () {
    test('успешно вызывает logout', () async {
      // ARRANGE
      when(mockAuthService.logout()).thenAnswer((_) async {});

      // ACT
      await authUseCase.logoutUseCase();

      // ASSERT
      verify(mockAuthService.logout()).called(1);
    });

    test('выбрасывает AuthException при ошибке выхода', () async {
      // ARRANGE
      when(
        mockAuthService.logout(),
      ).thenThrow(AuthException('unknown', 'Не удалось выйти'));

      // ACT & ASSERT
      expect(() => authUseCase.logoutUseCase(), throwsA(isA<AuthException>()));
    });
  });
}
