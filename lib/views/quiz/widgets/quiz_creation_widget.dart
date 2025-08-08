import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmate/models/quiz/question_generator_model.dart';
import 'package:classmate/models/home_teacher/teacher_dashboard_model.dart';

class QuizCreationWidget extends StatefulWidget {
  final List<CourseModel> courses;
  final QuestionGeneratorModel generatedQuestions;
  final Function(String, String, int?, int?) onCreateQuiz;

  const QuizCreationWidget({
    super.key,
    required this.courses,
    required this.generatedQuestions,
    required this.onCreateQuiz,
  });

  @override
  State<QuizCreationWidget> createState() => _QuizCreationWidgetState();
}

class _QuizCreationWidgetState extends State<QuizCreationWidget> {
  final _formKey = GlobalKey<FormState>();
  final _testTitleController = TextEditingController();
  final _durationController = TextEditingController();
  final _totalMarksController = TextEditingController();
  
  String? _selectedCourseId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testTitleController.text = widget.generatedQuestions.testTitle;
    _durationController.text = '60'; // Default 60 minutes
    _totalMarksController.text = widget.generatedQuestions.questions.length.toString();
  }

  @override
  void dispose() {
    _testTitleController.dispose();
    _durationController.dispose();
    _totalMarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.quiz,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Quiz',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Configure quiz settings and select course',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Course Selection
            _buildCourseSelection(),
            
            const SizedBox(height: 20),
            
            // Quiz Settings
            _buildQuizSettings(),
            
            const SizedBox(height: 24),
            
            // Create Button
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Course',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCourseId,
          decoration: InputDecoration(
            hintText: 'Choose a course for this quiz',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a course';
            }
            return null;
          },
          items: widget.courses.map((course) {
            return DropdownMenuItem<String>(
              value: course.id,
              child: Text(
                '${course.title} (${course.courseCode})',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCourseId = value;
            });
          },
        ),
        
        if (widget.courses.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No courses available. Create a course first to make quizzes.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuizSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Settings',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quiz Title
          TextFormField(
            controller: _testTitleController,
            decoration: InputDecoration(
              labelText: 'Quiz Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Quiz title is required';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Duration and Total Marks
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration (minutes)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Duration is required';
                    }
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return 'Enter valid duration';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _totalMarksController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total Marks',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Total marks is required';
                    }
                    final marks = int.tryParse(value);
                    if (marks == null || marks <= 0) {
                      return 'Enter valid marks';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quiz Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.generatedQuestions.questions.length} questions will be added to this quiz',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    final isEnabled = widget.courses.isNotEmpty && !_isLoading;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? _handleCreateQuiz : null,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.add_circle, size: 20),
        label: Text(
          _isLoading ? 'Creating Quiz...' : 'Create Quiz',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _handleCreateQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final duration = int.tryParse(_durationController.text.trim());
      final totalMarks = int.tryParse(_totalMarksController.text.trim());

      widget.onCreateQuiz(
        _selectedCourseId!,
        _testTitleController.text.trim(),
        duration,
        totalMarks,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
