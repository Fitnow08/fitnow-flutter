import 'package:fitnow/domain/auth/entities/user.dart';

class LoginResponseDto {
  LoginResponseDto({
    required this.id,
    required this.email,
    required this.title,
    required this.accessToken,
    required this.refreshToken,
  });

  final String id;
  final String email;
  final String title;
  final String accessToken;
  final String refreshToken;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      id: json['id'] as String,
      email: json['email'] as String,
      title: json['title'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  User toUser() => User(id: id, email: email, title: title);
}
