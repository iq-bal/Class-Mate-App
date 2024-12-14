// Test file for AssignmentModel
import 'package:classmate/models/assignment_model.dart';

void main() {
  // Test the factory constructor
  Map<String, dynamic> json = {
    'id': '1',
    'course_id': '101',
    'title': 'Math Assignment',
    'description': 'Solve all problems in chapter 2.',
    'deadline': '2024-12-20',
    'created_at': '2024-12-14',
  };

  AssignmentModel assignment = AssignmentModel.fromJson(json);

  assert(assignment.id == '1');
  assert(assignment.courseId == '101');
  assert(assignment.title == 'Math Assignment');
  assert(assignment.description == 'Solve all problems in chapter 2.');
  assert(assignment.deadline == '2024-12-20');
  assert(assignment.createdAt == '2024-12-14');

  // Test toJson method
  Map<String, dynamic> assignmentJson = assignment.toJson();

  assert(assignmentJson['id'] == '1');
  assert(assignmentJson['course_id'] == '101');
  assert(assignmentJson['title'] == 'Math Assignment');
  assert(assignmentJson['description'] == 'Solve all problems in chapter 2.');
  assert(assignmentJson['deadline'] == '2024-12-20');
  assert(assignmentJson['created_at'] == '2024-12-14');

  print("All tests passed!");
}