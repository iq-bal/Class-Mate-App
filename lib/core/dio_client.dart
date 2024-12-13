import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:dio/dio.dart';

class DioClient {
  late Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  DioClient() {
    // Initialize Dio with base options, including timeouts
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl, // Set your base URL here
    ));

    // Set connectTimeout and receiveTimeout directly in the options
    _dio.options.connectTimeout = const Duration(seconds: AppConfig.timeoutDuration); // Set connection timeout
    _dio.options.receiveTimeout = const Duration(seconds: AppConfig.timeoutDuration); // Set receive timeout

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await _tokenStorage.retrieveAccessToken();
        if (accessToken != null) {
          options.headers["Authorization"] = "Bearer $accessToken";
        }
        return handler.next(options); // Proceed with request
      },
      onResponse: (response, handler) {
        return handler.next(response); // Proceed with response
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final isTokenRefreshed = await _refreshToken();
          if (isTokenRefreshed) {
            final newAccessToken = await _tokenStorage.retrieveAccessToken();

            // Retry original request with updated token
            final retryResponse = await _dio.request(
              error.requestOptions.path,
              options: Options(
                method: error.requestOptions.method,
                headers: {
                  ...error.requestOptions.headers,
                  "Authorization": "Bearer $newAccessToken"
                },
              ),
              data: error.requestOptions.data,
              queryParameters: error.requestOptions.queryParameters,
            );
            return handler.resolve(retryResponse); // Resolve request after retry
          }
        }
        return handler.next(error); // Return original error if retry fails
      },
    ));
  }

  Future<bool> _refreshToken() async {

    try {
      final refreshToken = await _tokenStorage.retrieveRefreshToken();
      if (refreshToken == null) return false;

      // Use Dio with the same timeout settings for the refresh token request
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: AppConfig.timeoutDuration),
        receiveTimeout: const Duration(seconds: AppConfig.timeoutDuration),
      ));

      final response = await dio.post(
        '/token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        await _tokenStorage.storeToken(newAccessToken, refreshToken);
        return true;
      }
    } catch (e) {
      throw Exception('Token refresh error: $e');
    }
    return false;
  }

  // Method to set a base URL dynamically
  Dio getDio(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    return _dio;
  }
}
