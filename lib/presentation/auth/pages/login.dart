import 'package:fitnow/core/configs/theme/app_spacing.dart';
import 'package:fitnow/data/auth/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .login(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      context.go('/');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ошибка входа')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen.copyWith(top: 118),
          child: Column(
            children: [
              Text('Авторизоваться', style: AppFontSize.loginTexth1),
              Text(
                "Введите свой адрес электронной почты и пароль",
                style: AppFontSize.loginText,
              ),
              Padding(
                padding: AppSpacing.inputMargin,
                child: Column(
                  spacing: AppSpacing.inputGap,
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Введите логин',
                      ),
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                      decoration: const InputDecoration(
                        hintText: 'Введите пароль',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.marginForgotPassword,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Забыли пароль?',
                      style: AppFontSize.forgotPasswordText,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.marginLoginBTN),
                child: ElevatedButton(
                  onPressed: () => _handleLogin(),
                  child: const Text('Войти'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
