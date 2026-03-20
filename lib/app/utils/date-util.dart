import 'package:intl/intl.dart';

class DateUtil {

  static String formatDateDDEEYY(String? value) {
    if (value == null) return '';
    DateTime date = DateTime.parse(value);
    String formattedDate = DateFormat('d MMM, y').format(date);
    return formattedDate;
  }
}

