import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class TimePickerField extends StatelessWidget {
  final String labelText;
  final TimeOfDay? selectedTime;
  final VoidCallback onTap;

  const TimePickerField({
    Key? key,
    required this.labelText,
    this.selectedTime,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
            hintText: selectedTime != null
                ? DateFormat.jm().format(DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              selectedTime!.hour,
              selectedTime!.minute,
            ))
                : 'Select Time',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.access_time, color: Colors.teal),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}


// class TimePickerField extends StatelessWidget {
//   final String labelText;
//   final TimeOfDay? selectedTime;
//   final VoidCallback onTap;
//
//   const TimePickerField({
//     Key? key,
//     required this.labelText,
//     this.selectedTime,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AbsorbPointer(
//         child: TextField(
//           decoration: InputDecoration(
//             labelText: labelText,
//             labelStyle: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.teal,
//             ),
//             hintText: selectedTime != null
//                 ? DateFormat.jm().format(DateTime(
//               DateTime.now().year,
//               DateTime.now().month,
//               DateTime.now().day,
//               selectedTime!.hour,
//               selectedTime!.minute,
//             ))
//                 : 'Select Time',
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             prefixIcon: const Icon(Icons.access_time, color: Colors.teal),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           ),
//         ),
//       ),
//     );
//   }
// }
