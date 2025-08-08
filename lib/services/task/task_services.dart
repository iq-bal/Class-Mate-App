import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/task/task_model.dart';
import 'package:classmate/models/task/user_model.dart';

class TaskService {
  final dioClient = DioClient();

  Future<void> createTask(TaskModel task) async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String mutation = r'''
        mutation CreateTask($taskInput: TaskInput!) {
          createTask(taskInput: $taskInput) {
            id
          }
        }
      ''';

      final response = await dio.post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'taskInput': task.toJson()
          },
        },
      );

      if (response.statusCode == 200) {
        if (response.data['errors'] != null) {
          throw Exception('GraphQL errors: ${response.data['errors']}');
        }
        // Task created successfully
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
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


  Future<List<TaskModel>> getTasks() async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String query = r'''
      query getTasks {
        tasksByUser {
          id
          title
          date
          start_time
          end_time
          category
          participants {
            id
            profile_picture
          }
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
        if (response.data['errors'] != null) {
          throw Exception('GraphQL errors: ${response.data['errors']}');
        }
        
        // Debug print to see the response structure
        print('Response data: ${response.data}');
        
        final tasks = response.data['data']['tasksByUser'] as List;  // Changed from 'tasks' to 'tasksByUser'
        return tasks.map((task) => TaskModel.fromJson(task)).toList();
      } else {
        throw Exception('Failed to get tasks');
      }
    } catch (e) {
      print('Error in getTasks: $e'); // Debug print
      throw Exception('Failed to get tasks: $e');
    }
  }

  Future<List<TaskModel>> getTasksByDate(String date) async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String query = r'''
      query GetTasksByDate($date: String!) {
        tasksByUserAndDate(date: $date) {
          id
          title
          category
          date
          start_time
          end_time
          status
          participants {
            id
            name
            email
            status
            profile_picture
          }
        }
      }
      ''';
      
      final response = await dio.post(
        '/',
        data: {
          'query': query,
          'variables': {
            'date': date,
          },
        },
      );

      if (response.statusCode == 200) {
        if (response.data['errors'] != null) {
          throw Exception('GraphQL errors: ${response.data['errors']}');
        }
        
        // Debug print to see the response structure
        print('Tasks by date response: ${response.data}');
        
        final tasks = response.data['data']['tasksByUserAndDate'] as List;
        return tasks.map((task) => TaskModel.fromJson(task)).toList();
      } else {
        throw Exception('Failed to get tasks by date');
      }
    } catch (e) {
      print('Error in getTasksByDate: $e'); // Debug print
      throw Exception('Failed to get tasks by date: $e');
    }
  }


  Future<void> respondToInvitation(String taskId, String response) async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String mutation = r'''
        mutation RespondToTaskInvitation($taskId: ID!, $response: String!) {
          respondToTaskInvitation(taskId: $taskId, response: $response) {
            id
            title
            participants {
              id
              status
            }
          }
        }
      ''';

      final responseResult = await dio.post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'taskId': taskId,
            'response': response,
          },
        },
      );

      if (responseResult.statusCode == 200) {
        if (responseResult.data['errors'] != null) {
          throw Exception('GraphQL errors: ${responseResult.data['errors']}');
        }
        // Successfully responded to the task invitation
        print('Response data: ${responseResult.data}');
      } else {
        throw Exception(
            'Failed to respond to task invitation: ${responseResult.statusCode}');
      }
    } catch (e) {
      print('Error responding to task invitation: $e');
      rethrow;
    }
  }

  Future<void> updateTask(String id, TaskModel task) async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String mutation = r'''
        mutation UpdateTask($id: ID!, $taskInput: TaskInput!) { 
          updateTask(id: $id, taskInput: $taskInput) { 
            id 
            title 
            category 
            date 
            start_time 
            end_time 
            status 
            participants { 
              id 
              name 
              email 
              status 
            } 
          } 
        } 
      ''';

      final response = await dio.post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'id': id,
            'taskInput': task.toJson()
          },
        },
      );

      if (response.statusCode == 200) {
        if (response.data['errors'] != null) {
          throw Exception('GraphQL errors: ${response.data['errors']}');
        }
        // Task updated successfully
        print('Task updated successfully: ${response.data}');
      } else {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating task: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String mutation = r'''
        mutation DeleteTask($id: ID!) { 
          deleteTask(id: $id) { 
            id 
            title 
          } 
        } 
      ''';

      final response = await dio.post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'id': id
          },
        },
      );

      if (response.statusCode == 200) {
        if (response.data['errors'] != null) {
          throw Exception('GraphQL errors: ${response.data['errors']}');
        }
        // Task deleted successfully
        print('Task deleted successfully: ${response.data}');
      } else {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting task: $e');
      throw Exception('Failed to delete task: $e');
    }
  }

}
