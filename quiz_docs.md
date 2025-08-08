# Quiz System Documentation

This document provides comprehensive information about the quiz system implementation, including GraphQL queries, mutations, and usage examples.

## Overview

The quiz system allows teachers to create quizzes for their courses. When a quiz is created, all enrolled students with "approved" status receive notifications. The system supports multiple-choice questions with four options (A, B, C, D).

## Features

- ✅ Teachers can create quizzes for courses they teach
- ✅ Multiple-choice questions with 4 options (A, B, C, D)
- ✅ Automatic notification to enrolled students
- ✅ Quiz status management (active/inactive)
- ✅ Authorization and authentication
- ✅ CRUD operations for quizzes
- ✅ Students can submit quiz answers and get scored automatically
- ✅ Quiz submission tracking with scores and percentages
- ✅ Multiple attempt support with attempt numbering
- ✅ Time tracking for quiz submissions
- ✅ Comprehensive quiz submission queries for teachers and students

## GraphQL Schema

### Types

```graphql
type QuizOption {
  A: String!
  B: String!
  C: String!
  D: String!
}

type QuizQuestion {
  id: Int!
  question: String!
  options: QuizOption!
  answer: String!
}

type Quiz {
  id: ID!
  course_id: ID!
  teacher_id: ID!
  testTitle: String!
  questions: [QuizQuestion!]!
  duration: Int!
  total_marks: Int!
  is_active: Boolean!
  created_at: String!
  updated_at: String!
  course: Course
  teacher: Teacher
}

type QuizAnswer {
  question_id: Int!
  selected_answer: String!
  is_correct: Boolean!
}

type QuizSubmission {
  id: ID!
  quiz_id: ID!
  student_id: ID!
  answers: [QuizAnswer!]!
  score: Int!
  total_marks: Int!
  percentage: Float!
  time_taken: Int!
  submitted_at: String!
  attempt_number: Int!
  quiz: Quiz
  student: Student
}
```

### Input Types

```graphql
input QuizOptionInput {
  A: String!
  B: String!
  C: String!
  D: String!
}

input QuizQuestionInput {
  id: Int!
  question: String!
  options: QuizOptionInput!
  answer: String!
}

input CreateQuizInput {
  course_id: ID!
  testTitle: String!
  questions: [QuizQuestionInput!]!
  duration: Int
  total_marks: Int
}

input UpdateQuizInput {
  testTitle: String
  questions: [QuizQuestionInput!]
  duration: Int
  total_marks: Int
  is_active: Boolean
}

input QuizAnswerInput {
  question_id: Int!
  selected_answer: String!
}

input SubmitQuizInput {
  quiz_id: ID!
  answers: [QuizAnswerInput!]!
  time_taken: Int!
}
```

## Queries

### 1. Get All Quizzes (Teachers/Admins only)

```graphql
query GetAllQuizzes {
  quizzes {
    id
    testTitle
    duration
    total_marks
    is_active
    created_at
    course {
      id
      title
      course_code
    }
    teacher {
      id
      department
      user {
        id
        name
        email
        profile_picture
      }
    }
  }
}
```

### 2. Get Quiz by ID

```graphql
query GetQuiz($id: ID!) {
  quiz(id: $id) {
    id
    testTitle
    questions {
      id
      question
      options {
        A
        B
        C
        D
      }
      answer
    }
    duration
    total_marks
    is_active
    created_at
    course {
      id
      title
      course_code
    }
    teacher {
      id
      department
      user {
        id
        name
        email
        profile_picture
      }
    }
  }
}
```

**Variables:**
```json
{
  "id": "quiz_id_here"
}
```

### 3. Get Quizzes by Course

```graphql
query GetQuizzesByCourse($course_id: ID!) {
  quizzesByCourse(course_id: $course_id) {
    id
    testTitle
    duration
    total_marks
    is_active
    created_at
    questions {
      id
      question
      options {
        A
        B
        C
        D
      }
    }
  }
}
```

**Variables:**
```json
{
  "course_id": "course_id_here"
}
```

### 4. Get Active Quizzes by Course

```graphql
query GetActiveQuizzesByCourse($course_id: ID!) {
  activeQuizzesByCourse(course_id: $course_id) {
    id
    testTitle
    duration
    total_marks
    created_at
    questions {
      id
      question
      options {
        A
        B
        C
        D
      }
    }
  }
}
```


### 6. Get All Quiz Submissions (Teachers/Admins only)

```graphql
query GetAllQuizSubmissions {
  quizSubmissions {
    id
    score
    total_marks
    percentage
    time_taken
    submitted_at
    attempt_number
    quiz {
      id
      testTitle
      course {
        title
        course_code
      }
    }
    student {
      id
      user_id {
        name
        email
      }
    }
  }
}
```

