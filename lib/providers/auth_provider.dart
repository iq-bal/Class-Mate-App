import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _role;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;

  // Set login state and role
  void setAuthentication(bool isLoggedIn, String? role) {
    _isLoggedIn = isLoggedIn;
    _role = role;
    notifyListeners();
  }

  // Log out the user
  void logout() {
    _isLoggedIn = false;
    _role = null;
    notifyListeners();
  }
}
