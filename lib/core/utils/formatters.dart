import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currency = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return currency.copyWith(symbol: symbol).format(amount);
  }

  static String formatDate(DateTime date) {
    return dateFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return timeFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return dateTimeFormat.format(date);
  }
}

