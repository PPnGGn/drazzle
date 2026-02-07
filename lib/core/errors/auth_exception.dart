class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException($code): $message';

  String get userMessage {
    switch (code) {
      case 'weak-password':
        return 'Пароль слишком слабый. Используйте минимум 8 символов, включая буквы и цифры';
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован. Попробуйте войти или используйте другой email';
      case 'user-not-found':
        return 'Пользователь с таким email не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету';
      case 'no-internet-connection':
        return 'Отсутствует подключение к интернету. Проверьте соединение и попробуйте снова';
      case 'too-many-requests':
        return 'Слишком много попыток. Подождите несколько минут и попробуйте снова';
      case 'operation-not-allowed':
        return 'Регистрация временно недоступна';
      case 'invalid-credential':
        return 'Неверные учетные данные';
      case 'user-disabled':
        return 'Аккаунт пользователя заблокирован';
      case 'requires-recent-login':
        return 'Требуется повторный вход в аккаунт';
      case 'firestore-error':
        return 'Ошибка сохранения данных. Попробуйте еще раз';
      default:
        return 'Произошла ошибка: $message';
    }
  }
}
