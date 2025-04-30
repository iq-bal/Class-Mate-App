import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:classmate/controllers/profile_teacher/profile_teacher_controller.dart';
import 'package:classmate/controllers/authentication/auth_controller.dart';
import 'package:classmate/views/authentication/landing.dart';

import '../../../models/profile_teacher/profile_teacher_model.dart';

class TeacherSettingsPage extends StatefulWidget {
  const TeacherSettingsPage({super.key});

  @override
  State<TeacherSettingsPage> createState() => _TeacherSettingsPageState();
}

class _TeacherSettingsPageState extends State<TeacherSettingsPage> {
  final ProfileTeacherController _profileController = ProfileTeacherController();
  bool _emailNotifications = true;
  bool _profileVisible     = true;

  @override
  void initState() {
    super.initState();
    // kick off the fetch
    _profileController.fetchTeacherProfile();
  }

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
        _showError(authController.errorMessage ?? "Logout failed.");
      }
    } catch (_) {
      _showError("An unexpected error occurred during logout.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _editField(
      String title,
      String currentValue,
      Future<void> Function(String) onSave,
      ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter new value',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newVal = controller.text.trim();
              Navigator.pop(context);
              await onSave(newVal);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ValueListenableBuilder<ProfileTeacherState>(
        valueListenable: _profileController.stateNotifier,
        builder: (context, state, _) {
          // Delegate to a helper so we cover every case explicitly
          return _buildByState(state);
        },
      ),
    );
  }

  Widget _buildByState(ProfileTeacherState state) {
    switch (state) {
      case ProfileTeacherState.idle:
      case ProfileTeacherState.loading:
        return const Center(child: CircularProgressIndicator());

      case ProfileTeacherState.error:
        return Center(
          child: Text(
            _profileController.errorMessage ?? 'Failed to load profile',
            textAlign: TextAlign.center,
          ),
        );

      case ProfileTeacherState.success:
        final profile = _profileController.teacherProfile;
        if (profile == null) {
          // defensive fallback
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(profile);
    }
  }

  Widget _buildContent(ProfileTeacherModel profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name (static) ─────────────────────────
          _buildInfoRow(Icons.person, 'Name', profile.name),
          const SizedBox(height: 15),

          // ── Email (static) ────────────────────────
          _buildInfoRow(Icons.email, 'Email', profile.email),
          const SizedBox(height: 30),

          // ── Profile Settings ──────────────────────
          _buildSectionTitle('Profile Settings'),
          const SizedBox(height: 10),

          // Department (editable)
          _buildEditableRow(
            Icons.business,
            'Department',
            profile.teacher?.department ?? '',
                (newVal) => _profileController.updateTeacherDepartment(newVal),
          ),
          const SizedBox(height: 15),

          // Designation (editable)
          _buildEditableRow(
            Icons.grade,
            'Designation',
            profile.teacher?.designation ?? '',
                (newVal) => _profileController.updateTeacherDesignation(newVal),
          ),
          const SizedBox(height: 30),

          // ── Notifications ──────────────────────────
          _buildSectionTitle('Notifications'),
          const SizedBox(height: 10),
          _buildSwitchRow(
            icon: Icons.notifications_active,
            title: 'Email Notifications',
            value: _emailNotifications,
            onChanged: (v) => setState(() => _emailNotifications = v),
          ),
          const SizedBox(height: 30),

          // ── Privacy ───────────────────────────────
          _buildSectionTitle('Privacy'),
          const SizedBox(height: 10),
          _buildSwitchRow(
            icon: Icons.lock,
            title: 'Profile Visibility',
            value: _profileVisible,
            onChanged: (v) => setState(() => _profileVisible = v),
          ),
          const SizedBox(height: 50),

          // ── Logout ────────────────────────────────
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(
      IconData icon,
      String title,
      String value,
      Future<void> Function(String) onSave,
      ) {
    return InkWell(
      onTap: () => _editField(title, value, onSave),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blueAccent),
        ],
      ),
    );
  }
}
