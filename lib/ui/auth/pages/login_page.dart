import 'package:drazzle/ui/auth/riverpod/auth_controller.dart';
import 'package:drazzle/ui/auth/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:email_validator/email_validator.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      authSnackbar(context, 'Пожалуйста, заполните все поля', isError: true);
      return;
    }
    if (!EmailValidator.validate(email)) {
      if (!mounted) return;
      authSnackbar(context, 'Некорректный email', isError: true);
      return;
    }

    await ref.read(authControllerProvider.notifier).login(email, password);
    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (state.error == null) {
      context.go('/gallery', extra: 'Вход выполнен успешно');
    } else {
      authSnackbar(context, state.error ?? 'Ошибка входа', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text('Вход', textAlign: TextAlign.center),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _onLoginPressed(),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: authState.isLoading ? null : _onLoginPressed,
                  child: authState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Войти'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.pushNamed('register'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Регистрация'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
