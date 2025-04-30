import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/create_course/schedule_model.dart';

class ScheduleService {
  final dioClient = DioClient();
  // Create a new schedule by sending the mutation to the GraphQL server
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    const String mutation = '''
    mutation CreateSchedule(\$scheduleInput: ScheduleInput!) {
      createSchedule(scheduleInput: \$scheduleInput) {
        id
        day
        section
        start_time
        end_time
        room_number
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
            'scheduleInput': schedule.toJson(),
          }
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['createSchedule'] != null) {
          return ScheduleModel.fromJson(data['data']['createSchedule']);
        } else {
          throw Exception('Failed to create schedule');
        }
      } else {
        throw Exception('Failed to create schedule. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while creating schedule: $e');
    }
  }
}
