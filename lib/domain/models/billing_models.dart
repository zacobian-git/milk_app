import 'package:milk_app/domain/models/ledger_enums.dart';

class MilkRate {
  const MilkRate({
    required this.effectiveFrom,
    required this.ratePerLitrePaise,
  });

  final DateTime effectiveFrom;
  final int ratePerLitrePaise;
}

class BillingEntry {
  const BillingEntry({
    required this.date,
    required this.quantityMl,
    required this.rateUsedPaise,
    required this.status,
  });

  final DateTime date;
  final int quantityMl;
  final int rateUsedPaise;
  final DailyEntryStatus status;
}

class DailyEntryDraft {
  const DailyEntryDraft({
    required this.date,
    required this.quantityMl,
    required this.rateUsedPaise,
    required this.status,
  });

  final DateTime date;
  final int quantityMl;
  final int rateUsedPaise;
  final DailyEntryStatus status;
}

class PaymentRecord {
  const PaymentRecord({required this.date, required this.amountPaise});

  final DateTime date;
  final int amountPaise;
}

class MonthlySummary {
  const MonthlySummary({
    required this.totalQuantityMl,
    required this.totalAmountPaise,
    required this.deliveredDays,
    required this.skippedDays,
    required this.paidPaise,
    required this.carriedForwardPaise,
    required this.closingBalancePaise,
  });

  final int totalQuantityMl;
  final int totalAmountPaise;
  final int deliveredDays;
  final int skippedDays;
  final int paidPaise;
  final int carriedForwardPaise;
  final int closingBalancePaise;
}
