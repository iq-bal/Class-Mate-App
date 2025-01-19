import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';

class FCMTokenService {
  final DioClient dioClient = DioClient();

  Future<void> updateFCMToken(String token) async {
    try {
      // Get Dio instance from the custom DioClient
      final dio = dioClient.getDio(AppConfig.graphqlServer);

      // GraphQL mutation to update the FCM token
      const String mutation = r'''
        mutation UpdateFCMToken($token: String!) {
          updateFCMToken(fcm_token: $token) {
            id
            email
          }
        }
      ''';

      // Execute the mutation with the token
      final response = await dio.post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'token': token,
          },
        },
      );

      // Check for errors in the response
      if (response.statusCode == 200) {
        if (response.data['errors'] != null) {
          throw Exception('GraphQL errors: ${response.data['errors']}');
        }
        print('FCM token updated successfully.');
      } else {
        throw Exception(
            'Failed to update FCM token: Status Code ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
      throw Exception('Error updating FCM token: $e');
    }
  }
}
