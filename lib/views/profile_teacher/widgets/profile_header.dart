import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileHeader extends StatelessWidget {
  final String coverPhotoUrl;
  final String profilePhotoUrl;
  final String name;
  final String title;

  /// NEW: callbacks into the page’s controller
  final Future<void> Function(File) onProfilePictureChange;
  final Future<void> Function(File) onCoverPhotoChange;

  const ProfileHeader({
    super.key,
    required this.coverPhotoUrl,
    required this.profilePhotoUrl,
    required this.name,
    required this.title,
    required this.onProfilePictureChange,
    required this.onCoverPhotoChange,
  });

  Future<void> _pickAndUpload(
      BuildContext context, Future<void> Function(File) uploadFn) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    try {
      final file = File(image.path);
      await uploadFn(file);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo updated")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover photo
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

        // Top-right icons
        Positioned(
          top: 40,
          right: 20,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                onPressed: () => _pickAndUpload(context, onCoverPhotoChange),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ),

        // Profile avatar + edit icon
        Positioned(
          bottom: -60,
          left: 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => _pickAndUpload(context, onProfilePictureChange),
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
                bottom: 75,
                right: -5,
                child: GestureDetector(
                  onTap: () => _pickAndUpload(context, onProfilePictureChange),
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

        // Name & title
        Positioned(
          bottom: -60,
          left: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(title,
                  style: const TextStyle(color: Colors.black, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
