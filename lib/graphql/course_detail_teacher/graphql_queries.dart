class GraphQLQueries {
  static const String getCourseDetails = '''
    query GetCourseDetails(\$courseId: String!) {
      course(id: \$courseId) {
        title
        enrolled_students {
          uid
          email
          name
          role
        }
        assignments {
          id
          title
          description
          deadline
          created_at
        }
      }
    }
  ''';
}