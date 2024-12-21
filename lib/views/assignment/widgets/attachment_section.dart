import 'package:flutter/material.dart';

class AttachmentSection extends StatelessWidget {
  final String? uploadedFileName;
  final VoidCallback onRemoveFile;
  final VoidCallback onPickFile;
  final VoidCallback onSubmit;
  final bool isFileUploaded;
  final Color borderColor;
  final Color buttonColor;

  const AttachmentSection({
    super.key,
    required this.uploadedFileName,
    required this.onRemoveFile,
    required this.onPickFile,
    required this.onSubmit,
    required this.isFileUploaded,
    required this.borderColor,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachment',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text(
                    uploadedFileName ?? 'your_roll.pdf',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (isFileUploaded)
                GestureDetector(
                  onTap: onRemoveFile,
                  child: const Icon(Icons.close, color: Colors.black54),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: isFileUploaded
                ? Transform.rotate(
              angle: -3.141592653589793 / 4, // pi/4 radians
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.upload_file,
              color: Colors.white,
            ),
            label: Text(
              isFileUploaded ? 'Turn In' : 'Upload Task',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            onPressed: isFileUploaded ? onSubmit : onPickFile,
          ),
        ),
      ],
    );
  }
}
