import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static final NumberFormat _formatterWithSpace = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format as Rp1.250.000 (standard Indonesian format)
  static String format(double amount, {bool withSpace = false}) {
    final formatted = withSpace 
        ? _formatterWithSpace.format(amount) 
        : _formatter.format(amount);
    return formatted;
  }

  /// Compact representation for chart axis or small cards (e.g., 1.5jt, 250rb)
  static String formatCompact(double amount) {
    if (amount.abs() >= 1000000000) {
      final val = amount / 1000000000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} M';
    } else if (amount.abs() >= 1000000) {
      final val = amount / 1000000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} jt';
    } else if (amount.abs() >= 1000) {
      final val = amount / 1000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} rb';
    } else {
      return amount.toInt().toString();
    }
  }
}
