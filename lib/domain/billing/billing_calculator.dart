import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';

int calculateEntryAmountPaise({
  required int quantityMl,
  required int ratePerLitrePaise,
}) {
  if (quantityMl < 0 || ratePerLitrePaise < 0) {
    throw ArgumentError('Quantity and rate must not be negative.');
  }

  return (quantityMl * ratePerLitrePaise + 500) ~/ 1000;
}

int paymentAmountForAdditionalAdvancePaise({
  required int balancePaise,
  required int additionalAdvancePaise,
}) {
  if (additionalAdvancePaise <= 0) {
    throw ArgumentError.value(additionalAdvancePaise, 'additionalAdvancePaise');
  }
  return (balancePaise > 0 ? balancePaise : 0) + additionalAdvancePaise;
}

int amountForEntry(BillingEntry entry) {
  if (entry.status == DailyEntryStatus.skipped) {
    return 0;
  }
  return calculateEntryAmountPaise(
    quantityMl: entry.quantityMl,
    ratePerLitrePaise: entry.rateUsedPaise,
  );
}

int calculateAccountBalance({
  required int openingBalancePaise,
  required Iterable<BillingEntry> entries,
  required Iterable<PaymentRecord> payments,
}) {
  return openingBalancePaise +
      entries.fold<int>(0, (total, entry) => total + amountForEntry(entry)) -
      payments.fold<int>(0, (total, payment) => total + payment.amountPaise);
}

MonthlySummary calculateMonthlySummary({
  required int openingBalancePaise,
  required Iterable<BillingEntry> entries,
  required Iterable<PaymentRecord> payments,
  required int year,
  required int month,
}) {
  final start = DateTime(year, month);
  final nextMonth = DateTime(year, month + 1);

  // One pass over each list; this runs on every ledger change for every
  // visible vendor, so it avoids building intermediate collections.
  var carriedForward = openingBalancePaise;
  var totalAmount = 0;
  var totalQuantity = 0;
  var deliveredDays = 0;
  var skippedDays = 0;
  for (final entry in entries) {
    if (entry.date.isBefore(start)) {
      carriedForward += amountForEntry(entry);
    } else if (entry.date.isBefore(nextMonth)) {
      if (entry.status == DailyEntryStatus.skipped) {
        skippedDays++;
      } else {
        deliveredDays++;
        totalQuantity += entry.quantityMl;
        totalAmount += amountForEntry(entry);
      }
    }
  }

  var paidThisMonth = 0;
  for (final payment in payments) {
    if (payment.date.isBefore(start)) {
      carriedForward -= payment.amountPaise;
    } else if (payment.date.isBefore(nextMonth)) {
      paidThisMonth += payment.amountPaise;
    }
  }

  return MonthlySummary(
    totalQuantityMl: totalQuantity,
    totalAmountPaise: totalAmount,
    deliveredDays: deliveredDays,
    skippedDays: skippedDays,
    paidPaise: paidThisMonth,
    carriedForwardPaise: carriedForward,
    closingBalancePaise: carriedForward + totalAmount - paidThisMonth,
  );
}

int? rateForDate(Iterable<MilkRate> rates, DateTime date) {
  final targetDate = dateOnly(date);
  MilkRate? effectiveRate;
  for (final rate in rates) {
    if (!dateOnly(rate.effectiveFrom).isAfter(targetDate) &&
        (effectiveRate == null ||
            dateOnly(rate.effectiveFrom)
                .isAfter(dateOnly(effectiveRate.effectiveFrom)))) {
      effectiveRate = rate;
    }
  }
  return effectiveRate?.ratePerLitrePaise;
}

List<DailyEntryDraft> buildBulkDeliveryEntries({
  required DateTime startDate,
  required DateTime endDate,
  required int defaultQtyMl,
  required Iterable<MilkRate> rates,
  required Set<DateTime> existingDates,
  DailyEntryStatus status = DailyEntryStatus.delivered,
}) {
  if (defaultQtyMl < 0) {
    throw ArgumentError.value(defaultQtyMl, 'defaultQtyMl');
  }
  final start = dateOnly(startDate);
  final end = dateOnly(endDate);
  if (start.isAfter(end)) {
    throw ArgumentError('The start date must not be after the end date.');
  }

  final normalizedExistingDates = existingDates.map(dateOnly).toSet();
  final applicableRates = rates.toList(growable: false);
  final entries = <DailyEntryDraft>[];
  final isSkipped = status == DailyEntryStatus.skipped;
  for (var date = start; !date.isAfter(end); date = addDays(date, 1)) {
    if (normalizedExistingDates.contains(date)) {
      continue;
    }

    final rate = rateForDate(applicableRates, date);
    if (rate == null) {
      throw StateError(
        'No milk rate is configured for ${date.toIso8601String()}.',
      );
    }
    entries.add(
      DailyEntryDraft(
        date: date,
        quantityMl: isSkipped ? 0 : defaultQtyMl,
        rateUsedPaise: rate,
        status: isSkipped
            ? DailyEntryStatus.skipped
            : DailyEntryStatus.delivered,
      ),
    );
  }
  return entries;
}
