import 'package:drazzle/ui/auth/riverpod/auth_controller.dart';
import 'package:drazzle/ui/auth/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegisterPressed() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      authSnackbar(context, 'Пожалуйста, заполните все поля', isError: true);
      return;
    }
    if (!EmailValidator.validate(email)) {
      authSnackbar(context, 'Некорректный email', isError: true);
      return;
    }

    if (password.length < 8) {
      authSnackbar(
        context,
        'Пароль должен быть не менее 8 символов',
        isError: true,
      );
      return;
    }
    if (password != confirmPassword) {
      authSnackbar(context, 'Пароли не совпадают', isError: true);
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .register(name, email, password);
    final state = ref.read(authControllerProvider);
    if (state.error == null) {
      if (!mounted) return;
      context.go('/email-verify');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Регистрация',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Имя',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Подтвердить пароль',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: authState.isLoading ? null : _onRegisterPressed,
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Зарегистрироваться'),
              ),
            ),
            if (authState.error != null) ...[const SizedBox(height: 12)],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
