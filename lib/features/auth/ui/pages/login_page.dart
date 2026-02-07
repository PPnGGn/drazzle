import 'package:drazzle/features/auth/domain/auth_controller.dart';
import 'package:drazzle/features/auth/ui/widgets/custom_text_field.dart';
import 'package:drazzle/features/auth/ui/widgets/error_snack_bar.dart';
import 'package:drazzle/features/widgets/gradient_button.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operationState = ref.watch(authControllerProvider);

    ref.listen<AuthOperationState>(authControllerProvider, (previous, next) {
      if (next is AuthOperationError) {
        showErrorSnackBar(context, next.message);
      }
    });

    final isLoading = operationState is AuthOperationLoading;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.asset(
            'assets/png/background_img.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  'Вход',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'E-mail',
                  hintText: 'Введите email',
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  onSubmitted: () => _passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'Пароль',
                  hintText: 'Введите пароль',
                  isPassword: true,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  onSubmitted: _handleLogin,
                ),
                const Spacer(),
                GradientButton(
                  onPressed: isLoading ? null : () => _handleLogin(),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Войти'),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () => context.push('/registration'),
                  child: const Text('Регистрация'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!EmailValidator.validate(email)) {
      showErrorSnackBar(context, 'Неверный формат e-mail');
      return;
    }

    if (password.isEmpty) {
      showErrorSnackBar(context, 'Введите пароль');
      return;
    }

    final authNotifier = ref.read(authControllerProvider.notifier);

    await authNotifier.login(email: email, password: password);
  }
}
