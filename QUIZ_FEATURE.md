# Quiz Generator Feature

## Overview

The Quiz Generator feature allows teachers to create quizzes by uploading PDF documents and using AI to generate multiple-choice questions. Teachers can then create quizzes for specific courses with automatically generated questions.

## Features

### 🤖 AI-Powered Question Generation
- Upload PDF documents to extract content
- Generate multiple-choice questions using Google's Gemini AI
- Customizable question count (1-20 questions)
- Difficulty levels: Easy, Medium, Hard
- Custom quiz titles

### 📚 Course Integration
- Select from teacher's created courses
- Automatic student notification when quiz is created
- Integration with existing course management system

### 🎯 Quiz Creation
- Configure quiz duration (in minutes)
- Set total marks for the quiz
- Preview generated questions before creating
- Real-time validation and error handling

## Prerequisites

### Question Generator Service
The feature requires a separate Question Generator service to be running:

1. **Service URL**: `http://localhost:8001`
2. **Health Check**: The app automatically checks if the service is available
3. **Service Setup**: Follow the instructions in `question-generator.md` to set up the service

### Dependencies
- `file_picker`: For PDF file selection
- `dio`: For HTTP requests to the question generator service
- Standard Flutter dependencies for UI

## Architecture

### Models
- `QuestionGeneratorModel`: Handles AI-generated questions
- `QuizCreationRequest`: Manages quiz creation data
- `QuizQuestionInput`: Input format for GraphQL mutations

### Services
- `QuestionGeneratorService`: Communicates with the AI service
- `QuizService`: Handles GraphQL operations for quiz management
- `TeacherDashboardService`: Fetches teacher's courses

### Controllers
- `QuizController`: Main business logic controller
- Manages state transitions and data flow
- Handles error states and user interactions

### Views
- `QuizView`: Main quiz generator interface
- `ChatbotWidget`: AI assistant UI for PDF upload and settings
- `GeneratedQuestionsWidget`: Preview of generated questions
- `QuizCreationWidget`: Course selection and quiz configuration

## Usage Flow

### 1. Access Quiz Generator
- Teachers access the Quiz tab from the bottom navigation
- Service health status is displayed at the top

### 2. Upload PDF and Generate Questions
- Click "Select PDF" to choose a PDF file
- Configure question settings:
  - Number of questions (1-20)
  - Difficulty level (Easy/Medium/Hard)
  - Custom quiz title
- Click "Generate Questions" to create questions using AI

### 3. Review Generated Questions
- Preview all generated questions with correct answers highlighted
- Questions show multiple-choice options (A, B, C, D)
- Option to regenerate questions if needed

### 4. Create Quiz
- Select target course from dropdown
- Configure quiz settings:
  - Quiz title (pre-filled from generation)
  - Duration in minutes
  - Total marks
- Click "Create Quiz" to save to the system

### 5. Success Confirmation
- Success screen confirms quiz creation
- Students are automatically notified
- Option to create another quiz

## Technical Implementation

### GraphQL Integration
Uses the quiz system GraphQL mutations as documented in `quiz_docs.md`:

```graphql
mutation CreateQuiz($input: CreateQuizInput!) {
  createQuiz(input: $input) {
    id
    testTitle
    questions {
      id
      question
      options { A B C D }
      answer
    }
    duration
    total_marks
    is_active
    created_at
  }
}
```

### Question Generator API
Communicates with the external question generator service:

```http
POST /generate-questions-public
Content-Type: multipart/form-data

- file: PDF file
- num_questions: Number of questions
- difficulty: Difficulty level
- test_title: Quiz title
```

### State Management
Uses `ValueNotifier` for reactive state management:

```dart
enum QuizState {
  initial,           // Starting state
  loading,           // Generating questions or creating quiz
  questionsGenerated,// Questions ready for review
  quizCreated,       // Quiz successfully created
  error,             // Error occurred
}
```

## Error Handling

### Service Offline
- Real-time health check monitoring
- Clear error messages when service is unavailable
- Instructions for starting the service

### PDF Processing Errors
- File type validation (PDF only)
- Content extraction error handling
- User-friendly error messages

### Quiz Creation Errors
- Course selection validation
- Form validation for all required fields
- GraphQL error handling and display

## Navigation Integration

The Quiz feature is integrated into the teacher navigation:

```dart
// Added to main_layout.dart for teachers
_navItems = [
  BottomNavItem(icon: Icons.dashboard, label: 'Dashboard'),
  BottomNavItem(icon: Icons.folder, label: 'Drive'),
  BottomNavItem(icon: Icons.quiz, label: 'Quiz'),        // New
  BottomNavItem(icon: Icons.person, label: 'Profile'),
];
```

## File Structure

```
lib/
├── controllers/quiz/
│   └── quiz_controller.dart
├── models/quiz/
│   └── question_generator_model.dart
├── services/quiz/
│   ├── question_generator_service.dart
│   └── quiz_service.dart
└── views/quiz/
    ├── quiz_view.dart
    └── widgets/
        ├── chatbot_widget.dart
        ├── generated_questions_widget.dart
        └── quiz_creation_widget.dart
```

## Future Enhancements

### Planned Features
- Question editing before quiz creation
- Multiple PDF upload support
- Custom question templates
- Quiz analytics and performance tracking
- Bulk quiz operations

### Possible Integrations
- Integration with existing assignment system
- Student quiz attempt tracking
- Grade book integration
- Advanced AI customization options

## Troubleshooting

### Common Issues

1. **Service Health Check Fails**
   - Ensure question generator service is running on localhost:8001
   - Check service logs for startup errors
   - Verify network connectivity

2. **PDF Upload Issues**
   - Verify PDF contains readable text content
   - Check file size limitations
   - Ensure proper file permissions

3. **No Courses Available**
   - Teacher must create courses first
   - Check course creation permissions
   - Verify teacher dashboard data loading

4. **Quiz Creation Fails**
   - Validate all form fields
   - Check GraphQL service connectivity
   - Verify teacher has course creation permissions

### Debug Mode
Enable debug mode in the controller to see detailed logs:

```dart
if (kDebugMode) {
  print('Debug information...');
}
```

## Testing

### Manual Testing Checklist
- [ ] Service health check displays correctly
- [ ] PDF file picker works on all platforms
- [ ] Question generation with various settings
- [ ] Question preview displays properly
- [ ] Course selection shows all teacher courses
- [ ] Quiz creation form validation
- [ ] Success/error state handling
- [ ] Navigation between states

### Test Data
Use the sample PDF files and test courses for consistent testing results.

---

This Quiz Generator feature provides a comprehensive solution for teachers to create engaging quizzes using AI-powered question generation, seamlessly integrated with the existing course management system.
