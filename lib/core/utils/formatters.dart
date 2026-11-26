import 'package:intl/intl.dart';

// Formatters and patterns are expensive to build, and these helpers run on
// every frame of the dashboard's count-up animations, so they are cached.
final NumberFormat _moneyHi = NumberFormat.decimalPattern('hi_IN');
final NumberFormat _moneyEn = NumberFormat.decimalPattern('en_IN');
final Map<String, DateFormat> _dateFormats = {};
final RegExp _trailingZeros = RegExp(r'0+$');
final RegExp _digits = RegExp(r'^\d+$');
final RegExp _litreFraction = RegExp(r'^\d{1,3}$');
final RegExp _paiseFraction = RegExp(r'^\d{1,2}$');

String formatMoney(int amountPaise, String locale) {
  final formatter = locale == 'hi' ? _moneyHi : _moneyEn;
  final sign = amountPaise < 0 ? '-' : '';
  final absoluteAmount = amountPaise.abs();
  final rupees = formatter.format(absoluteAmount ~/ 100);
  final paise = (absoluteAmount % 100).toString().padLeft(2, '0');
  return '$sign₹$rupees.$paise';
}

/// Whole rupees only, for large headline figures.
String formatMoneyCompact(int amountPaise, String locale) {
  final formatter = locale == 'hi' ? _moneyHi : _moneyEn;
  final sign = amountPaise < 0 ? '-' : '';
  final rupees = (amountPaise.abs() + 50) ~/ 100;
  return '$sign₹${formatter.format(rupees)}';
}

String formatLitres(int quantityMl) {
  final wholeLitres = quantityMl ~/ 1000;
  final fractionalMl = (quantityMl % 1000).abs();
  final fraction = fractionalMl == 0
      ? ''
      : '.${fractionalMl.toString().padLeft(3, '0').replaceFirst(_trailingZeros, '')}';
  return '$wholeLitres$fraction';
}

String formatDate(DateTime date, String locale) => _dateFormats
    .putIfAbsent(locale, () => DateFormat('dd MMM yyyy', locale))
    .format(date);

int? parseLitresToMl(String input) {
  final value = input.trim().replaceAll(',', '.');
  final parts = value.split('.');
  if (parts.length > 2 ||
      parts.first.isEmpty ||
      !_digits.hasMatch(parts.first)) {
    return null;
  }
  final whole = int.tryParse(parts.first);
  if (whole == null) {
    return null;
  }
  final fraction = parts.length == 1 ? '' : parts[1];
  if (fraction.isNotEmpty && !_litreFraction.hasMatch(fraction)) {
    return null;
  }
  final fractionalMl = int.tryParse(fraction.padRight(3, '0')) ?? 0;
  return whole * 1000 + fractionalMl;
}

int? parseRupeesToPaise(String input) {
  final value = input.trim().replaceAll(',', '').replaceAll('₹', '');
  final parts = value.split('.');
  if (parts.length > 2 ||
      parts.first.isEmpty ||
      !_digits.hasMatch(parts.first)) {
    return null;
  }
  final rupees = int.tryParse(parts.first);
  if (rupees == null) {
    return null;
  }
  final fraction = parts.length == 1 ? '' : parts[1];
  if (fraction.isNotEmpty && !_paiseFraction.hasMatch(fraction)) {
    return null;
  }
  return rupees * 100 + (int.tryParse(fraction.padRight(2, '0')) ?? 0);
}
