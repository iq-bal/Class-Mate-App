class StudentQuizModel {
  final String id;
  final String testTitle;
  final int duration;
  final int totalMarks;
  final bool isActive;
  final String createdAt;
  final List<StudentQuizQuestion> questions;
  final StudentQuizSubmission? mySubmission;

  StudentQuizModel({
    required this.id,
    required this.testTitle,
    required this.duration,
    required this.totalMarks,
    required this.isActive,
    required this.createdAt,
    required this.questions,
    this.mySubmission,
  });

  factory StudentQuizModel.fromJson(Map<String, dynamic> json) {
    return StudentQuizModel(
      id: json['id']?.toString() ?? '',
      testTitle: json['testTitle']?.toString() ?? '',
      duration: json['duration'] ?? 0,
      totalMarks: json['total_marks'] ?? 0,
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((q) => StudentQuizQuestion.fromJson(q))
          .toList(),
      mySubmission: json['mySubmission'] != null 
          ? StudentQuizSubmission.fromJson(json['mySubmission'])
          : null,
    );
  }
}

class StudentQuizQuestion {
  final int id;
  final String question;
  final StudentQuizOptions options;

  StudentQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory StudentQuizQuestion.fromJson(Map<String, dynamic> json) {
    return StudentQuizQuestion(
      id: json['id'] ?? 0,
      question: json['question']?.toString() ?? '',
      options: StudentQuizOptions.fromJson(json['options'] ?? {}),
    );
  }
}

class StudentQuizOptions {
  final String a;
  final String b;
  final String c;
  final String d;

  StudentQuizOptions({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
  });

  factory StudentQuizOptions.fromJson(Map<String, dynamic> json) {
    return StudentQuizOptions(
      a: json['A']?.toString() ?? '',
      b: json['B']?.toString() ?? '',
      c: json['C']?.toString() ?? '',
      d: json['D']?.toString() ?? '',
    );
  }
}

class StudentQuizSubmission {
  final String id;
  final int score;
  final int totalMarks;
  final double percentage;
  final int timeTaken;
  final String submittedAt;
  final int attemptNumber;
  final List<StudentQuizAnswer>? answers;
  final StudentQuizInfo? quiz; // Nested quiz info in submission

  StudentQuizSubmission({
    required this.id,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.timeTaken,
    required this.submittedAt,
    required this.attemptNumber,
    this.answers,
    this.quiz,
  });

  factory StudentQuizSubmission.fromJson(Map<String, dynamic> json) {
    return StudentQuizSubmission(
      id: json['id']?.toString() ?? '',
      score: json['score'] ?? 0,
      totalMarks: json['total_marks'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      timeTaken: json['time_taken'] ?? 0,
      submittedAt: json['submitted_at']?.toString() ?? '',
      attemptNumber: json['attempt_number'] ?? 1,
      answers: json['answers'] != null 
          ? (json['answers'] as List)
              .map((a) => StudentQuizAnswer.fromJson(a))
              .toList()
          : null,
      quiz: json['quiz'] != null 
          ? StudentQuizInfo.fromJson(json['quiz'])
          : null,
    );
  }
}

class StudentQuizInfo {
  final String id;
  final String testTitle;
  final StudentCourseInfo? course;
  final List<StudentQuizQuestionWithAnswer>? questions;

  StudentQuizInfo({
    required this.id,
    required this.testTitle,
    this.course,
    this.questions,
  });

  factory StudentQuizInfo.fromJson(Map<String, dynamic> json) {
    return StudentQuizInfo(
      id: json['id']?.toString() ?? '',
      testTitle: json['testTitle']?.toString() ?? '',
      course: json['course'] != null 
          ? StudentCourseInfo.fromJson(json['course'])
          : null,
      questions: json['questions'] != null 
          ? (json['questions'] as List)
              .map((q) => StudentQuizQuestionWithAnswer.fromJson(q))
              .toList()
          : null,
    );
  }
}

class StudentQuizQuestionWithAnswer {
  final int id;
  final String question;
  final StudentQuizOptions options;
  final String answer; // Correct answer

  StudentQuizQuestionWithAnswer({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory StudentQuizQuestionWithAnswer.fromJson(Map<String, dynamic> json) {
    return StudentQuizQuestionWithAnswer(
      id: json['id'] ?? 0,
      question: json['question']?.toString() ?? '',
      options: StudentQuizOptions.fromJson(json['options'] ?? {}),
      answer: json['answer']?.toString() ?? '',
    );
  }
}

class StudentCourseInfo {
  final String title;
  final String courseCode;

  StudentCourseInfo({
    required this.title,
    required this.courseCode,
  });

  factory StudentCourseInfo.fromJson(Map<String, dynamic> json) {
    return StudentCourseInfo(
      title: json['title']?.toString() ?? '',
      courseCode: json['course_code']?.toString() ?? '',
    );
  }
}

class StudentQuizAnswer {
  final int questionId;
  final String selectedAnswer;
  final bool isCorrect;

  StudentQuizAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  factory StudentQuizAnswer.fromJson(Map<String, dynamic> json) {
    return StudentQuizAnswer(
      questionId: json['question_id'] ?? 0,
      selectedAnswer: json['selected_answer']?.toString() ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_answer': selectedAnswer,
    };
  }
}

class QuizSubmissionRequest {
  final String quizId;
  final List<StudentQuizAnswer> answers;
  final int timeTaken;

  QuizSubmissionRequest({
    required this.quizId,
    required this.answers,
    required this.timeTaken,
  });

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'answers': answers.map((a) => a.toJson()).toList(),
      'time_taken': timeTaken,
    };
  }
}
