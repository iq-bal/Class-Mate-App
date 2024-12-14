import 'package:classmate/models/submission_model.dart';
import 'package:test/test.dart';

void main() {
  group('SubmissionModel', () {
    test('fromJson correctly creates a SubmissionModel instance', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'assignment_id': '101',
        'student_id': '2001',
        'file_url': 'https://example.com/file.pdf',
        'plagiarism_score': '20',
        'teacher_comments': 'Well done!',
        'grade': 'A',
        'submitted_at': '2024-12-14T10:00:00Z',
      };

      final submission = SubmissionModel.fromJson(json);

      expect(submission.id, '1');
      expect(submission.assignmentId, '101');
      expect(submission.studentId, '2001');
      expect(submission.fileUrl, 'https://example.com/file.pdf');
      expect(submission.plagiarismScore, '20');
      expect(submission.teacherComment, 'Well done!');
      expect(submission.grade, 'A');
      expect(submission.submittedAt, '2024-12-14T10:00:00Z');
    });

    test('toJson correctly converts a SubmissionModel to JSON', () {
      final submission = SubmissionModel(
        id: '1',
        assignmentId: '101',
        studentId: '2001',
        fileUrl: 'https://example.com/file.pdf',
        plagiarismScore: '20',
        teacherComment: 'Well done!',
        grade: 'A',
        submittedAt: '2024-12-14T10:00:00Z',
      );

      final json = submission.toJson();

      expect(json['id'], '1');
      expect(json['assignment_id'], '101');
      expect(json['student_id'], '2001');
      expect(json['file_url'], 'https://example.com/file.pdf');
      expect(json['plagiarism_score'], '20');
      expect(json['teacher_comments'], 'Well done!');
      expect(json['grade'], 'A');
      expect(json['submitted_at'], '2024-12-14T10:00:00Z');
    });

    test('fromJson handles null values gracefully', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'assignment_id': null,
        'student_id': '2001',
        'file_url': null,
        'plagiarism_score': null,
        'teacher_comments': null,
        'grade': 'B',
        'submitted_at': '2024-12-14T10:00:00Z',
      };

      final submission = SubmissionModel.fromJson(json);

      expect(submission.id, '1');
      expect(submission.assignmentId, null);
      expect(submission.studentId, '2001');
      expect(submission.fileUrl, null);
      expect(submission.plagiarismScore, null);
      expect(submission.teacherComment, null);
      expect(submission.grade, 'B');
      expect(submission.submittedAt, '2024-12-14T10:00:00Z');
    });
  });
}
