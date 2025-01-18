import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/entity/task_entity.dart';
import 'package:dio/dio.dart';

class TaskService {
  final dioClient = DioClient();

  Future<void> createTask(TaskEntity task) async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String query = r'''
      mutation CreateTask($task: TaskInput!) {
        createTask(task: $task) {
          id
        }
      }
      ''';
      final response = await dio.post(
        '/',
        data: {
          'query': query,
          'variables': {'task': task.toJson()},
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }
}
