import 'package:classmate/views/authentication/landing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:classmate/controllers/authentication/auth_controller.dart';

class TeacherSettingsPage extends StatefulWidget {
  const TeacherSettingsPage({super.key});

  @override
  State<TeacherSettingsPage> createState() => _TeacherSettingsPageState();
}

class _TeacherSettingsPageState extends State<TeacherSettingsPage> {
  bool _emailNotifications = true;
  bool _profileVisible = true;

  String _name = 'Emily Carter';
  String _department = 'Department of Computer Science';
  String _email = 'emily.carter@globaluni.edu';
  String _designation = 'professor';

  void _editField(String title, String currentValue, ValueChanged<String> onSave) {
    final TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new $title',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);

    try {
      await authController.logout(context);

      if (authController.stateNotifier.value == AuthState.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
              (route) => false,
        );
      } else if (authController.stateNotifier.value == AuthState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? "Logout failed."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred during logout."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Profile Settings'),
              const SizedBox(height: 10),
              _buildEditableRow(Icons.person, 'Name', _name, (newValue) {
                setState(() {
                  _name = newValue;
                });
              }),
              const SizedBox(height: 15),
              _buildEditableRow(Icons.business, 'Department', _department, (newValue) {
                setState(() {
                  _department = newValue;
                });
              }),
              const SizedBox(height: 15),
              _buildEditableRow(Icons.email, 'Email', _email, (newValue) {
                setState(() {
                  _email = newValue;
                });
              }),
              const SizedBox(height: 15),
              _buildEditableRow(Icons.grade, 'Designation', _designation, (newValue) {
                setState(() {
                  _designation = newValue;
                });
              }),

              const SizedBox(height: 30),
              _buildSectionTitle('Notifications'),
              const SizedBox(height: 10),
              _buildSwitchRow(
                icon: Icons.notifications_active,
                title: 'Email Notifications',
                value: _emailNotifications,
                onChanged: (val) {
                  setState(() {
                    _emailNotifications = val;
                  });
                },
              ),

              const SizedBox(height: 30),
              _buildSectionTitle('Privacy'),
              const SizedBox(height: 10),
              _buildSwitchRow(
                icon: Icons.lock,
                title: 'Profile Visibility',
                value: _profileVisible,
                onChanged: (val) {
                  setState(() {
                    _profileVisible = val;
                  });
                },
              ),

              const SizedBox(height: 50),
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
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEditableRow(IconData icon, String title, String value, ValueChanged<String> onSave) {
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
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}
