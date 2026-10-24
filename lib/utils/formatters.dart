import 'package:intl/intl.dart';

final NumberFormat _wholeRupees =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final NumberFormat _rupeesWithPaise =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
final DateFormat _dateFormat = DateFormat('d MMM yyyy');
final DateFormat _monthFormat = DateFormat('MMMM yyyy');
final DateFormat _shortMonthFormat = DateFormat('MMM');

/// ₹1,250 for whole amounts, ₹1,250.50 when there are paise.
String formatCurrency(double value) {
  final hasPaise = (value * 100).round() % 100 != 0;
  return (hasPaise ? _rupeesWithPaise : _wholeRupees).format(value);
}

/// 20 Oct 2026
String formatDate(DateTime date) => _dateFormat.format(date);

/// October 2026
String formatMonth(DateTime date) => _monthFormat.format(date);

/// Oct
String formatShortMonth(DateTime date) => _shortMonthFormat.format(date);

/// Plain number for text fields: 250 or 250.50, no symbol or grouping.
String formatAmountInput(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
