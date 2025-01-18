import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/task/task_model.dart';
import 'package:classmate/models/task/user_model.dart';

class TaskService {
  final dioClient = DioClient();

  Future<void> createTask(TaskModel task) async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String query = r'''
        mutation CreateTask($taskInput: TaskInput!) {
        createTask(taskInput: $taskInput) {
          id
        }
      ''';
      final response = await dio.post(
        '/',
        data: {
          'query': query,
          'variables': {'taskInput':task.toJson()},
        },
      );
      if (response.statusCode == 200) {
        if (response.data['errors'] != null) {
          throw Exception(
            "GraphQL errors: ${response.data['errors']}",
          );
        }
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }



  Future<List<UserModel>> getUsers() async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String query = r'''
      query getUsers{
        users {
          id
          name
          profile_picture
        }
      }
      ''';



      final response = await dio.post(
        '/',
        data: {
          'query': query,
        },
      );










      if (response.statusCode == 200) {
        return (response.data['data']['users'] as List).map((user) => UserModel.fromJson(user)).toList();
      } else {
        throw Exception('Failed to get users');
      }
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }   


}
