import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:classmate/controllers/profile_teacher/profile_teacher_controller.dart';
import 'package:classmate/views/profile_teacher/widgets/teacher_settings_page.dart';

class ProfileHeader extends StatelessWidget {
  final String coverPhotoUrl;
  final String profilePhotoUrl;
  final String name;
  final String title;

  final ProfileTeacherController profileTeacherController = ProfileTeacherController();

  ProfileHeader({
    super.key,
    required this.coverPhotoUrl,
    required this.profilePhotoUrl,
    required this.name,
    required this.title,
  });

  Future<void> _editProfilePhoto(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        File selectedImage = File(image.path);
        await profileTeacherController.updateProfilePicture(selectedImage);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile photo updated")));
      } catch (e) {
        print("Error updating profile photo: $e");
      }
    }
  }

  Future<void> _editCoverPhoto(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        File selectedImage = File(image.path);
        await profileTeacherController.updateCoverPhoto(selectedImage);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cover photo updated")));
      } catch (e) {
        print("Error updating cover photo: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // ensures overflow like avatar works
      children: [
        // Cover Photo
        Container(
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(coverPhotoUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 250,
          color: Colors.black.withOpacity(0.4),
        ),

        // Top Right: Cover Camera + Settings
        Positioned(
          top: 40,
          right: 20,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                onPressed: () => _editCoverPhoto(context),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherSettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),

        // Bottom: Avatar + Camera Icon at Bottom-Right
        Positioned(
          bottom: -60,
          left: 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => _editProfilePhoto(context),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: NetworkImage(profilePhotoUrl),
                  ),
                ),
              ),
              Positioned(
                bottom: 70,
                right: -5,
                child: GestureDetector(
                  onTap: () => _editProfilePhoto(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Name and Title
        Positioned(
          bottom: -60,
          left: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
