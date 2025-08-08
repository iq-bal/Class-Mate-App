import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/quiz/student_quiz_model.dart';

class StudentQuizService {
  final DioClient _dioClient = DioClient();

  /// Get active quizzes for a course (for students)
  Future<List<StudentQuizModel>> getActiveQuizzesByCourse(String courseId) async {
    try {
      const String query = '''
        query GetActiveQuizzesByCourse(\$course_id: ID!) {
          activeQuizzesByCourse(course_id: \$course_id) {
            id
            testTitle
            duration
            total_marks
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
        
        if (data['data'] != null && data['data']['activeQuizzesByCourse'] != null) {
          final quizzes = List<Map<String, dynamic>>.from(data['data']['activeQuizzesByCourse']);
          return quizzes.map((quiz) => StudentQuizModel.fromJson(quiz)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching active quizzes: $e');
      rethrow;
    }
  }

  /// Get quiz by ID with questions (for taking the quiz)
  Future<StudentQuizModel?> getQuizById(String quizId) async {
    try {
      const String query = '''
        query GetQuiz(\$id: ID!) {
          quiz(id: \$id) {
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
        'id': quizId,
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
        
        if (data['data'] != null && data['data']['quiz'] != null) {
          return StudentQuizModel.fromJson(data['data']['quiz']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching quiz: $e');
      rethrow;
    }
  }

  /// Submit quiz answers
  Future<StudentQuizSubmission?> submitQuiz(QuizSubmissionRequest request) async {
    try {
      const String mutation = '''
        mutation SubmitQuiz(\$input: SubmitQuizInput!) {
          submitQuiz(input: \$input) {
            id
            answers {
              question_id
              selected_answer
              is_correct
            }
            score
            total_marks
            percentage
            time_taken
            submitted_at
            attempt_number
            quiz {
              id
              testTitle
              course {
                title
                course_code
              }
            }
          }
        }
      ''';

      final variables = {
        'input': request.toJson(),
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
        
        if (data['data'] != null && data['data']['submitQuiz'] != null) {
          return StudentQuizSubmission.fromJson(data['data']['submitQuiz']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error submitting quiz: $e');
      rethrow;
    }
  }

  /// Get student's quiz submissions
  Future<List<StudentQuizSubmission>> getMyQuizSubmissions() async {
    try {
      const String query = '''
        query GetMyQuizSubmissions {
          myQuizSubmissions {
            id
            score
            total_marks
            percentage
            time_taken
            submitted_at
            attempt_number
            quiz {
              id
              testTitle
              course {
                title
                course_code
              }
            }
          }
        }
      ''';

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }
        
        if (data['data'] != null && data['data']['myQuizSubmissions'] != null) {
          final submissions = List<Map<String, dynamic>>.from(data['data']['myQuizSubmissions']);
          return submissions.map((submission) => StudentQuizSubmission.fromJson(submission)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching quiz submissions: $e');
      rethrow;
    }
  }

  /// Get quizzes by course with submission status
  Future<List<StudentQuizModel>> getQuizzesByCourseWithSubmissions(String courseId) async {
    try {
      // First get active quizzes
      final quizzes = await getActiveQuizzesByCourse(courseId);
      
      // Then get my submissions
      final submissions = await getMyQuizSubmissions();
      
      // Match submissions to quizzes
      final List<StudentQuizModel> quizzesWithSubmissions = [];
      
      for (final quiz in quizzes) {
        // Find submission for this specific quiz
        StudentQuizSubmission? submission;
        try {
          // Match by quiz ID from the nested quiz object in submission
          submission = submissions.firstWhere((s) => 
            s.quiz != null && s.quiz!.id == quiz.id
          );
        } catch (e) {
          // No submission found for this quiz
          submission = null;
        }
            
        quizzesWithSubmissions.add(StudentQuizModel(
          id: quiz.id,
          testTitle: quiz.testTitle,
          duration: quiz.duration,
          totalMarks: quiz.totalMarks,
          isActive: quiz.isActive,
          createdAt: quiz.createdAt,
          questions: quiz.questions,
          mySubmission: submission,
        ));
      }
      
      return quizzesWithSubmissions;
    } catch (e) {
      print('Error fetching quizzes with submissions: $e');
      rethrow;
    }
  }
}
