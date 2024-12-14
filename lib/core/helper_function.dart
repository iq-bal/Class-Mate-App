import 'package:intl/intl.dart';
class HelperFunction {
  static String getFirstTwoLettersUppercase(String input) {
    if (input.isEmpty) {
      return '';
    }
    String firstTwoLetters = input.length >= 2 ? input.substring(0, 2) : input;
    return firstTwoLetters.toUpperCase();
  }
  static String formatTimestamp(String timestamp) {
    int parsedTimestamp = int.tryParse(timestamp) ?? 0;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(parsedTimestamp);
    return DateFormat('MMM d, yyyy').format(date);
  }

}
