import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmate/models/home_teacher/teacher_dashboard_model.dart';

class UpdateCourseDialog extends StatefulWidget {
  final CourseModel course;
  final Function(Map<String, dynamic>) onUpdate;

  const UpdateCourseDialog({
    super.key,
    required this.course,
    required this.onUpdate,
  });

  @override
  State<UpdateCourseDialog> createState() => _UpdateCourseDialogState();
}

class _UpdateCourseDialogState extends State<UpdateCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _excerptController = TextEditingController();
  final _creditController = TextEditingController();
  
  // Syllabus controllers
  final Map<String, List<TextEditingController>> _syllabusControllers = {};
  final Map<String, String> _syllabus = {};
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.course.title;
    _courseCodeController.text = widget.course.courseCode;
    _descriptionController.text = widget.course.description;
    _excerptController.text = widget.course.excerpt;
    _creditController.text = widget.course.credit.toString();
    
    // Initialize syllabus with default structure
    _initializeSyllabus();
  }

  void _initializeSyllabus() {
    final chapters = ['Intro', 'Chapter 1', 'Chapter 2'];
    for (String chapter in chapters) {
      _syllabusControllers[chapter] = [
        TextEditingController(text: 'Topic 1'),
        TextEditingController(text: 'Topic 2'),
      ];
      _syllabus[chapter] = 'Topic 1,Topic 2';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseCodeController.dispose();
    _descriptionController.dispose();
    _excerptController.dispose();
    _creditController.dispose();
    
    // Dispose syllabus controllers
    for (var controllers in _syllabusControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addSyllabusItem(String chapter) {
    setState(() {
      _syllabusControllers[chapter]?.add(TextEditingController());
    });
  }

  void _removeSyllabusItem(String chapter, int index) {
    setState(() {
      if (_syllabusControllers[chapter]!.length > 1) {
        _syllabusControllers[chapter]![index].dispose();
        _syllabusControllers[chapter]!.removeAt(index);
      }
    });
  }

  Map<String, List<String>> _buildSyllabusMap() {
    final syllabusMap = <String, List<String>>{};
    for (var entry in _syllabusControllers.entries) {
      syllabusMap[entry.key] = entry.value
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
    }
    return syllabusMap;
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updateData = {
        'title': _titleController.text.trim(),
        'courseCode': _courseCodeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'excerpt': _excerptController.text.trim(),
        'credit': int.parse(_creditController.text.trim()),
        'syllabus': _buildSyllabusMap(),
      };

      await widget.onUpdate(updateData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Update Course',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      _buildTextField(
                        controller: _titleController,
                        label: 'Course Title',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Course title is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Course Code
                      _buildTextField(
                        controller: _courseCodeController,
                        label: 'Course Code',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Course code is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Credits
                      _buildTextField(
                        controller: _creditController,
                        label: 'Credits',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Credits is required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Credits must be a number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Excerpt
                      _buildTextField(
                        controller: _excerptController,
                        label: 'Course Excerpt',
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Course excerpt is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Course Description',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Course description is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Syllabus Section
                      Text(
                        'Course Syllabus',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Syllabus chapters
                      ..._syllabusControllers.entries.map((entry) {
                        return _buildSyllabusSection(entry.key, entry.value);
                      }).toList(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Update Course',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade600),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSyllabusSection(String chapter, List<TextEditingController> controllers) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                chapter,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () => _addSyllabusItem(chapter),
                icon: Icon(Icons.add, color: Colors.blue.shade600),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...controllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Enter topic',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  if (controllers.length > 1)
                    IconButton(
                      onPressed: () => _removeSyllabusItem(chapter, index),
                      icon: Icon(Icons.remove_circle, color: Colors.red.shade400),
                      iconSize: 20,
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

Future<void> showUpdateCourseDialog({
  required BuildContext context,
  required CourseModel course,
  required Function(Map<String, dynamic>) onUpdate,
}) {
  return showDialog(
    context: context,
    builder: (context) => UpdateCourseDialog(
      course: course,
      onUpdate: onUpdate,
    ),
  );
}
