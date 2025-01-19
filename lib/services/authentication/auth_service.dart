import 'dart:convert';
import 'dart:ffi';

import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:classmate/models/authentication/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class AuthService {
  late Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
    ));
  }
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      UserModel user = UserModel.fromJson(response.data);
      await _tokenStorage.storeToken(response.data['accessToken'], response.data['refreshToken']);
      return user;
    } catch (e) {
      throw Exception('Failed to login. Please try again.');
    }
  }

  Future<void> register(String email, String name, String password, String role) async {
    try {
      final response = await _dio.post('/register', data: {
        'email': email,
        'name':name,
        'password': password,
        'role': role
      });
    } catch (e) {
      throw Exception('Failed to login. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.retrieveRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token found.');
      }

      // Send logout request to the server
      final response = await _dio.delete('/logout', data: {
        'refreshToken': refreshToken,
      });
      if (response.statusCode == 200 || response.statusCode == 404) {
        await _tokenStorage.clearTokens();
      } else {
        throw Exception('Logout failed. Please try again.');
      }

    } catch (e) {
      await _tokenStorage.clearTokens();
      throw Exception('Failed to logout. Please try again.');
    }
  }



}
