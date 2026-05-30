import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../services/auth_service.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../widgets/auth_common.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  String? _emailError;
  bool _loading = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool get _ctaEnabled => _emailCtrl.text.isNotEmpty && !_loading;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _loading = true;
    });

    final err = await AuthService.resetPassword(email: _emailCtrl.text.trim());

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      setState(() => _sent = true);
      return;
    }
    setState(() => _emailError = err);
  }

  void _returnToSignIn() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) return _buildSentState();
    return _buildFormState();
  }

  // ─────────────── Default / Form ───────────────

  Widget _buildFormState() {
    return AuthScreenShell(
      leading: AuthLeading.back,
      footer: _returnLinkFooter(),
      children: [
        const AuthHeader(
          title: 'Восстановление пароля',
          description: 'Введите email, на который зарегистрирован аккаунт.',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthField(
                controller: _emailCtrl,
                label: 'Email',
                placeholder: 'you@example.com',
                leadingIcon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _ctaEnabled ? _submit() : null,
                errorText: _emailError,
              ),
              const SizedBox(height: 6),
              AuthCtaButton(
                label: 'Отправить',
                loading: _loading,
                onPressed: _ctaEnabled ? _submit : null,
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'На указанную почту придёт письмо со ссылкой для сброса пароля. '
                  'Если письма нет, проверьте папку «Спам».',
                  style: AppText.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.eyebrow,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _returnLinkFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Center(
        child: AuthTextLink(
          label: 'Вернуться ко входу',
          onTap: _returnToSignIn,
        ),
      ),
    );
  }

  // ─────────────── Sent state ───────────────

  Widget _buildSentState() {
    return AuthScreenShell(
      leading: AuthLeading.back,
      onLeading: _returnToSignIn,
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: AuthCtaButton(
          label: 'Вернуться ко входу',
          onPressed: _returnToSignIn,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0x1A4ADE80), // ~0.10
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x4D4ADE80), // ~0.30
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.mailCheck,
                    size: 44,
                    color: Color(0xFF4ADE80),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Письмо отправлено',
                  textAlign: TextAlign.center,
                  // bigTitle = 26/800 -0.5 1.1 — точно по JSX.
                  style: AppText.bigTitle,
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text.rich(
                    TextSpan(
                      style: AppText.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.eyebrow,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Проверьте почту '),
                        TextSpan(
                          text: _emailCtrl.text.trim(),
                          style: AppText.body.copyWith(
                            fontSize: 15,
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                        const TextSpan(
                          text: ' и перейдите по ссылке для сброса пароля.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
