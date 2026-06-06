import 'package:shared_preferences/shared_preferences.dart';

/// AuthService — обёртка над авторизацией.
///
/// Сейчас это заглушка: «логин» = записать токен и email в shared_preferences.
/// Когда у бэкенда появятся endpoints — заменяй только тело методов
/// (signIn / signUp / resetPassword). Интерфейс наружу не меняется,
/// экраны и main.dart править не придётся.
class AuthService {
  static const _kAuthToken = 'auth_token';
  static const _kUserEmail = 'user_email';
  static const _kIsAuthenticated = 'is_authenticated';

  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsAuthenticated) ?? false;
  }

  static Future<String?> currentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserEmail);
  }

  /// Отображаемое имя: сохранённое имя (из онбординга) → иначе часть email
  /// до @ с заглавной буквы → иначе пусто. Поле имени появится в онбординге.
  static Future<String> displayName() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('user_name')?.trim() ?? '';
    if (saved.isNotEmpty) return saved;
    final email = prefs.getString(_kUserEmail) ?? '';
    final local = email.split('@').first.trim();
    if (local.isEmpty) return '';
    return local[0].toUpperCase() + local.substring(1);
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!_isEmailValid(email)) {
      return 'Введите корректный email';
    }
    if (password.length < 8) {
      return 'Неверный email или пароль';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAuthToken, 'fake_token_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString(_kUserEmail, email);
    await prefs.setBool(_kIsAuthenticated, true);
    return null;
  }

  static Future<String?> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!_isEmailValid(email)) return 'Введите корректный email';
    if (password.length < 8) return 'Пароль слишком короткий — минимум 8 символов';
    if (password != confirmPassword) return 'Пароли не совпадают';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAuthToken, 'fake_token_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString(_kUserEmail, email);
    await prefs.setBool(_kIsAuthenticated, true);
    return null;
  }

  static Future<String?> resetPassword({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!_isEmailValid(email)) return 'Введите корректный email';
    return null;
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthToken);
    await prefs.setBool(_kIsAuthenticated, false);
  }

  static bool _isEmailValid(String email) {
    final r = RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
    return r.hasMatch(email.trim());
  }
}
