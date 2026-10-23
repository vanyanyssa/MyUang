import 'package:intl/intl.dart';

class DateFormatter {
  static const List<String> monthNamesIndonesian = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> shortMonthNamesIndonesian = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String getMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return monthNamesIndonesian[month];
    }
    return '';
  }

  static String getShortMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return shortMonthNamesIndonesian[month];
    }
    return '';
  }

  /// Example: 23 Oktober 2026
  static String formatFull(DateTime date) {
    return '${date.day} ${getMonthName(date.month)} ${date.year}';
  }

  /// Example: 23 Okt 2026
  static String formatMedium(DateTime date) {
    return '${date.day} ${getShortMonthName(date.month)} ${date.year}';
  }

  /// Example: 23/10/2026
  static String formatNumeric(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  /// Example: Oktober 2026
  static String formatMonthYear(DateTime date) {
    return '${getMonthName(date.month)} ${date.year}';
  }

  /// Example: Okt 2026
  static String formatShortMonthYear(DateTime date) {
    return '${getShortMonthName(date.month)} ${date.year}';
  }

  /// Example: Jumat, 23 Oktober 2026
  static String formatWithDay(DateTime date) {
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return formatFull(date);
    }
  }
}
