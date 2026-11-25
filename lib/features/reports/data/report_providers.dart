import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/billing_models.dart';

typedef MonthSelection = ({int vendorId, int year, int month});
typedef EntryDateSelection = ({int vendorId, DateTime date});

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
  });

  final Vendor vendor;
  final MonthlySummary summary;
  final int year;
  final int month;
  final List<DailyEntry> entries;
  final List<Payment> payments;
  final List<MonthlyInsight> insights;
}

final vendorRateHistoryProvider = FutureProvider.family<List<MilkRate>, int>(
  (ref, vendorId) =>
      ref.watch(vendorRepositoryProvider).getRateHistory(vendorId),
);

final monthlyReportProvider =
    FutureProvider.family<MonthlyReportData, MonthSelection>((
      ref,
      selection,
    ) async {
      final vendors = ref.watch(vendorRepositoryProvider);
      final entriesRepo = ref.watch(dailyEntryRepositoryProvider);
      final paymentsRepo = ref.watch(paymentRepositoryProvider);
      final vendor = await vendors.getVendor(selection.vendorId);
      if (vendor == null) {
        throw StateError('The selected vendor no longer exists.');
      }

      final allEntries = await entriesRepo.getAllEntries(selection.vendorId);
      final allPayments = await paymentsRepo.getAllPayments(selection.vendorId);
      final summary = calculateMonthlySummary(
        openingBalancePaise: vendor.openingBalancePaise,
        entries: allEntries.map(
          (entry) => BillingEntry(
            date: entry.date,
            quantityMl: entry.quantityMl,
            rateUsedPaise: entry.rateUsedPaise,
            status: entry.status,
          ),
        ),
        payments: allPayments.map(
          (payment) => PaymentRecord(
            date: payment.date,
            amountPaise: payment.amountPaise,
          ),
        ),
        year: selection.year,
        month: selection.month,
      );
      final now = DateTime.now();
      final insights = <MonthlyInsight>[];
      for (var monthOffset = 5; monthOffset >= 0; monthOffset--) {
        final insightMonth = DateTime(now.year, now.month - monthOffset);
        final insightSummary = calculateMonthlySummary(
          openingBalancePaise: vendor.openingBalancePaise,
          entries: allEntries.map(
            (entry) => BillingEntry(
              date: entry.date,
              quantityMl: entry.quantityMl,
              rateUsedPaise: entry.rateUsedPaise,
              status: entry.status,
            ),
          ),
          payments: allPayments.map(
            (payment) => PaymentRecord(
              date: payment.date,
              amountPaise: payment.amountPaise,
            ),
          ),
          year: insightMonth.year,
          month: insightMonth.month,
        );
        insights.add(
          MonthlyInsight(
            month: insightMonth,
            quantityMl: insightSummary.totalQuantityMl,
            amountPaise: insightSummary.totalAmountPaise,
          ),
        );
      }
      final start = DateTime(selection.year, selection.month);
      final end = DateTime(selection.year, selection.month + 1);
      return MonthlyReportData(
        vendor: vendor,
        summary: summary,
        year: selection.year,
        month: selection.month,
        entries: allEntries
            .where(
              (entry) =>
                  !entry.date.isBefore(start) && entry.date.isBefore(end),
            )
            .toList(growable: false),
        payments: allPayments
            .where(
              (payment) =>
                  !payment.date.isBefore(start) && payment.date.isBefore(end),
            )
            .toList(growable: false),
        insights: insights,
      );
    });

final entriesForMonthProvider =
    FutureProvider.family<List<DailyEntry>, MonthSelection>((ref, selection) {
      final start = DateTime(selection.year, selection.month);
      final end = DateTime(selection.year, selection.month + 1, 0);
      return ref
          .watch(dailyEntryRepositoryProvider)
          .getEntriesForRange(selection.vendorId, start, end);
    });

final entryForDateProvider =
    FutureProvider.family<DailyEntry?, EntryDateSelection>(
      (ref, selection) => ref
          .watch(dailyEntryRepositoryProvider)
          .getEntryForDate(selection.vendorId, selection.date),
    );
