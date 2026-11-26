import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milk_app/data/daos/ledger_dao.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';

typedef MonthSelection = ({int vendorId, int year, int month});

class MonthlyInsight {
  const MonthlyInsight({
    required this.month,
    required this.quantityMl,
    required this.amountPaise,
  });

  final DateTime month;
  final int quantityMl;
  final int amountPaise;
}

class MonthlyReportData {
  const MonthlyReportData({
    required this.vendor,
    required this.summary,
    required this.year,
    required this.month,
    required this.entries,
    required this.payments,
    required this.insights,
    this.currentRatePaise,
  });

  final Vendor vendor;
  final MonthlySummary summary;
  final int year;
  final int month;
  final List<DailyEntry> entries;
  final List<Payment> payments;
  final List<MonthlyInsight> insights;

  /// The rate in effect today, or `null` when no rate has started yet.
  final int? currentRatePaise;

  /// Average quantity per delivered day, in millilitres.
  int get averageDailyMl => summary.deliveredDays == 0
      ? 0
      : (summary.totalQuantityMl / summary.deliveredDays).round();
}

/// Builds a report for one month from an in-memory ledger snapshot.
/// Pure and synchronous, so it is cheap to recompute on every change.
MonthlyReportData buildMonthlyReport(
  VendorLedgerSnapshot ledger, {
  required int year,
  required int month,
  int insightMonths = 6,
}) {
  final billingEntries = billingEntriesOf(ledger);
  final paymentRecords = paymentRecordsOf(ledger);
  final summary = calculateMonthlySummary(
    openingBalancePaise: ledger.vendor.openingBalancePaise,
    entries: billingEntries,
    payments: paymentRecords,
    year: year,
    month: month,
  );

  // Insights cover the months ending at the selected month, in one pass.
  final firstInsightMonth = DateTime(year, month - (insightMonths - 1));
  final quantities = List<int>.filled(insightMonths, 0);
  final amounts = List<int>.filled(insightMonths, 0);
  for (final entry in billingEntries) {
    if (entry.status == DailyEntryStatus.skipped) {
      continue;
    }
    final index =
        (entry.date.year - firstInsightMonth.year) * 12 +
        entry.date.month -
        firstInsightMonth.month;
    if (index < 0 || index >= insightMonths) {
      continue;
    }
    quantities[index] += entry.quantityMl;
    amounts[index] += amountForEntry(entry);
  }

  final start = DateTime(year, month);
  final end = DateTime(year, month + 1);
  bool inMonth(DateTime date) => !date.isBefore(start) && date.isBefore(end);

  return MonthlyReportData(
    vendor: ledger.vendor,
    summary: summary,
    year: year,
    month: month,
    entries: [
      for (final entry in ledger.entries)
        if (inMonth(entry.date)) entry,
    ],
    payments: [
      for (final payment in ledger.payments)
        if (inMonth(payment.date)) payment,
    ],
    insights: [
      for (var index = 0; index < insightMonths; index++)
        MonthlyInsight(
          month: DateTime(
            firstInsightMonth.year,
            firstInsightMonth.month + index,
          ),
          quantityMl: quantities[index],
          amountPaise: amounts[index],
        ),
    ],
    currentRatePaise: rateForDate(milkRatesOf(ledger), DateTime.now()),
  );
}

// Conversions are cached per snapshot: the balance, the current month's
// report and any other month's report all read the same snapshot, so they
// share one converted list instead of each rebuilding it.
final Expando<List<BillingEntry>> _billingEntriesCache = Expando();
final Expando<List<PaymentRecord>> _paymentRecordsCache = Expando();
final Expando<List<MilkRate>> _milkRatesCache = Expando();

List<BillingEntry> billingEntriesOf(VendorLedgerSnapshot ledger) =>
    _billingEntriesCache[ledger] ??= List.unmodifiable([
      for (final entry in ledger.entries)
        BillingEntry(
          date: entry.date,
          quantityMl: entry.quantityMl,
          rateUsedPaise: entry.rateUsedPaise,
          status: entry.status,
        ),
    ]);

List<PaymentRecord> paymentRecordsOf(VendorLedgerSnapshot ledger) =>
    _paymentRecordsCache[ledger] ??= List.unmodifiable([
      for (final payment in ledger.payments)
        PaymentRecord(date: payment.date, amountPaise: payment.amountPaise),
    ]);

List<MilkRate> milkRatesOf(VendorLedgerSnapshot ledger) =>
    _milkRatesCache[ledger] ??= List.unmodifiable([
      for (final rate in ledger.rates)
        MilkRate(
          effectiveFrom: rate.effectiveFrom,
          ratePerLitrePaise: rate.ratePerLitrePaise,
        ),
    ]);

/// The single source of truth for a vendor's data. It re-emits after every
/// database write, so derived providers below never need manual invalidation.
final vendorLedgerProvider = StreamProvider.family<VendorLedgerSnapshot, int>((
  ref,
  vendorId,
) {
  return ref.watch(vendorRepositoryProvider).watchVendorLedger(vendorId).map((
    ledger,
  ) {
    if (ledger == null) {
      throw StateError('The selected vendor no longer exists.');
    }
    return ledger;
  });
});

/// Auto-disposed: one exists per (vendor, month) ever viewed, and a kept-alive
/// one would recompute on every write long after its screen moved on.
final monthlyReportProvider = Provider.autoDispose
    .family<AsyncValue<MonthlyReportData>, MonthSelection>(
      (ref, selection) => ref
          .watch(vendorLedgerProvider(selection.vendorId))
          .whenData(
            (ledger) => buildMonthlyReport(
              ledger,
              year: selection.year,
              month: selection.month,
            ),
          ),
    );

/// Running balance as of today (positive = due, negative = advance).
final vendorBalanceProvider = Provider.family<AsyncValue<int>, int>(
  (ref, vendorId) => ref
      .watch(vendorLedgerProvider(vendorId))
      .whenData(
        (ledger) => calculateAccountBalance(
          openingBalancePaise: ledger.vendor.openingBalancePaise,
          entries: billingEntriesOf(ledger),
          payments: paymentRecordsOf(ledger),
        ),
      ),
);

final vendorRateHistoryProvider =
    Provider.family<AsyncValue<List<MilkRate>>, int>(
      (ref, vendorId) =>
          ref.watch(vendorLedgerProvider(vendorId)).whenData(milkRatesOf),
    );
