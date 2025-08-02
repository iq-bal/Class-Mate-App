import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/authentication/auth_controller.dart';
import '../../../controllers/profile_student/profile_student_controller.dart';
import '../../../models/profile_student/profile_student_model.dart';
import '../../authentication/landing.dart';
import 'edit_profile_dialog.dart';

class ActionsSection extends StatelessWidget {
  final ProfileStudentModel? profile;
  final ProfileStudentController? controller;

  const ActionsSection({
    super.key,
    this.profile,
    this.controller,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    try {
      await authController.logout(context);
      if (authController.stateNotifier.value == AuthState.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LandingPage()),
              (route) => false,
        );
      } else {
        _showError(context, authController.errorMessage ?? "Logout failed.");
      }
    } catch (_) {
      _showError(context, "An unexpected error occurred during logout.");
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _actionTile(
          context,
          icon: Icons.edit_note_rounded,
          label: "Edit Profile",
          iconColor: Colors.indigo,
          onTap: () {
            if (profile != null && controller != null) {
              showDialog(
                context: context,
                builder: (context) => EditProfileDialog(
                  profile: profile!,
                  controller: controller!,
                ),
              );
            }
          },
        ),
        _actionTile(
          context,
          icon: Icons.file_copy_rounded,
          label: "View Transcript",
          iconColor: Colors.teal,
          onTap: () {
            // TODO: Implement View Transcript action
          },
        ),
        _actionTile(
          context,
          icon: Icons.logout_rounded,
          label: "Logout",
          iconColor: Colors.redAccent,
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }

  Widget _actionTile(BuildContext context,
      {required IconData icon,
        required String label,
        required Color iconColor,
        required VoidCallback onTap}) {
    return Container(
      decoration: _glassBox(),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 26),
        title: Text(label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  BoxDecoration _glassBox() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
