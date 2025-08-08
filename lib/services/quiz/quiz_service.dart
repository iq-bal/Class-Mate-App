import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/quiz/question_generator_model.dart';

class QuizService {
  final DioClient _dioClient = DioClient();

  /// Create a quiz using GraphQL mutation
  Future<Map<String, dynamic>?> createQuiz({
    required String courseId,
    required String testTitle,
    required List<QuizQuestionInput> questions,
    int? duration,
    int? totalMarks,
  }) async {
    try {
      const String mutation = '''
        mutation CreateQuiz(\$input: CreateQuizInput!) {
          createQuiz(input: \$input) {
            id
            testTitle
            questions {
              id
              question
              options {
                A
                B
                C
                D
              }
              answer
            }
            duration
            total_marks
            is_active
            created_at
            course {
              id
              title
              course_code
            }
          }
        }
      ''';

      final variables = {
        'input': {
          'course_id': courseId,
          'testTitle': testTitle,
          'questions': questions.map((q) => q.toJson()).toList(),
          if (duration != null) 'duration': duration,
          if (totalMarks != null) 'total_marks': totalMarks,
        },
      };

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': variables,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }
        
        if (data['data'] != null && data['data']['createQuiz'] != null) {
          return data['data']['createQuiz'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error creating quiz: $e');
      rethrow;
    }
  }

  /// Get quizzes by teacher
  Future<List<Map<String, dynamic>>> getQuizzesByTeacher(String teacherId) async {
    try {
      const String query = '''
        query GetQuizzesByTeacher(\$teacher_id: ID!) {
          quizzesByTeacher(teacher_id: \$teacher_id) {
            id
            testTitle
            duration
            total_marks
            is_active
            created_at
            course {
              id
              title
              course_code
            }
          }
        }
      ''';

      final variables = {
        'teacher_id': teacherId,
      };

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
          'variables': variables,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }
        
        if (data['data'] != null && data['data']['quizzesByTeacher'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['quizzesByTeacher']);
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching quizzes by teacher: $e');
      rethrow;
    }
  }

  /// Get quizzes by course
  Future<List<Map<String, dynamic>>> getQuizzesByCourse(String courseId) async {
    try {
      const String query = '''
        query GetQuizzesByCourse(\$course_id: ID!) {
          quizzesByCourse(course_id: \$course_id) {
            id
            testTitle
            duration
            total_marks
            is_active
            created_at
            questions {
              id
              question
              options {
                A
                B
                C
                D
              }
            }
          }
        }
      ''';

      final variables = {
        'course_id': courseId,
      };

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
          'variables': variables,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }
        
        if (data['data'] != null && data['data']['quizzesByCourse'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['quizzesByCourse']);
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching quizzes by course: $e');
      rethrow;
    }
  }

  /// Delete quiz
  Future<bool> deleteQuiz(String quizId) async {
    try {
      const String mutation = '''
        mutation DeleteQuiz(\$id: ID!) {
          deleteQuiz(id: \$id)
        }
      ''';

      final variables = {
        'id': quizId,
      };

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': variables,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }
        
        return data['data']['deleteQuiz'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting quiz: $e');
      rethrow;
    }
  }

  /// Toggle quiz status
  Future<Map<String, dynamic>?> toggleQuizStatus(String quizId) async {
    try {
      const String mutation = '''
        mutation ToggleQuizStatus(\$id: ID!) {
          toggleQuizStatus(id: \$id) {
            id
            testTitle
            is_active
            updated_at
          }
        }
      ''';

      final variables = {
        'id': quizId,
      };

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': variables,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }
        
        if (data['data'] != null && data['data']['toggleQuizStatus'] != null) {
          return data['data']['toggleQuizStatus'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error toggling quiz status: $e');
      rethrow;
    }
  }
}
