import 'package:drazzle/ui/auth/riverpod/auth_provider.dart';
import 'package:drazzle/ui/auth/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmailVerifyPage extends ConsumerWidget {
  const EmailVerifyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    Future<void> checkVerification() async {
      await authService.reloadUser();
      if (!context.mounted) return;
      if (authService.isEmailVerified) {
        if (!context.mounted) return;
        authSnackbar(context, 'Почта успешно подтверждена!', isError: false);
        if (!context.mounted) return;
        context.go('/gallery');
      } else {
        if (!context.mounted) return;
        authSnackbar(
          context,
          'Почта не подтверждена, проверьте ваш email.',
          isError: true,
        );
      }
    }

    Future<void> resendEmail() async {
      try {
        await authService.resendVerificationEmail();
        if (!context.mounted) return;
        authSnackbar(context, 'Письмо отправлено повторно!', isError: false);
      } catch (e) {
        if (!context.mounted) return;
        authSnackbar(context, 'Ошибка при отправке письма: $e', isError: true);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Подтверждение почты')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Пожалуйста, подтвердите ваш email.\n'
              'Письмо с ссылкой для подтверждения отправлено на почту.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: checkVerification,
              icon: const Icon(Icons.check),
              label: const Text('Проверить подтверждение'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: resendEmail,
              icon: const Icon(Icons.mail),
              label: const Text('Отправить письмо ещё раз'),
            ),
          ],
        ),
      ),
    );
  }
}
