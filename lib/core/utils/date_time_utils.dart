import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(dateTime);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'id_ID').format(date);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm', 'id_ID').format(dateTime);
  }

  static String formatDateForDatabase(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  static DateTime parseFromDatabase(String dateString) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

