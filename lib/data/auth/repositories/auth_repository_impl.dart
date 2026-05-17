import 'package:dio/dio.dart';
import 'package:fitnow/core/configs/services/token_storage.dart';
import 'package:fitnow/core/network/dio_provider.dart';
import 'package:fitnow/data/auth/repositories/auth_repository.dart';
import 'package:fitnow/domain/auth/entities/login_response.dart';
import 'package:fitnow/domain/auth/entities/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final dto = LoginResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _tokenStorage.saveTokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      );

      return dto.toUser();
    } on DioException catch (e, stack) {
      debugPrint('[Auth] DioException: ${e.response?.statusCode} ${e.message}');
      debugPrint('[Auth] Response: ${e.response?.data}');
      debugPrint('$stack');
      rethrow;
    } catch (e, stack) {
      debugPrint('[Auth] Unexpected error: $e');
      debugPrint('$stack');
      rethrow;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(dioProvider),
    ref.watch(tokenStorageProvider),
  ),
);
