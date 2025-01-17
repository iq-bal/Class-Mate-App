import 'package:classmate/models/authentication/user_model.dart';
import 'package:classmate/services/authentication/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

enum AuthState { idle, loading, success, error }

class AuthController {
  final AuthService _authService = AuthService();
  final ValueNotifier<AuthState> stateNotifier = ValueNotifier<AuthState>(AuthState.idle);
  String? errorMessage; // To store error messages
  UserModel? user;
  Future<void> login(String email, String password) async {
    stateNotifier.value = AuthState.loading;
    try {
      user = await _authService.login(email, password);
      stateNotifier.value = AuthState.success;
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = AuthState.error;
    }
  }

  Future<void> register(String email, String name, String password, String role) async {
    stateNotifier.value = AuthState.loading;
    try {
      await _authService.register(email, name, password, role);
      stateNotifier.value = AuthState.success;
      print("successful reg");
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = AuthState.error;
    }
  }

  /// Logout Method
  Future<void> logout(context) async {
    stateNotifier.value = AuthState.loading;
    try {
      await _authService.logout();
      user = null;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.logout();
      stateNotifier.value = AuthState.success;
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = AuthState.error;
    }
  }

}
