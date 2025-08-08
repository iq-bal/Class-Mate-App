import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:classmate/models/quiz/question_generator_model.dart';
import 'package:classmate/models/home_teacher/teacher_dashboard_model.dart';
import 'package:classmate/services/quiz/question_generator_service.dart';
import 'package:classmate/services/quiz/quiz_service.dart';
import 'package:classmate/services/home_teacher/teacher_dashboard_service.dart';

enum QuizState {
  initial,
  loading,
  questionsGenerated,
  quizCreated,
  error,
}

class QuizController {
  final QuestionGeneratorService _questionGeneratorService = QuestionGeneratorService();
  final QuizService _quizService = QuizService();
  final TeacherDashboardService _teacherService = TeacherDashboardService();
  
  final ValueNotifier<QuizState> _stateNotifier = ValueNotifier(QuizState.initial);
  
  QuestionGeneratorModel? _generatedQuestions;
  List<CourseModel> _teacherCourses = [];
  String? _errorMessage;
  bool _isServiceHealthy = false;
  
  ValueNotifier<QuizState> get stateNotifier => _stateNotifier;
  QuestionGeneratorModel? get generatedQuestions => _generatedQuestions;
  List<CourseModel> get teacherCourses => _teacherCourses;
  String? get errorMessage => _errorMessage;
  bool get isServiceHealthy => _isServiceHealthy;

  bool _disposed = false;

  /// Initialize the controller
  Future<void> initialize() async {
    if (_disposed) return;
    
    await Future.wait([
      _checkServiceHealth(),
      _fetchTeacherCourses(),
    ]);
  }

  /// Check if question generator service is available
  Future<void> _checkServiceHealth() async {
    try {
      _isServiceHealthy = await _questionGeneratorService.checkHealth();
      if (kDebugMode) {
        print('Question generator service health: $_isServiceHealthy');
      }
    } catch (e) {
      _isServiceHealthy = false;
      if (kDebugMode) {
        print('Error checking service health: $e');
      }
    }
  }

  /// Fetch teacher's courses
  Future<void> _fetchTeacherCourses() async {
    try {
      final dashboardData = await _teacherService.getMyCreatedCourses();
      if (dashboardData != null) {
        _teacherCourses = dashboardData.user.courses;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching teacher courses: $e');
      }
    }
  }

  /// Generate questions from PDF
  Future<void> generateQuestionsFromPDF({
    required File pdfFile,
    int numQuestions = 5,
    String difficulty = 'medium',
    String testTitle = 'Generated Quiz',
  }) async {
    if (_disposed) return;
    
    try {
      _stateNotifier.value = QuizState.loading;
      _errorMessage = null;

      if (!_isServiceHealthy) {
        await _checkServiceHealth();
        if (!_isServiceHealthy) {
          throw Exception('Question generator service is not available. Please ensure the service is running on localhost:8001');
        }
      }

      final result = await _questionGeneratorService.generateQuestions(
        pdfFile: pdfFile,
        numQuestions: numQuestions,
        difficulty: difficulty,
        testTitle: testTitle,
      );

      if (result != null && result.questions.isNotEmpty) {
        _generatedQuestions = result;
        _stateNotifier.value = QuizState.questionsGenerated;
      } else {
        throw Exception('No questions were generated from the PDF. Please ensure the PDF contains readable text content.');
      }
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString();
      _stateNotifier.value = QuizState.error;
      if (kDebugMode) {
        print('Error generating questions: $e');
      }
    }
  }

  /// Create quiz from generated questions
  Future<void> createQuiz({
    required String courseId,
    required String testTitle,
    int? duration,
    int? totalMarks,
  }) async {
    if (_disposed) return;
    
    if (_generatedQuestions == null) {
      _errorMessage = 'No questions available to create quiz';
      _stateNotifier.value = QuizState.error;
      return;
    }

    try {
      _stateNotifier.value = QuizState.loading;
      _errorMessage = null;

      // Convert generated questions to quiz input format
      final quizQuestions = _generatedQuestions!.questions
          .map((q) => QuizQuestionInput.fromGeneratedQuestion(q))
          .toList();

      final result = await _quizService.createQuiz(
        courseId: courseId,
        testTitle: testTitle,
        questions: quizQuestions,
        duration: duration ?? 60, // Default 60 minutes
        totalMarks: totalMarks ?? quizQuestions.length, // Default 1 mark per question
      );

      if (result != null) {
        _stateNotifier.value = QuizState.quizCreated;
      } else {
        throw Exception('Failed to create quiz. Please try again.');
      }
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString();
      _stateNotifier.value = QuizState.error;
      if (kDebugMode) {
        print('Error creating quiz: $e');
      }
    }
  }

  /// Reset state to initial
  void resetState() {
    if (_disposed) return;
    _generatedQuestions = null;
    _errorMessage = null;
    _stateNotifier.value = QuizState.initial;
  }

  /// Get course by ID
  CourseModel? getCourseById(String courseId) {
    try {
      return _teacherCourses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  /// Retry last operation
  Future<void> retry() async {
    if (_disposed) return;
    
    switch (_stateNotifier.value) {
      case QuizState.error:
        // Reset to initial state and let user try again
        resetState();
        await initialize();
        break;
      default:
        break;
    }
  }

  void dispose() {
    _disposed = true;
    _stateNotifier.dispose();
  }
}
