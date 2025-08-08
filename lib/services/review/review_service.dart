import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';

class ReviewService {
  final dioClient = DioClient();

  /// Create a new review using GraphQL mutation
  Future<Map<String, dynamic>> createReview({
    required String courseId,
    required int rating,
    String? comment,
  }) async {
    const String mutation = '''
      mutation CreateReview(\$reviewInput: ReviewInput!) {
        createReview(reviewInput: \$reviewInput) {
          id
          course_id {
            id
            title
          }
          student_id {
            id
          }
          rating
          comment
          commented_by {
            name
          }
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      final requestData = {
        'query': mutation,
        'variables': {
          'reviewInput': {
            'course_id': courseId,
            'rating': rating,
            'comment': comment,
          },
        }
      };
      
      print('Sending GraphQL request: $requestData');
      
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['createReview'] != null) {
          return data['data']['createReview'];
        } else {
          throw Exception('Failed to create review');
        }
      } else {
        throw Exception('Failed to create review. Status code: \${response.statusCode}');
      }
    } catch (e) {
        print('Error creating review: $e');
      throw Exception('Error occurred while creating review: $e');
    }
  }

  /// Update an existing review using GraphQL mutation
  Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    required String courseId,
    required int rating,
    String? comment,
  }) async {
    const String mutation = '''
      mutation UpdateReview(\$id: ID!, \$reviewInput: ReviewInput!) {
        updateReview(id: \$id, reviewInput: \$reviewInput) {
          id
          course_id {
            id
            title
          }
          student_id {
            id
          }
          rating
          comment
          commented_by {
            name
          }
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      final requestData = {
        'query': mutation,
        'variables': {
          'id': reviewId,
          'reviewInput': {
            'course_id': courseId,
            'rating': rating,
            'comment': comment,
          },
        }
      };
      
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['updateReview'] != null) {
          return data['data']['updateReview'];
        } else {
          throw Exception('Failed to update review');
        }
      } else {
        throw Exception('Failed to update review. Status code: \${response.statusCode}');
      }
    } catch (e) {
        print('Error updating review: $e');
      throw Exception('Error occurred while updating review: $e');
    }
  }

  /// Delete a review using GraphQL mutation
  Future<bool> deleteReview(String reviewId) async {
    const String mutation = '''
      mutation DeleteReview(\$id: ID!) {
        deleteReview(id: \$id)
      }
    ''';

    try {
      final requestData = {
        'query': mutation,
        'variables': {
          'id': reviewId,
        }
      };
      
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['deleteReview'] != null) {
          return data['data']['deleteReview'];
        } else {
          throw Exception('Failed to delete review');
        }
      } else {
        throw Exception('Failed to delete review. Status code: \${response.statusCode}');
      }
    } catch (e) {
        print('Error deleting review: $e');
      throw Exception('Error occurred while deleting review: $e');
    }
  }
}