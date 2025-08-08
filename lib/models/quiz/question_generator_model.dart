class QuestionGeneratorModel {
  final String testTitle;
  final List<GeneratedQuestion> questions;

  QuestionGeneratorModel({
    required this.testTitle,
    required this.questions,
  });

  factory QuestionGeneratorModel.fromJson(Map<String, dynamic> json) {
    return QuestionGeneratorModel(
      testTitle: json['testTitle'] ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((q) => GeneratedQuestion.fromJson(q))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testTitle': testTitle,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class GeneratedQuestion {
  final int id;
  final String question;
  final QuestionOptions options;
  final String answer;

  GeneratedQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory GeneratedQuestion.fromJson(Map<String, dynamic> json) {
    return GeneratedQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      options: QuestionOptions.fromJson(json['options'] ?? {}),
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.toJson(),
      'answer': answer,
    };
  }
}

class QuestionOptions {
  final String a;
  final String b;
  final String c;
  final String d;

  QuestionOptions({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
  });

  factory QuestionOptions.fromJson(Map<String, dynamic> json) {
    return QuestionOptions(
      a: json['A'] ?? '',
      b: json['B'] ?? '',
      c: json['C'] ?? '',
      d: json['D'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'A': a,
      'B': b,
      'C': c,
      'D': d,
    };
  }
}

class QuizCreationRequest {
  final String courseId;
  final String testTitle;
  final List<QuizQuestionInput> questions;
  final int? duration;
  final int? totalMarks;

  QuizCreationRequest({
    required this.courseId,
    required this.testTitle,
    required this.questions,
    this.duration,
    this.totalMarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'testTitle': testTitle,
      'questions': questions.map((q) => q.toJson()).toList(),
      if (duration != null) 'duration': duration,
      if (totalMarks != null) 'total_marks': totalMarks,
    };
  }
}

class QuizQuestionInput {
  final int id;
  final String question;
  final Map<String, String> options;
  final String answer;

  QuizQuestionInput({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestionInput.fromGeneratedQuestion(GeneratedQuestion question) {
    return QuizQuestionInput(
      id: question.id,
      question: question.question,
      options: {
        'A': question.options.a,
        'B': question.options.b,
        'C': question.options.c,
        'D': question.options.d,
      },
      answer: question.answer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'answer': answer,
    };
  }
}