### 7. Get Quiz Submissions by Quiz ID

```graphql
query GetQuizSubmissionsByQuiz($quiz_id: ID!) {
  quizSubmissionsByQuiz(quiz_id: $quiz_id) {
    id
    score
    total_marks
    percentage
    time_taken
    submitted_at
    attempt_number
    student {
      id
      user_id {
        name
        email
      }
    }
  }
}
```

### 8. Get Student's Quiz Submissions

```graphql
query GetMyQuizSubmissions {
  myQuizSubmissions {
    id
    score
    total_marks
    percentage
    time_taken
    submitted_at
    attempt_number
    quiz {
      id
      testTitle
      course {
        title
        course_code
      }
    }
  }
}
```



## Mutations

### 1. Create Quiz

```graphql
mutation CreateQuiz($input: CreateQuizInput!) {
  createQuiz(input: $input) {
    id
    testTitle
    questions {
      id
      question
      options {
        A
        B
        C
        D
      }
      answer
    }
    duration
    total_marks
    is_active
    created_at
    course {
      id
      title
      course_code
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "course_id": "64a1b2c3d4e5f6789012345",
    "testTitle": "Sample Test",
    "duration": 60,
    "questions": [
      {
        "id": 1,
        "question": "What is the capital of France?",
        "options": {
          "A": "Berlin",
          "B": "Madrid",
          "C": "Paris",
          "D": "Rome"
        },
        "answer": "C"
      },
      {
        "id": 2,
        "question": "Which planet is known as the Red Planet?",
        "options": {
          "A": "Earth",
          "B": "Mars",
          "C": "Jupiter",
          "D": "Saturn"
        },
        "answer": "B"
      },
      {
        "id": 3,
        "question": "Who wrote 'Hamlet'?",
        "options": {
          "A": "Charles Dickens",
          "B": "William Shakespeare",
          "C": "Mark Twain",
          "D": "Leo Tolstoy"
        },
        "answer": "B"
      }
    ]
  }
}
```

### 2. Update Quiz

```graphql
mutation UpdateQuiz($id: ID!, $input: UpdateQuizInput!) {
  updateQuiz(id: $id, input: $input) {
    id
    testTitle
    questions {
      id
      question
      options {
        A
        B
        C
        D
      }
      answer
    }
    duration
    total_marks
    is_active
    updated_at
  }
}
```

**Variables:**
```json
{
  "id": "quiz_id_here",
  "input": {
    "testTitle": "Updated Test Title",
    "duration": 90,
    "is_active": true
  }
}
```

### 3. Delete Quiz

```graphql
mutation DeleteQuiz($id: ID!) {
  deleteQuiz(id: $id)
}
```

**Variables:**
```json
{
  "id": "quiz_id_here"
}
```

### 4. Toggle Quiz Status

```graphql
mutation ToggleQuizStatus($id: ID!) {
  toggleQuizStatus(id: $id) {
    id
    testTitle
    is_active
    updated_at
  }
}
```

**Variables:**
```json
{
  "id": "quiz_id_here"
}
```

### 5. Submit Quiz

```graphql
mutation SubmitQuiz($input: SubmitQuizInput!) {
  submitQuiz(input: $input) {
    id
    answers {
      question_id
      selected_answer
      is_correct
    }
    score
    total_marks
    percentage
    time_taken
    submitted_at
    attempt_number
    quiz {
      id
      testTitle
      course {
        title
        course_code
      }
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "quiz_id": "quiz_id_here",
    "answers": [
      {
        "question_id": 1,
        "selected_answer": "A"
      },
      {
        "question_id": 2,
        "selected_answer": "C"
      },
      {
        "question_id": 3,
        "selected_answer": "B"
      }
    ],
    "time_taken": 25
  }
}
```

## Authentication & Authorization

### Required Headers

All requests must include a valid JWT token:

```
Authorization: Bearer <your_jwt_token>
```

### Role-Based Access

- **Teachers**: Can create, update, delete, and view their own quizzes
- **Students**: Can view quizzes for courses they're enrolled in
- **Admins**: Can view all quizzes

### Permissions

| Operation | Teacher (Own Quiz) | Teacher (Other Quiz) | Student | Admin |
|-----------|-------------------|---------------------|---------|-------|
| Create Quiz | ✅ | ❌ | ❌ | ✅ |
| View Quiz | ✅ | ✅* | ✅* | ✅ |
| Update Quiz | ✅ | ❌ | ❌ | ✅ |
| Delete Quiz | ✅ | ❌ | ❌ | ✅ |
| Toggle Status | ✅ | ❌ | ❌ | ✅ |
| Submit Quiz | ❌ | ❌ | ✅** | ❌ |
| View All Submissions | ✅ | ✅ | ❌ | ✅ |
| View Own Submissions | ❌ | ❌ | ✅ | ✅ |
| View Quiz Submissions | ✅*** | ✅*** | ❌ | ✅ |

