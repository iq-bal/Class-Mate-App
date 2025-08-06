import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/create_course/schedule_model.dart';

class RescheduleService {
  final dioClient = DioClient();

  /// Update course schedule using GraphQL mutation
  /// This will trigger notifications to all approved students
  Future<ScheduleModel> updateSchedule({
    required String scheduleId,
    required ScheduleModel scheduleData,
  }) async {
    print("------------------------");
    print(scheduleId);
    print(scheduleData);
    print("------------------------");
    const String mutation = '''
    mutation UpdateSchedule(\$id: ID!, \$scheduleInput: ScheduleInput!) {
      updateSchedule(id: \$id, scheduleInput: \$scheduleInput) {
        id
        day
        start_time
        end_time
        room_number
        section
        course_id {
          id
          title
        }
        teacher_id {
          id
        }
      }
    }
    ''';

    try {
      final requestData = {
        'query': mutation,
        'variables': {
          'id': scheduleId,
          'scheduleInput': {
            'course_id': scheduleData.courseId,
            'day': scheduleData.day,
            'start_time': scheduleData.startTime,
            'end_time': scheduleData.endTime,
            'room_number': scheduleData.roomNumber,
            'section': scheduleData.section,
          },
        }
      };
      
      print('Sending GraphQL request: $requestData');
      
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['updateSchedule'] != null) {
          final scheduleData = data['data']['updateSchedule'];
          return ScheduleModel(
            id: scheduleData['id'],
            courseId: scheduleData['course_id']['id'],
            day: scheduleData['day'],
            section: scheduleData['section'],
            startTime: scheduleData['start_time'],
            endTime: scheduleData['end_time'],
            roomNumber: scheduleData['room_number'],
          );
        } else {
          throw Exception('Failed to update schedule');
        }
      } else {
        throw Exception('Failed to update schedule. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while updating schedule: $e');
    }
  }

  /// Get current schedule details
  Future<ScheduleModel> getSchedule(String scheduleId) async {
    const String query = '''
    query GetSchedule(\$scheduleId: ID!) {
      schedule(id: \$scheduleId) {
        id
        day
        start_time
        end_time
        room_number
        section
        course_id {
          id
          title
        }
      }
    }
    ''';

    try {
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {
          'query': query,
          'variables': {
            'scheduleId': scheduleId,
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['schedule'] != null) {
          final scheduleData = data['data']['schedule'];
          return ScheduleModel(
            id: scheduleData['id'],
            courseId: scheduleData['course_id']['id'],
            day: scheduleData['day'],
            section: scheduleData['section'],
            startTime: scheduleData['start_time'],
            endTime: scheduleData['end_time'],
            roomNumber: scheduleData['room_number'],
          );
        } else {
          throw Exception('Schedule not found');
        }
      } else {
        throw Exception('Failed to get schedule. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while getting schedule: $e');
    }
  }
}