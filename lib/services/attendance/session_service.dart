import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/entity/session_entity.dart';

class SessionService {
  final dioClient = DioClient();

  // Create a new session using GraphQL mutation
  Future<SessionEntity> createSession({
    required String courseId,
    required String title,
    required String description,
    required String date,
    required String startTime,
    required String endTime,
    String? meetingLink,
  }) async {
    const String mutation = '''
      mutation CreateSession(\$sessionInput: SessionInput!) {
        createSession(sessionInput: \$sessionInput) {
          id
          title
          description
          date
          start_time
          end_time
          status
          meeting_link
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'sessionInput': {
              'course_id': courseId,
              'title': title,
              'description': description,
              'date': date,
              'start_time': startTime,
              'end_time': endTime,
              'meeting_link': meetingLink ?? 'https://zoom.us/j/123456789',
            },
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['createSession'] != null) {
          return SessionEntity.fromJson(data['data']['createSession']);
        } else {
          throw Exception('Failed to create session');
        }
      } else {
        throw Exception('Failed to create session. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while creating session: $e');
    }
  }

  // Create a session specifically for attendance with default values
  Future<SessionEntity> createAttendanceSession({
    required String courseId,
    required String topic,
    String? meetingLink,
  }) async {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final startTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final endTime = '${(now.hour + 1).toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return createSession(
      courseId: courseId,
      title: 'Attendance Session - $topic',
      description: 'Attendance session for $topic',
      date: date,
      startTime: startTime,
      endTime: endTime,
      meetingLink: meetingLink,
    );
  }
}