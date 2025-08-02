import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmate/models/profile_student/profile_student_model.dart';
import 'package:classmate/controllers/profile_student/profile_student_controller.dart';

class EditProfileDialog extends StatefulWidget {
  final ProfileStudentModel profile;
  final ProfileStudentController controller;

  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.controller,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _rollController;
  late TextEditingController _sectionController;
  late TextEditingController _departmentController;
  late TextEditingController _semesterController;
  late TextEditingController _cgpaController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rollController = TextEditingController(text: widget.profile.roll);
    _sectionController = TextEditingController(text: widget.profile.section);
    _departmentController = TextEditingController(text: widget.profile.department);
    _semesterController = TextEditingController(text: widget.profile.semester);
    _cgpaController = TextEditingController(text: widget.profile.cgpa);
  }

  @override
  void dispose() {
    _rollController.dispose();
    _sectionController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.controller.updateStudentInfo(
        roll: _rollController.text.trim(),
        section: _sectionController.text.trim(),
        department: _departmentController.text.trim(),
        semester: _semesterController.text.trim(),
        cgpa: _cgpaController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $error'),
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form Fields
            _buildTextField(
              controller: _rollController,
              label: 'Roll Number',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _sectionController,
              label: 'Section',
              icon: Icons.class_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _departmentController,
              label: 'Department',
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _semesterController,
              label: 'Semester',
              icon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _cgpaController,
              label: 'CGPA',
              icon: Icons.grade_outlined,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
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
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: GoogleFonts.inter(
          color: Colors.grey.shade700,
        ),
      ),
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
      ),
    );
  }
}