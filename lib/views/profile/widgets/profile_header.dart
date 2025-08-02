import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileHeader extends StatelessWidget {
  final String coverImageUrl;
  final String profileImageUrl;
  final Function(File)? onCoverImageEdit;
  final Function(File)? onProfileImageEdit;

  const ProfileHeader({
    super.key,
    required this.coverImageUrl,
    required this.profileImageUrl,
    this.onCoverImageEdit,
    this.onProfileImageEdit,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Photo
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(coverImageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Cover Photo Camera Icon
        Positioned(
          top: 160, // lowered slightly
          right: 16,
          child: GestureDetector(
            onTap: () => _pickCoverImage(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),

        // Profile Picture with Camera Icon
        Positioned(
          bottom: -50,
          left: screenWidth / 2 - 50,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 46,
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
              ),

              // Camera Icon on Top Right of Profile Image
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickProfileImage(),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null && onCoverImageEdit != null) {
      onCoverImageEdit!(File(image.path));
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null && onProfileImageEdit != null) {
      onProfileImageEdit!(File(image.path));
    }
  }
}
