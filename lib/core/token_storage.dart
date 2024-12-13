import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Store tokens securely
  Future<void> storeToken(String accessToken, String refreshToken) async {
    try {
      // Write the access and refresh tokens to secure storage
      await _secureStorage.write(key: 'accessToken', value: accessToken);
      await _secureStorage.write(key: 'refreshToken', value: refreshToken);
    } catch (e) {
      throw Exception('Failed to store tokens securely: $e');
    }
  }

  // Retrieve the access token from secure storage
  Future<String?> retrieveAccessToken() async {
    try {
      // Read the access token
      return await _secureStorage.read(key: 'accessToken');
    } catch (e) {
      throw Exception('Failed to retrieve access token: $e');
    }
  }

  // Retrieve the refresh token from secure storage
  Future<String?> retrieveRefreshToken() async {
    try {
      // Read the refresh token
      return await _secureStorage.read(key: 'refreshToken');
    } catch (e) {
      throw Exception('Failed to retrieve refresh token: $e');
    }
  }
}
