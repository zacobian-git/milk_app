import 'package:intl/intl.dart';

String formatMoney(int amountPaise, String locale) {
  final formatter = NumberFormat.decimalPattern(
    locale == 'hi' ? 'hi_IN' : 'en_IN',
  );
  final sign = amountPaise < 0 ? '-' : '';
  final absoluteAmount = amountPaise.abs();
  final rupees = formatter.format(absoluteAmount ~/ 100);
  final paise = (absoluteAmount % 100).toString().padLeft(2, '0');
  return '$sign₹$rupees.$paise';
}

String formatLitres(int quantityMl) {
  final wholeLitres = quantityMl ~/ 1000;
  final fractionalMl = (quantityMl % 1000).abs();
  final fraction = fractionalMl == 0
      ? ''
      : '.${fractionalMl.toString().padLeft(3, '0').replaceFirst(RegExp(r'0+$'), '')}';
  final number = '$wholeLitres$fraction';
  return number;
}

String formatDate(DateTime date, String locale) =>
    DateFormat('dd MMM yyyy', locale).format(date);

int? parseLitresToMl(String input) {
  final value = input.trim().replaceAll(',', '.');
  final parts = value.split('.');
  if (parts.length > 2 ||
      parts.first.isEmpty ||
      !RegExp(r'^\d+$').hasMatch(parts.first)) {
    return null;
  }
  final whole = int.tryParse(parts.first);
  if (whole == null) {
    return null;
  }
  final fraction = parts.length == 1 ? '' : parts[1];
  if (fraction.isNotEmpty && !RegExp(r'^\d{1,3}$').hasMatch(fraction)) {
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
      !RegExp(r'^\d+$').hasMatch(parts.first)) {
    return null;
  }
  final rupees = int.tryParse(parts.first);
  if (rupees == null) {
    return null;
  }
  final fraction = parts.length == 1 ? '' : parts[1];
  if (fraction.isNotEmpty && !RegExp(r'^\d{1,2}$').hasMatch(fraction)) {
    return null;
  }
  return rupees * 100 + (int.tryParse(fraction.padRight(2, '0')) ?? 0);
}