*Only for courses they teach/are enrolled in  
**Only for courses they are enrolled in with approved status  
***Only for quizzes in courses they teach

## Notification System

When a quiz is created, the system automatically:

1. Finds all students enrolled in the course with "approved" status
2. Creates bulk notifications for these students
3. Sends notifications with quiz details

### Notification Structure

```json
{
  "title": "New Quiz Available",
  "body": "A new quiz 'Sample Test' has been created for Course Title (COURSE001)",
  "type": "quiz_created",
  "related_entity_type": "quiz",
  "data": {
    "course_id": "course_id",
    "quiz_id": "quiz_id",
    "course_title": "Course Title",
    "course_code": "COURSE001",
    "quiz_title": "Sample Test",
    "duration": 60,
    "total_marks": 3
  }
}
```

## Error Handling

### Common Errors

1. **Authentication Required**
   ```json
   {
     "errors": [{
       "message": "Authentication required"
     }]
   }
   ```

2. **Insufficient Permissions**
   ```json
   {
     "errors": [{
       "message": "Only the course creator can create quizzes for this course"
     }]
   }
   ```

3. **Quiz Not Found**
   ```json
   {
     "errors": [{
       "message": "Quiz not found"
     }]
   }
   ```

4. **Invalid Course**
   ```json
   {
     "errors": [{
       "message": "Course not found"
     }]
   }
   ```

## Database Schema

### Quiz Collection

```javascript
{
  _id: ObjectId,
  course_id: ObjectId, // Reference to Course
  teacher_id: ObjectId, // Reference to Teacher
  testTitle: String,
  questions: [
    {
      id: Number,
      question: String,
      options: {
        A: String,
        B: String,
        C: String,
        D: String
      },
      answer: String // 'A', 'B', 'C', or 'D'
    }
  ],
  duration: Number, // in minutes
  total_marks: Number,
  is_active: Boolean,
  created_at: Date,
  updated_at: Date
}
```

### Quiz Submission Collection

```javascript
{
  _id: ObjectId,
  quiz_id: ObjectId, // Reference to Quiz
  student_id: ObjectId, // Reference to Student
  answers: [
    {
      question_id: Number,
      selected_answer: String, // 'A', 'B', 'C', or 'D'
      is_correct: Boolean
    }
  ],
  score: Number, // Number of correct answers
  total_marks: Number, // Total possible marks
  percentage: Number, // Calculated percentage (0-100)
  time_taken: Number, // Time taken in minutes
  submitted_at: Date,
  attempt_number: Number // Tracks multiple attempts
}
```

## Frontend Integration Examples

### React/Apollo Client

```javascript
import { gql, useMutation, useQuery } from '@apollo/client';

// Create Quiz Hook
const CREATE_QUIZ = gql`
  mutation CreateQuiz($input: CreateQuizInput!) {
    createQuiz(input: $input) {
      id
      testTitle
      is_active
      created_at
    }
  }
`;

function CreateQuizComponent() {
  const [createQuiz, { loading, error }] = useMutation(CREATE_QUIZ);
  
  const handleCreateQuiz = async (quizData) => {
    try {
      const { data } = await createQuiz({
        variables: { input: quizData }
      });
      console.log('Quiz created:', data.createQuiz);
    } catch (err) {
      console.error('Error creating quiz:', err);
    }
  };
  
  // Component JSX...
}

// Get Quizzes Hook
const GET_QUIZZES_BY_COURSE = gql`
  query GetQuizzesByCourse($course_id: ID!) {
    quizzesByCourse(course_id: $course_id) {
      id
      testTitle
      duration
      total_marks
      is_active
      created_at
    }
  }
`;

function QuizListComponent({ courseId }) {
  const { data, loading, error } = useQuery(GET_QUIZZES_BY_COURSE, {
    variables: { course_id: courseId }
  });
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  
  return (
    <div>
      {data.quizzesByCourse.map(quiz => (
        <div key={quiz.id}>
          <h3>{quiz.testTitle}</h3>
          <p>Duration: {quiz.duration} minutes</p>
          <p>Total Marks: {quiz.total_marks}</p>
          <p>Status: {quiz.is_active ? 'Active' : 'Inactive'}</p>
        </div>
      ))}
    </div>
  );
}
```

## Testing

### Sample Test Data

