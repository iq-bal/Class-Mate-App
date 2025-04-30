import 'dart:ui';
import 'package:flutter/material.dart';

class SyllabusPage extends StatefulWidget {
  final String courseId;
  final void Function(Map<String, List<String>> syllabus)? onSyllabusChanged;

  const SyllabusPage({super.key, required this.courseId, this.onSyllabusChanged});

  @override
  State<SyllabusPage> createState() => _SyllabusPageState();
}

class _SyllabusPageState extends State<SyllabusPage> {
  final TextEditingController _moduleController = TextEditingController();
  final Map<String, TextEditingController> _topicControllers = {};
  Map<String, List<String>> syllabusData = {};

  // Add a new module
  void _addModule() {
    final text = _moduleController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      syllabusData[text] = [];
    });
    _moduleController.clear();

    // Notify parent (via onSyllabusChanged) whenever data is updated
    widget.onSyllabusChanged?.call(syllabusData);
  }

  // Add a topic to a specific module
  void _addTopic(String module) {
    final controller = _topicControllers[module];
    if (controller == null || controller.text.trim().isEmpty) return;
    setState(() {
      syllabusData[module]?.add(controller.text.trim());
    });
    controller.clear();

    // Notify parent (via onSyllabusChanged) whenever data is updated
    widget.onSyllabusChanged?.call(syllabusData);
  }

  // Remove a module and all its topics
  void _removeModule(String module) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module?'),
        content: Text('Are you sure you want to delete "$module" along with all its topics?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        syllabusData.remove(module);
        _topicControllers.remove(module);
      });

      // Notify parent (via onSyllabusChanged) whenever data is updated
      widget.onSyllabusChanged?.call(syllabusData);
    }
  }

  // Remove a topic from a specific module
  void _removeTopic(String module, String topic) {
    setState(() {
      syllabusData[module]?.remove(topic);
    });

    // Notify parent (via onSyllabusChanged) whenever data is updated
    widget.onSyllabusChanged?.call(syllabusData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'Syllabus Builder 📚',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 25),
              _buildGlassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _moduleController,
                        decoration: _inputDecoration('Add New Module (e.g., Introduction)'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 30),
                      onPressed: _addModule,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (syllabusData.isEmpty)
                const Center(
                  child: Text('No modules added yet. Start by adding one!', style: TextStyle(color: Colors.black54)),
                ),
              ...syllabusData.keys.map((module) => _buildModuleCard(module)),
            ],
          ),
        ),
      ),
    );
  }

  // Build the card for each module
  Widget _buildModuleCard(String module) {
    _topicControllers.putIfAbsent(module, () => TextEditingController()); // create controller if not exists

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          backgroundColor: Colors.white.withOpacity(0.15),
          collapsedBackgroundColor: Colors.white.withOpacity(0.1),
          title: Text(
            module,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _removeModule(module),
          ),
          children: [
            ListView.builder(
              itemCount: syllabusData[module]?.length ?? 0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final topic = syllabusData[module]![index];
                return ListTile(
                  title: Text(topic, style: const TextStyle(color: Colors.black87)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _removeTopic(module, topic),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _topicControllers[module],
                      decoration: _inputDecoration('Add topic to "$module"'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green, size: 28),
                    onPressed: () => _addTopic(module),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the glass card (with background blur effect)
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Input decoration style
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
      ),
    );
  }
}
