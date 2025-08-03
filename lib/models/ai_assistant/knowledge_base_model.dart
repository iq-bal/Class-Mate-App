class KnowledgeBase {
  final String id;
  final String filename;
  final DateTime uploadTime;
  final int textLength;
  final String status;
  final String? message;

  KnowledgeBase({
    required this.id,
    required this.filename,
    required this.uploadTime,
    required this.textLength,
    required this.status,
    this.message,
  });

  factory KnowledgeBase.fromJson(Map<String, dynamic> json) {
    return KnowledgeBase(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      uploadTime: DateTime.parse(json['upload_time'] ?? DateTime.now().toIso8601String()),
      textLength: json['text_length'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'upload_time': uploadTime.toIso8601String(),
      'text_length': textLength,
      'status': status,
      if (message != null) 'message': message,
    };
  }
}

class QuestionRequest {
  final String question;
  final String knowledgeBaseId;

  QuestionRequest({
    required this.question,
    required this.knowledgeBaseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'knowledge_base_id': knowledgeBaseId,
    };
  }
}

class QuestionResponse {
  final String answer;
  final String knowledgeBaseId;
  final String question;
  final DateTime timestamp;

  QuestionResponse({
    required this.answer,
    required this.knowledgeBaseId,
    required this.question,
    required this.timestamp,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      answer: json['answer'] ?? '',
      knowledgeBaseId: json['knowledge_base_id'] ?? '',
      question: json['question'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class KnowledgeBasePreview {
  final String knowledgeBaseId;
  final String filename;
  final String preview;
  final int totalLength;
  final int previewLength;

  KnowledgeBasePreview({
    required this.knowledgeBaseId,
    required this.filename,
    required this.preview,
    required this.totalLength,
    required this.previewLength,
  });

  factory KnowledgeBasePreview.fromJson(Map<String, dynamic> json) {
    return KnowledgeBasePreview(
      knowledgeBaseId: json['knowledge_base_id'] ?? '',
      filename: json['filename'] ?? '',
      preview: json['preview'] ?? '',
      totalLength: json['total_length'] ?? 0,
      previewLength: json['preview_length'] ?? 0,
    );
  }
}