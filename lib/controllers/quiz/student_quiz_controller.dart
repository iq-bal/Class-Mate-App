import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:classmate/models/quiz/student_quiz_model.dart';
import 'package:classmate/services/quiz/student_quiz_service.dart';

enum StudentQuizState {
  initial,
  loading,
  loaded,
  taking,
  submitting,
  submitted,
  error,
}

class StudentQuizController {
  final StudentQuizService _service = StudentQuizService();
  
  final ValueNotifier<StudentQuizState> _stateNotifier = ValueNotifier(StudentQuizState.initial);
  final ValueNotifier<int> _timeNotifier = ValueNotifier(0);
  
  List<StudentQuizModel> _quizzes = [];
  StudentQuizModel? _currentQuiz;
  Map<int, String> _currentAnswers = {};
  Timer? _quizTimer;
  int _timeRemaining = 0; // in seconds
  String? _errorMessage;
  StudentQuizSubmission? _lastSubmission;
  
  ValueNotifier<StudentQuizState> get stateNotifier => _stateNotifier;
  ValueNotifier<int> get timeNotifier => _timeNotifier;
  List<StudentQuizModel> get quizzes => _quizzes;
  StudentQuizModel? get currentQuiz => _currentQuiz;
  Map<int, String> get currentAnswers => _currentAnswers;
  int get timeRemaining => _timeRemaining;
  String? get errorMessage => _errorMessage;
  StudentQuizSubmission? get lastSubmission => _lastSubmission;

  bool _disposed = false;

  /// Load quizzes for a course
  Future<void> loadQuizzes(String courseId) async {
    if (_disposed) return;
    
    try {
      _stateNotifier.value = StudentQuizState.loading;
      _errorMessage = null;
      
      _quizzes = await _service.getQuizzesByCourseWithSubmissions(courseId);
      _stateNotifier.value = StudentQuizState.loaded;
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString();
      _stateNotifier.value = StudentQuizState.error;
      if (kDebugMode) {
        print('Error loading quizzes: $e');
      }
    }
  }

  /// Start taking a quiz
  Future<void> startQuiz(String quizId) async {
    if (_disposed) return;
    
    try {
      _stateNotifier.value = StudentQuizState.loading;
      _errorMessage = null;
      
      _currentQuiz = await _service.getQuizById(quizId);
      
      if (_currentQuiz != null) {
        _currentAnswers.clear();
        _timeRemaining = _currentQuiz!.duration * 60; // Convert minutes to seconds
        _timeNotifier.value = _timeRemaining;
        _startTimer();
        _stateNotifier.value = StudentQuizState.taking;
      } else {
        throw Exception('Quiz not found or not available');
      }
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString();
      _stateNotifier.value = StudentQuizState.error;
      if (kDebugMode) {
        print('Error starting quiz: $e');
      }
    }
  }

  /// Update answer for a question
  void updateAnswer(int questionId, String answer) {
    if (_disposed || _stateNotifier.value != StudentQuizState.taking) return;
    
    _currentAnswers[questionId] = answer;
  }

  /// Submit the quiz
  Future<void> submitQuiz() async {
    if (_disposed || _currentQuiz == null) return;
    
    try {
      _stateNotifier.value = StudentQuizState.submitting;
      _stopTimer();
      
      final timeTakenInMinutes = (_currentQuiz!.duration * 60 - _timeRemaining) ~/ 60;
      
      // Convert answers to the required format
      final answers = _currentAnswers.entries
          .map((entry) => StudentQuizAnswer(
                questionId: entry.key,
                selectedAnswer: entry.value,
                isCorrect: false, // This will be determined by the server
              ))
          .toList();
      
      final request = QuizSubmissionRequest(
        quizId: _currentQuiz!.id,
        answers: answers,
        timeTaken: timeTakenInMinutes,
      );
      
      _lastSubmission = await _service.submitQuiz(request);
      
      if (_lastSubmission != null) {
        _stateNotifier.value = StudentQuizState.submitted;
      } else {
        throw Exception('Failed to submit quiz');
      }
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString();
      _stateNotifier.value = StudentQuizState.error;
      if (kDebugMode) {
        print('Error submitting quiz: $e');
      }
    }
  }

  /// Start the quiz timer
  void _startTimer() {
    _quizTimer?.cancel();
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      
      if (_timeRemaining > 0) {
        _timeRemaining--;
        _timeNotifier.value = _timeRemaining;
      } else {
        // Time's up - auto submit
        timer.cancel();
        submitQuiz();
      }
    });
  }

  /// Stop the quiz timer
  void _stopTimer() {
    _quizTimer?.cancel();
    _quizTimer = null;
  }

  /// Exit quiz (without submitting)
  void exitQuiz() {
    _stopTimer();
    _currentQuiz = null;
    _currentAnswers.clear();
    _timeRemaining = 0;
    _stateNotifier.value = StudentQuizState.loaded;
  }

  /// Reset to show quiz list
  void resetToQuizList() {
    _stopTimer();
    _currentQuiz = null;
    _currentAnswers.clear();
    _timeRemaining = 0;
    _lastSubmission = null;
    _stateNotifier.value = StudentQuizState.loaded;
  }

  /// Get formatted time remaining
  String getFormattedTimeRemaining() {
    final minutes = _timeRemaining ~/ 60;
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if all questions are answered
  bool get areAllQuestionsAnswered {
    if (_currentQuiz == null) return false;
    return _currentQuiz!.questions.length == _currentAnswers.length;
  }

  /// Get quiz by ID from loaded quizzes
  StudentQuizModel? getQuizById(String quizId) {
    try {
      return _quizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }

  /// Retry loading quizzes
  Future<void> retry(String courseId) async {
    await loadQuizzes(courseId);
  }

  void dispose() {
    _disposed = true;
    _stopTimer();
    _stateNotifier.dispose();
    _timeNotifier.dispose();
  }
}
