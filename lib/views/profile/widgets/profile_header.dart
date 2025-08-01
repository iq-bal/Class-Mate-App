import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://i.pravatar.cc/150?img=47"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: screenWidth / 2 - 50,
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 46,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=47"),
            ),
          ),
        ),
      ],
    );
  }
}
