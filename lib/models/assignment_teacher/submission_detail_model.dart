import 'assignment_submission_model.dart';
import 'package:classmate/models/assignment_teacher/submission_model.dart' as submission_model;
import 'package:classmate/entity/student_entity.dart';
import 'package:classmate/entity/assignment_entity.dart';

class CourseInfo {
  final String id;
  final String title;
  final String courseCode;

  const CourseInfo({
    required this.id,
    required this.title,
    required this.courseCode,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      courseCode: json['course_code']?.toString() ?? '',
    );
  }
}

class AssignmentWithSubmissions {
  final String id;
  final String title;
  final String description;
  final DateTime? deadline;
  final DateTime? createdAt;
  final CourseInfo course;
  final List<SubmissionModel> submissions;
  final int submissionCount;

  const AssignmentWithSubmissions({
    required this.id,
    required this.title,
    required this.description,
    this.deadline,
    this.createdAt,
    required this.course,
    required this.submissions,
    required this.submissionCount,
  });

  factory AssignmentWithSubmissions.fromJson(Map<String, dynamic> json) {
    return AssignmentWithSubmissions(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      course: CourseInfo.fromJson(json['course'] as Map<String, dynamic>),
      submissions: (json['submissions'] as List<dynamic>? ?? [])
          .map((e) => SubmissionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      submissionCount: json['submissionCount'] as int? ?? 0,
    );
  }
}

class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String? fileUrl;
  final String? plagiarismScore;
  final bool? aiGenerated;
  final String? teacherComments;
  final String? grade;
  final DateTime? submittedAt;
  final DateTime? evaluatedAt;
  final StudentInfo student;

  const SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.fileUrl,
    this.plagiarismScore,
    this.aiGenerated,
    this.teacherComments,
    this.grade,
    this.submittedAt,
    this.evaluatedAt,
    required this.student,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
      plagiarismScore: json['plagiarism_score']?.toString(),
      aiGenerated: json['ai_generated'] is int ? (json['ai_generated'] as int) == 1 : json['ai_generated'] as bool?,
      teacherComments: json['teacher_comments']?.toString(),
      grade: json['grade']?.toString(),
      submittedAt: json['submitted_at'] != null ? DateTime.tryParse(json['submitted_at'].toString()) : null,
      evaluatedAt: json['evaluated_at'] != null ? DateTime.tryParse(json['evaluated_at'].toString()) : null,
      student: StudentInfo.fromJson(json['student'] as Map<String, dynamic>),
    );
  }
}

class StudentInfo {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String roll;
  final String section;

  const StudentInfo({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.roll,
    required this.section,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString(),
      roll: json['roll']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
    );
  }
}

class SubmissionDetailModel {
  final AssignmentWithSubmissions assignment;

  const SubmissionDetailModel({
    required this.assignment,
  });

  factory SubmissionDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final assignmentData = data['assignment'] as Map<String, dynamic>;
    return SubmissionDetailModel(
      assignment: AssignmentWithSubmissions.fromJson(assignmentData),
    );
  }

  // For backward compatibility, provide access to submissions
  List<AssignmentSubmissionModel> get submissionsByAssignment {
    return assignment.submissions.map((submission) {
      return AssignmentSubmissionModel(
        submission: submission_model.SubmissionModel(
          id: submission.id,
          assignmentId: submission.assignmentId,
          studentId: submission.studentId,
          fileUrl: submission.fileUrl,
          plagiarismScore: submission.plagiarismScore?.isNotEmpty == true ? double.tryParse(submission.plagiarismScore!) : null,
          aiGenerated: submission.aiGenerated == true ? 1.0 : 0.0,
          teacherComments: submission.teacherComments,
          grade: submission.grade?.isNotEmpty == true ? double.tryParse(submission.grade!) : null,
        ),
        student: StudentEntity(
          id: submission.student.id,
          name: submission.student.name,
          email: submission.student.email,
          profilePicture: submission.student.profilePicture,
          roll: submission.student.roll,
          section: submission.student.section,
        ),
        assignment: AssignmentEntity(
          id: assignment.id,
          title: assignment.title,
          description: assignment.description,
          deadline: assignment.deadline,
          createdAt: assignment.createdAt,
          submissionCount: assignment.submissionCount,
        ),
      );
    }).toList();
  }
}
