import 'package:flutter/material.dart';

class AboutMeSection extends StatefulWidget {
  final String initialAboutMeText;
  final ValueChanged<String> onSave;

  const AboutMeSection({
    super.key,
    required this.initialAboutMeText,
    required this.onSave,
  });

  @override
  State<AboutMeSection> createState() => _AboutMeSectionState();
}

class _AboutMeSectionState extends State<AboutMeSection> {
  bool _isEditing = false;
  late TextEditingController _textController;
  late String _aboutMeText;

  @override
  void initState() {
    super.initState();
    _aboutMeText    = widget.initialAboutMeText;
    _textController = TextEditingController(text: _aboutMeText);
  }

  @override
  void didUpdateWidget(covariant AboutMeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if parent passed a new initial text, update local state & controller
    if (widget.initialAboutMeText != oldWidget.initialAboutMeText) {
      _aboutMeText    = widget.initialAboutMeText;
      _textController.text = _aboutMeText;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final newText = _textController.text.trim();
    setState(() {
      _aboutMeText = newText;
      _isEditing   = false;
    });
    widget.onSave(newText);
  }

  void _cancelEditing() {
    setState(() {
      _textController.text = _aboutMeText;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('About Me',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit,
                    color: Colors.blueAccent),
                onPressed: () => setState(() => _isEditing = !_isEditing),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isEditing) ...[
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter about me...',
                filled: true,
                fillColor: Colors.blueAccent.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _cancelEditing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(_aboutMeText, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ],
      ),
    );
  }
}
