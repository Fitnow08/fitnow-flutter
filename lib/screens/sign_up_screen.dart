import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../services/auth_service.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../widgets/app_restart.dart';
import '../widgets/auth_common.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _emailError;
  String? _passError;
  String? _confirmError;
  String? _globalError;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onTextChanged);
    _passCtrl.addListener(_onTextChanged);
    _confirmCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _ctaEnabled =>
      _emailCtrl.text.isNotEmpty &&
      _passCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty &&
      !_loading;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _passError = null;
      _confirmError = null;
      _globalError = null;
      _loading = true;
    });

    final err = await AuthService.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      // Перезапуск от корня — надёжно, независимо от стека навигатора.
      AppRestart.restart(context);
      return;
    }

    if (err.contains('email')) {
      setState(() => _emailError = err);
    } else if (err.contains('не совпадают')) {
      setState(() => _confirmError = err);
    } else if (err.contains('короткий')) {
      setState(() => _passError = err);
    } else {
      setState(() => _globalError = err);
    }
  }

  void _goSignIn() {
    // Возврат на вход. Если экран входа уже под низом стека (мы пришли
    // оттуда через push) — просто pop. Иначе открываем заново.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      leading: AuthLeading.close,
      footer: const AuthFooterLegal(),
      children: [
        const AuthHeader(
          title: 'Создать аккаунт',
          description:
              'Зарегистрируйтесь, чтобы сохранять прогресс и синхронизировать тренировки.',
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
                textInputAction: TextInputAction.next,
                errorText: _passError,
              ),
              AuthField(
                controller: _confirmCtrl,
                label: 'Подтверждение пароля',
                placeholder: 'Повторите пароль',
                leadingIcon: LucideIcons.lock,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _ctaEnabled ? _submit() : null,
                errorText: _confirmError,
              ),
              const SizedBox(height: 14),
              AuthCtaButton(
                label: 'Зарегистрироваться',
                loading: _loading,
                onPressed: _ctaEnabled ? _submit : null,
              ),
              const SizedBox(height: 18),
              _SignInHint(onTap: _goSignIn),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignInHint extends StatelessWidget {
  const _SignInHint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Уже есть аккаунт? ',
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
              'Войти',
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
