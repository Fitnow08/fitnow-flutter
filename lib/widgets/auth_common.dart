import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

/// Палитра ошибок — локальная для auth-флоу, не выносим в AppColors,
/// чтобы не плодить «универсальных» цветов с одним местом использования.
class _ErrorPalette {
  static const text = Color(0xFFE07A7A);
  static const bg = Color(0x14E07A7A); // ~0.08 alpha
  static const border = Color(0x40E07A7A); // ~0.25 alpha
}

/// Скелет экрана: шапка с крестиком/назад + прокручиваемое тело.
/// Аналог JSX `ScreenShell + TopBar`.
class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    super.key,
    required this.children,
    this.leading = AuthLeading.close,
    this.onLeading,
    this.footer,
  });

  final List<Widget> children;
  final AuthLeading leading;
  final VoidCallback? onLeading;

  /// Закреплён внизу — для legal-текста или одиночной кнопки.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // resizeToAvoidBottomInset: true (по умолчанию) — экран корректно
      // ужимается, когда поднимается клавиатура.
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthTopBar(leading: leading, onLeading: onLeading),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
            if (footer != null)
              SafeArea(top: false, child: footer!),
          ],
        ),
      ),
    );
  }
}

enum AuthLeading { close, back }

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar({required this.leading, this.onLeading});

  final AuthLeading leading;
  final VoidCallback? onLeading;

  @override
  Widget build(BuildContext context) {
    final icon = leading == AuthLeading.close ? LucideIcons.x : LucideIcons.arrowLeft;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: onLeading ?? () => Navigator.of(context).maybePop(),
              splashRadius: 22,
              icon: Icon(icon, size: 22, color: AppColors.eyebrow),
              tooltip: leading == AuthLeading.close ? 'Закрыть' : 'Назад',
            ),
          ),
        ],
      ),
    );
  }
}

/// Заголовок + описание экрана (28px / 15px).
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            // screenTitle = 28/800 -0.6 — близко к JSX (28/700 -0.6).
            // Чуть жирнее, но дисциплина шкалы важнее минорных правок.
            style: AppText.screenTitle.copyWith(height: 1.15),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: AppText.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.eyebrow,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Поле ввода в стиле auth-флоу — высота 52, иконка слева, опциональный
/// тоггл показа пароля справа, состояние ошибки с красной обводкой
/// и подписью снизу.
class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.leadingIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.errorText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final IconData? leadingIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool autofocus;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? _ErrorPalette.border
        : _focused
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.07);

    final iconColor = hasError ? _ErrorPalette.text : AppColors.eyebrow;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                widget.label!,
                style: AppText.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.eyebrow,
                ),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: hasError ? _ErrorPalette.bg : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(widget.leadingIcon, size: 18, color: iconColor),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    obscureText: widget.isPassword && _obscured,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onSubmitted: widget.onSubmitted,
                    cursorColor: AppColors.text,
                    style: AppText.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.placeholder,
                      hintStyle: AppText.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.eyebrow.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
                if (widget.isPassword)
                  GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
                        _obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                        size: 20,
                        color: AppColors.eyebrow,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Text(
                widget.errorText!,
                style: AppText.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _ErrorPalette.text,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// «Глобальная» ошибка над формой — например, «Неверный email или пароль».
class AuthGlobalError extends StatelessWidget {
  const AuthGlobalError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _ErrorPalette.bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _ErrorPalette.border, width: 1),
      ),
      child: Text(
        message,
        style: AppText.body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _ErrorPalette.text,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Белая основная кнопка — для служебного флоу (auth).
/// Не путать с lime CTA в онбординге/тренировках — тот зарезервирован.
class AuthCtaButton extends StatefulWidget {
  const AuthCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  State<AuthCtaButton> createState() => _AuthCtaButtonState();
}

class _AuthCtaButtonState extends State<AuthCtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTap: disabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: disabled
              ? Colors.white.withValues(alpha: 0.20)
              : Color.lerp(AppColors.text, AppColors.bg, _pressed ? 0.12 : 0)!,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: widget.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
                ),
              )
            : Text(
                widget.label,
                style: AppText.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: disabled
                      ? AppColors.bg.withValues(alpha: 0.45)
                      : AppColors.bg,
                ),
              ),
      ),
    );
  }
}

/// Текст с двумя ссылками («Условия» и «Политика») — подвал auth-экранов.
class AuthFooterLegal extends StatelessWidget {
  const AuthFooterLegal({super.key});

  @override
  Widget build(BuildContext context) {
    final base = AppText.body.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.eyebrow,
      height: 1.5,
    );
    final link = base.copyWith(
      color: AppColors.text,
      decoration: TextDecoration.underline,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Нажимая «Продолжить», вы соглашаетесь с '),
            TextSpan(text: 'Условиями использования', style: link),
            const TextSpan(text: ' и '),
            TextSpan(text: 'Политикой конфиденциальности', style: link),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
        style: base,
      ),
    );
  }
}

/// Универсальный текстовый «линк-кнопка» (например «Забыли пароль?»).
class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final VoidCallback onTap;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          label,
          style: AppText.body.copyWith(
            fontSize: 13,
            fontWeight: fontWeight,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}
