import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CourseInfoPage extends StatefulWidget {
  final Function(String) onTitleChanged;
  final Function(String) onCourseCodeChanged;
  final Function(double) onCreditChanged;
  final Function(String) onExcerptChanged;
  final Function(String) onDescriptionChanged;
  final Function(String) onImageChanged;

  const CourseInfoPage({
    super.key,
    required this.onTitleChanged,
    required this.onCourseCodeChanged,
    required this.onCreditChanged,
    required this.onExcerptChanged,
    required this.onDescriptionChanged,
    required this.onImageChanged,
  });

  @override
  State<CourseInfoPage> createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
      widget.onImageChanged(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ListView(
            children: [
              Text(
                'Create a Course ✨',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 30),
              _buildGlassCard(child: _buildTextField(hint: 'Course Title', onChanged: widget.onTitleChanged)),
              const SizedBox(height: 20),
              _buildGlassCard(child: _buildTextField(hint: 'Course Code', onChanged: widget.onCourseCodeChanged)),
              const SizedBox(height: 20),
              _buildGlassCard(
                child: _buildTextField(
                  hint: 'Credit',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => widget.onCreditChanged(double.tryParse(value) ?? 0.0),
                ),
              ),
              const SizedBox(height: 20),
              _buildGlassCard(child: _buildTextField(hint: 'Excerpt (optional)', onChanged: widget.onExcerptChanged)),
              const SizedBox(height: 20),
              _buildGlassCard(
                child: _buildTextField(
                  hint: 'Course Description (optional)',
                  maxLines: 4,
                  onChanged: widget.onDescriptionChanged,
                ),
              ),
              const SizedBox(height: 30),
              Text('Upload Course Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.7))),
              const SizedBox(height: 12),
              GestureDetector(onTap: _pickImage, child: _buildImageUploadBox()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField({
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return TextField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.8)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildImageUploadBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: _selectedImagePath == null
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.black54),
              SizedBox(height: 10),
              Text('Tap to upload', style: TextStyle(color: Colors.black54)),
            ],
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            File(_selectedImagePath!),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
