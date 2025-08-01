import 'package:dio/dio.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/config/app_config.dart';
import 'package:classmate/models/home/home_page_model.dart';

class HomeService {
  final DioClient _dioClient = DioClient();

  Future<HomePageModel?> getHomePageData() async {
    try {
      const String query = '''
        query HomePageData {
          # Get current authenticated user information
          user {
            id
            name
            email
            profile_picture
            role
          }
          
          # Get all enrollments with course details
          enrollments {
            id
            status
            enrolled_at
            courses {
              id
              title
              course_code
              description
              image
              credit
              teacher {
                id
                user_id {
                  name
                  profile_picture
                }
              }
              
              # Get assignments for each course
              assignments {
                id
                title
                description
                deadline
                created_at
              }
              
              # Get class tests for each course
              classTests {
                id
                title
                description
                date
                duration
                total_marks
              }
            }
          }
        }
      ''';

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          return HomePageModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching home page data: $e');
      return null;
    }
  }

  Future<HomePageModel?> getTodaysEnrolledCourses(String day) async {
    try {
      const String query = '''
        query TodaysEnrolledCourses(\$day: String!) {
          # User Information
          user {
            id
            name
            email
            profile_picture
            role
          }
          
          # Get enrollments filtered by day (server-side filtering)
          enrollmentsByDay(day: \$day) {
            id
            status
            enrolled_at
            courses {
              id
              title
              course_code
              description
              image
              credit
              
              # Teacher Information
              teacher {
                id
                user_id {
                  id
                  name
                  email
                  profile_picture
                }
              }
              
              # Get schedules for today only
              schedules {
                id
                day
                start_time
                end_time
                room_number
                section
              }
            }
          }
        }
      ''';

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
          'variables': {
            'day': day,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          // Map enrollmentsByDay to enrollments for compatibility
          final mappedData = {
            'user': data['user'],
            'enrollments': data['enrollmentsByDay'] ?? [],
          };
          return HomePageModel.fromJson(mappedData);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching today\'s enrolled courses: $e');
      return null;
    }
  }

  Future<HomePageModel?> getStudentAllAssignments() async {
    try {
      const String query = '''
        query StudentAllAssignments {
          enrollments {
            id
            status
            enrolled_at
            courses {
              id
              title
              course_code
              
              # Teacher Information
              teacher {
                id
                user_id {
                  id
                  name
                  email
                  profile_picture
                }
              }
              
              # All assignments from this course
              assignments {
                id
                title
                description
                deadline
                created_at
              }
            }
          }
        }
      ''';

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          return HomePageModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching student assignments: $e');
      return null;
    }
  }

  Future<HomePageModel?> getStudentAllClassTests() async {
    try {
      const String query = '''
        query StudentAllClassTests {
          enrollments {
            id
            status
            enrolled_at
            courses {
              id
              title
              course_code
              
              # Teacher Information
              teacher {
                id
                user_id {
                  id
                  name
                  email
                  profile_picture
                }
              }
              
              # All class tests from this course
              classTests {
                id
                title
                description
                date
                duration
                total_marks
                created_at
              }
            }
          }
        }
      ''';

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          return HomePageModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching student class tests: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentClassForStudent(String day, String currentTime) async {
    try {
      const String query = '''
        query CurrentClassForStudent(\$day: String!, \$current_time: String!) {
          currentClassForStudent(day: \$day, current_time: \$current_time) {
            id
            status
            enrolled_at
            courses {
              id
              title
              course_code
              description
              teacher {
                id
                user_id {
                  name
                  email
                  profile_picture
                }
              }
            }
          }
        }
      ''';

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
          'variables': {
            'day': day,
            'current_time': currentTime,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null && data['currentClassForStudent'] != null) {
          return data['currentClassForStudent'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching current class for student: $e');
      return null;
    }
  }
}