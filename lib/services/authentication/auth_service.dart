import 'dart:convert';
import 'dart:ffi';

import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:classmate/models/authentication/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
}
