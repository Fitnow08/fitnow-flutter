import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../services/auth_service.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../widgets/app_restart.dart';
import '../widgets/auth_common.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? _emailError;
  String? _passError;
  String? _globalError;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onTextChanged);
    _passCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _ctaEnabled =>
      _emailCtrl.text.isNotEmpty && _passCtrl.text.isNotEmpty && !_loading;

  Future<void> _submit() async {
    debugPrint('[SIGNIN] _submit() called. ctaEnabled=$_ctaEnabled '
        'emailLen=${_emailCtrl.text.length} passLen=${_passCtrl.text.length}');
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _passError = null;
      _globalError = null;
      _loading = true;
    });

    final err = await AuthService.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    debugPrint('[SIGNIN] signIn returned: err=$err  mounted=$mounted');
    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      debugPrint('[SIGNIN] success -> AppRestart.restart');
      // Перезапуск от корня: _Bootstrap перечитает флаги и покажет
      // онбординг или главный экран. Работает независимо от того,
      // что в стеке навигатора (push с экрана регистрации и т.п.).
      AppRestart.restart(context);
      return;
    }

    debugPrint('[SIGNIN] showing error: $err');
    if (err.contains('email')) {
      setState(() => _emailError = err);
    } else {
      setState(() => _globalError = err);
    }
  }

  void _goForgot() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  void _goSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      leading: AuthLeading.close,
      footer: const AuthFooterLegal(),
      children: [
        const AuthHeader(
          title: 'Войти в FitNow',
          description: 'Введите email и пароль, чтобы продолжить тренировки.',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_globalError != null) AuthGlobalError(message: _globalError!),
              AuthField(
                controller: _emailCtrl,
                label: 'Email',
                placeholder: 'you@example.com',
                leadingIcon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: _emailError,
              ),
              AuthField(
                controller: _passCtrl,
                label: 'Пароль',
                placeholder: 'Не менее 8 символов',
                leadingIcon: LucideIcons.lock,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _ctaEnabled ? _submit() : null,
                errorText: _passError,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: AuthTextLink(
                  label: 'Забыли пароль?',
                  onTap: _goForgot,
                ),
              ),
              const SizedBox(height: 16),
              AuthCtaButton(
                label: 'Продолжить',
                loading: _loading,
                onPressed: _ctaEnabled ? _submit : null,
              ),
              const SizedBox(height: 18),
              _SignUpHint(onTap: _goSignUp),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignUpHint extends StatelessWidget {
  const _SignUpHint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Нет аккаунта? ',
            style: AppText.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.eyebrow,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              'Зарегистрироваться',
              style: AppText.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
