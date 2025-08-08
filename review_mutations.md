# Course Review System Documentation

## Overview

The Course Review System allows students to provide feedback on courses they are enrolled in. To ensure quality reviews, only students with an **approved** enrollment status in a course can submit reviews for that course.

## Features

- Students can create, update, and delete their own reviews
- Reviews include a rating (number) and a comment (text)
- Each student can only submit one review per course
- Only students with approved enrollment status can submit reviews
- Reviews are associated with both the course and the student who created them

## GraphQL Schema

### Types

```graphql
type Review {
  id: ID!
  course_id: Course!
  student_id: Student!
  rating: Int!
  comment: String
  commented_by: User
  createdAt: String
  updatedAt: String
}

input ReviewInput {
  course_id: ID!
  rating: Int!
  comment: String
}
```

### Queries

```graphql
type Query {
  reviews: [Review!]!
  reviewsByCourse(course_id: ID!): [Review!]!
  reviewsByStudent(student_id: ID!): [Review!]!
}
```

### Mutations

```graphql
type Mutation {
  createReview(reviewInput: ReviewInput!): Review!
  updateReview(id: ID!, reviewInput: ReviewInput!): Review!
  deleteReview(id: ID!): Boolean!
}
```

## Authentication & Authorization

- All review operations require user authentication
- Only students can create, update, or delete reviews
- Students can only update or delete their own reviews
- Students must have an approved enrollment status in a course to review it

## Business Rules

1. A student can only submit one review per course
2. Students must have an approved enrollment status to submit a review
3. Rating is required and must be a number
4. Comment is optional
5. Students can only modify or delete their own reviews

## Example Usage

### Creating a Review

```graphql
mutation {
  createReview(reviewInput: {
    course_id: "60d21b4667d0d01ce8341e21",
    rating: 5,
    comment: "Excellent course! The instructor was very knowledgeable."
  }) {
    id
    rating
    comment
    course_id {
      id
      title
    }
    student_id {
      id
    }
    commented_by {
      name
    }
  }
}
```

### Updating a Review

```graphql
mutation {
  updateReview(
    id: "60d21b4667d0d01ce8341e22",
    reviewInput: {
      course_id: "60d21b4667d0d01ce8341e21",
      rating: 4,
      comment: "Updated: Good course with some areas for improvement."
    }
  ) {
    id
    rating
    comment
  }
}
```

### Deleting a Review

```graphql
mutation {
  deleteReview(id: "60d21b4667d0d01ce8341e22")
}
```

## Implementation Details

### Review Creation Process

1. User authentication is verified
2. User's student record is retrieved
3. Student's enrollment status for the course is checked
4. If enrollment status is 'approved', the review is created
5. Duplicate reviews (same student, same course) are prevented

### Error Handling

The system provides specific error messages for different scenarios:

- Authentication errors: "Authentication required"
- Authorization errors: "Only students can create reviews"
- Enrollment errors: "You must be enrolled in this course with approved status to review it"
- Duplicate review errors: "You have already reviewed this course"
- Not found errors: "Review not found or you are not authorized to update/delete it"

### Fallback Handling

To ensure the system remains robust even when data is incomplete:

- If a student's user data cannot be found, a default "Unknown User" is provided
- Non-nullable fields like `name` always have fallback values
- The system gracefully handles missing or incomplete user data without throwing errors

## Testing

A test script is provided at `/test_review_enrollment_check.js` to verify the review creation functionality with enrollment status check. The script sets up a test server and provides instructions for testing the review creation mutation.

An example mutation file is also available at `/review_mutation_example.graphql` which demonstrates how to create a review with variables.