```json
{
  "course_id": "64a1b2c3d4e5f6789012345",
  "testTitle": "JavaScript Fundamentals Quiz",
  "duration": 45,
  "questions": [
    {
      "id": 1,
      "question": "What is the correct way to declare a variable in JavaScript?",
      "options": {
        "A": "var myVar;",
        "B": "variable myVar;",
        "C": "v myVar;",
        "D": "declare myVar;"
      },
      "answer": "A"
    },
    {
      "id": 2,
      "question": "Which method is used to add an element to the end of an array?",
      "options": {
        "A": "append()",
        "B": "push()",
        "C": "add()",
        "D": "insert()"
      },
      "answer": "B"
    }
  ]
}
```

## Best Practices

1. **Question IDs**: Use sequential numbers starting from 1
2. **Answer Validation**: Always ensure the answer field matches one of the option keys (A, B, C, D)
3. **Duration**: Set reasonable time limits (typically 1-2 minutes per question)
4. **Total Marks**: If not specified, defaults to the number of questions
5. **Error Handling**: Always handle potential errors in your frontend code
6. **Authentication**: Ensure JWT tokens are valid and not expired

## Troubleshooting

### Common Issues

1. **"Teacher ID not found in user context"**
   - Ensure the user is logged in as a teacher
   - Check JWT token validity

2. **"Only the course creator can create quizzes"**
   - Verify the teacher is the one who created the course
   - Check course ownership

3. **"Course not found"**
   - Verify the course_id exists in the database
   - Check if the course is still active

4. **Notification not sent**
   - Check if students are enrolled with "approved" status
   - Verify notification service is working

## Quiz Submission Usage Examples

### For Students

#### 1. Taking a Quiz
```javascript
// 1. First, get the quiz questions (without answers)
const GET_QUIZ_FOR_STUDENT = gql`
  query GetQuizForStudent($id: ID!) {
    quiz(id: $id) {
      id
      testTitle
      duration
      total_marks
      questions {
        id
        question
        options {
          A
          B
          C
          D
        }
      }
    }
  }
`;

// 2. Submit the quiz answers
const SUBMIT_QUIZ = gql`
  mutation SubmitQuiz($input: SubmitQuizInput!) {
    submitQuiz(input: $input) {
      id
      score
      total_marks
      percentage
      time_taken
      attempt_number
    }
  }
`;

// Usage in React component
const [submitQuiz] = useMutation(SUBMIT_QUIZ);

const handleSubmitQuiz = async (answers, timeTaken) => {
  try {
    const { data } = await submitQuiz({
      variables: {
        input: {
          quiz_id: quizId,
          answers: answers, // [{ question_id: 1, selected_answer: "A" }, ...]
          time_taken: timeTaken
        }
      }
    });
    
    console.log('Quiz submitted successfully:', data.submitQuiz);
    // Show results to student
  } catch (error) {
    console.error('Error submitting quiz:', error);
  }
};
```

#### 2. Viewing Quiz Results
```javascript
const GET_MY_SUBMISSIONS = gql`
  query GetMyQuizSubmissions {
    myQuizSubmissions {
      id
      score
      total_marks
      percentage
      time_taken
      submitted_at
      attempt_number
      quiz {
        testTitle
        course {
          title
        }
      }
    }
  }
`;
```

### For Teachers

#### 1. Viewing Quiz Submissions
```javascript
const GET_QUIZ_SUBMISSIONS = gql`
  query GetQuizSubmissions($quiz_id: ID!) {
    quizSubmissionsByQuiz(quiz_id: $quiz_id) {
      id
      score
      total_marks
      percentage
      time_taken
      submitted_at
      attempt_number
      student {
        user_id {
          name
          email
        }
      }
    }
  }
`;
```

#### 2. Viewing Detailed Student Answers
```javascript
const GET_STUDENT_SUBMISSION = gql`
  query GetStudentSubmission($quiz_id: ID!, $student_id: ID!) {
    studentQuizSubmission(quiz_id: $quiz_id, student_id: $student_id) {
      answers {
        question_id
        selected_answer
        is_correct
      }
      score
      percentage
      time_taken
    }
  }
`;
```

## Key Features Summary

### Automatic Scoring
- ✅ Answers are automatically checked against correct answers
- ✅ Score and percentage are calculated in real-time
- ✅ Individual question results are stored (correct/incorrect)

### Multiple Attempts
- ✅ Students can retake quizzes (if allowed by teacher)
- ✅ Each attempt is tracked with attempt numbers
- ✅ All attempts are preserved in the database

### Time Tracking
- ✅ Time taken for each submission is recorded
- ✅ Can be used for analytics and performance tracking

### Security & Validation
- ✅ Students can only submit to quizzes for courses they're enrolled in
- ✅ Only active quizzes accept submissions
- ✅ Answer validation ensures all questions are answered
- ✅ Role-based access control for viewing submissions

This documentation covers the complete quiz system implementation with scoring functionality. The system is now ready for use by teachers to create quizzes and students to take them with automatic scoring and result tracking.