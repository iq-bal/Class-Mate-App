import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';
import 'package:classmate/services/course_detail_teacher/enrollment_service.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/config/app_config.dart';

class AttendanceService {
  final EnrollmentService _enrollmentService = EnrollmentService();
  
  // Get approved students for a course
  Future<List<EnrollmentModel>> getApprovedStudents(String courseId) async {
    try {
      final enrollments = await _enrollmentService.getCourseEnrollments(courseId);
      // Filter only approved students
      return enrollments.where((enrollment) => enrollment.status == 'approved').toList();
    } catch (e) {
      throw Exception('Failed to fetch approved students: $e');
    }
  }
  
  final DioClient _dioClient = DioClient();

  // Start attendance session
  Future<String> startAttendanceSession(String sessionId) async {
    final String startSessionMutation = '''
      mutation {
        startAttendanceSession(session_id: "$sessionId") {
          success
          message
          session {
            _id
            topic
            date
          }
          totalStudents
        }
      }
    ''';
    
    try {
      final response = await _dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {
          'query': startSessionMutation,
        },
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['errors'] != null) {
        throw Exception('GraphQL Error: ${data['errors']}');
      }
      
      final sessionResponse = data['data']?['startAttendanceSession'];
      if (sessionResponse == null) {
        throw Exception('No session response returned');
      }
      
      if (sessionResponse['success'] != true) {
        throw Exception('Failed to start session: ${sessionResponse['message']}');
      }
      
      final sessionData = sessionResponse['session'];
      if (sessionData == null) {
        throw Exception('No session data returned');
      }
      
      return sessionData['_id'] as String;
    } catch (e) {
      throw Exception('Failed to start attendance session: $e');
    }
  }
  
  // End attendance session
  Future<void> endAttendanceSession(String sessionId) async {
    final String endSessionMutation = '''
      mutation {
        endAttendanceSession(sessionId: "$sessionId") {
          id
          endTime
          isActive
        }
      }
    ''';
    
    try {
      final response = await _dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {
          'query': endSessionMutation,
        },
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['errors'] != null) {
        throw Exception('GraphQL Error: ${data['errors']}');
      }
    } catch (e) {
      throw Exception('Failed to end attendance session: $e');
    }
  }
  
  // Mark attendance for a student
  Future<void> markAttendance(String sessionId, String studentId, String status, {String? remarks}) async {
    final String markAttendanceMutation = '''
      mutation {
        markAttendance(sessionId: "$sessionId", studentId: "$studentId", status: "${status.toUpperCase()}", remarks: "${remarks ?? ''}") {
          id
          sessionId
          studentId
          status
          remarks
          createdAt
        }
      }
    ''';
    
    try {
      final response = await _dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {
          'query': markAttendanceMutation,
        },
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['errors'] != null) {
        throw Exception('GraphQL Error: ${data['errors']}');
      }
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }
  
  // Get attendance records for a session
  Future<List<Map<String, dynamic>>> getSessionAttendance(String sessionId) async {
    final String getAttendanceQuery = '''
      query {
        attendanceRecords(sessionId: "$sessionId") {
          id
          sessionId
          studentId
          status
          remarks
          createdAt
          student {
            id
            name
            email
            roll
            section
            profilePicture
          }
        }
      }
    ''';
    
    try {
      final DioClient dioClient = DioClient();
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      
      final response = await dio.post(
        '/',
        data: {
          'query': getAttendanceQuery,
        },
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['errors'] != null) {
        throw Exception('GraphQL Error: ${data['errors']}');
      }
      
      final attendanceData = data['data']?['attendanceRecords'] as List<dynamic>?;
      if (attendanceData == null) {
        return [];
      }
      
      return attendanceData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch session attendance: $e');
    }
  }
  
  // Get attendance sessions for a course
  Future<List<Map<String, dynamic>>> getCourseAttendanceSessions(String courseId) async {
    final String getSessionsQuery = '''
      query {
        attendanceSessions(courseId: "$courseId") {
          id
          courseId
          startTime
          endTime
          isActive
          attendanceCount
        }
      }
    ''';
    
    try {
      final DioClient dioClient = DioClient();
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      
      final response = await dio.post(
        '/',
        data: {
          'query': getSessionsQuery,
        },
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['errors'] != null) {
        throw Exception('GraphQL Error: ${data['errors']}');
      }
      
      final sessionsData = data['data']?['attendanceSessions'] as List<dynamic>?;
      if (sessionsData == null) {
        return [];
      }
      
      return sessionsData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch course attendance sessions: $e');
    }
  }
}