import 'package:intl/intl.dart';

String formatDate(String? iso) {
  if (iso == null) return '';
  try {
    final dt = DateTime.parse(iso);
    return DateFormat.yMMMd().add_jm().format(dt);
  } catch (_) {
    return iso;
  }
}

String formatShortDate(String? iso) {
  if (iso == null) return '';
  try {
    final dt = DateTime.parse(iso);
    return DateFormat.yMMMd().format(dt);
  } catch (_) {
    return iso;
  }
}

String formatCurrency(double amount) => NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount);
