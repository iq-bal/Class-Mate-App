import 'package:classmate/models/course_detail_teacher/assignment_entity.dart';
import 'package:test/test.dart';

void main() {
  group('AssignmentEntity', () {
    test('should correctly parse JSON into AssignmentEntity', () {
      // Sample JSON data for testing
      final json = {
        "id": "675cba0a097be65e5ced61b9",
        "course_id": "675c910186e75d98dc7c5cae",
        "title": "Introduction to Data Structures",
        "description": "Complete the exercises on arrays, linked lists, and stacks.",
        "deadline": "1734717599000",
        "created_at": "1734130186039",
        "submissions": [
          {
            "id": "675d8e619011ce0e37bd1118",
            "assignment_id": "675cba0a097be65e5ced61b9",
            "plagiarism_score": 10,
            "student_id": "675cb131c80792e9f500f2d5",
            "grade": "A",
            "file_url": "https://example.com/submission1.pdf",
            "teacher_comments": "Well done!",
            "submitted_at": "1734184545228",
            "evaluated_at": null
          },
          {
            "id": "675d8e6264a7ef37888fe18b",
            "assignment_id": "675cba0a097be65e5ced61b9",
            "plagiarism_score": 10,
            "student_id": "675cb131c80792e9f500f2d5",
            "grade": "A",
            "file_url": "https://example.com/submission1.pdf",
            "teacher_comments": "Well done!",
            "submitted_at": "1734184546673",
            "evaluated_at": null
          },
          {
            "id": "675d8e6264a7ef37888fe18c",
            "assignment_id": "675cba0a097be65e5ced61b9",
            "plagiarism_score": 20,
            "student_id": "675cb131c80792e9f500f2d6",
            "grade": "B",
            "file_url": "https://example.com/submission2.pdf",
            "teacher_comments": "Good effort!",
            "submitted_at": "1734184546674",
            "evaluated_at": null
          },
          {
            "id": "675d8e658ce87f5f2b6cece8",
            "assignment_id": "675cba0a097be65e5ced61b9",
            "plagiarism_score": 10,
            "student_id": "675cb131c80792e9f500f2d5",
            "grade": "A",
            "file_url": "https://example.com/submission1.pdf",
            "teacher_comments": "Well done!",
            "submitted_at": "1734184549940",
            "evaluated_at": null
          },
          {
            "id": "675d8e658ce87f5f2b6cece9",
            "assignment_id": "675cba0a097be65e5ced61b9",
            "plagiarism_score": 20,
            "student_id": "675cb131c80792e9f500f2d6",
            "grade": "B",
            "file_url": "https://example.com/submission2.pdf",
            "teacher_comments": "Good effort!",
            "submitted_at": "1734184549940",
            "evaluated_at": null
          },
          {
            "id": "675d8e658ce87f5f2b6cecea",
            "assignment_id": "675cba0a097be65e5ced61b9",
            "plagiarism_score": 15,
            "student_id": "675cb131c80792e9f500f2d7",
            "grade": "A",
            "file_url": "https://example.com/submission3.pdf",
            "teacher_comments": "Keep it up!",
            "submitted_at": "1734184549941",
            "evaluated_at": null
          },
          {
            "id": "675d8ecdb7ad5fe83b41b3b3",
            "assignment_id": "675cba0a097be65e5ced61b9",
            "plagiarism_score": 10,
            "student_id": "675cb131c80792e9f500f2d5",
            "grade": "A",
            "file_url": "https://example.com/submission1.pdf",
            "teacher_comments": "Well done!",
            "submitted_at": "1734184653440",
            "evaluated_at": null
          },
          {
            "id": "675d8ecdb7ad5fe83b41b3b4",
            "assignment_id": "675cba0a097be65e5ced61b9",
            "plagiarism_score": 20,
            "student_id": "675cb131c80792e9f500f2d6",
            "grade": "B",
            "file_url": "https://example.com/submission2.pdf",
            "teacher_comments": "Good effort!",
            "submitted_at": "1734184653441",
            "evaluated_at": null
          },
          {
            "id": "675d8ed1d80f937af79dfa05",
            "assignment_id": "675cba0a097be65e5ced61b9",
            "plagiarism_score": 20,
            "student_id": "675cb131c80792e9f500f2d6",
            "grade": "B",
            "file_url": "https://example.com/submission2.pdf",
            "teacher_comments": "Good effort!",
            "submitted_at": "1734184657851",
            "evaluated_at": null
          }
        ]
      };

      // Parse the JSON data using AssignmentEntity.fromJson
      final assignmentEntity = AssignmentEntity.fromJson(json);

      // Check that the basic fields are parsed correctly
      expect(assignmentEntity.id, '675cba0a097be65e5ced61b9');
      expect(assignmentEntity.title, 'Introduction to Data Structures');
      expect(assignmentEntity.description, 'Complete the exercises on arrays, linked lists, and stacks.');
      expect(assignmentEntity.deadline, '1734717599000');
      expect(assignmentEntity.createdAt, '1734130186039');
      expect(assignmentEntity.courseId, '675c910186e75d98dc7c5cae');

      // Check that the submissions list is parsed correctly
      expect(assignmentEntity.submissions.length, 9);

      // Check the details of the first submission
      final firstSubmission = assignmentEntity.submissions[0];
      expect(firstSubmission.id, '675d8e619011ce0e37bd1118');
      expect(firstSubmission.grade, 'A');
      expect(firstSubmission.fileUrl, 'https://example.com/submission1.pdf');
      expect(firstSubmission.teacherComment, 'Well done!');
      expect(firstSubmission.submittedAt, '1734184545228');
    });
  });
}
