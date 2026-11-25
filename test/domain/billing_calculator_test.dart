import 'package:flutter_test/flutter_test.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';

void main() {
  group('rate history', () {
    final rates = [
      MilkRate(effectiveFrom: DateTime(2025, 6, 1), ratePerLitrePaise: 8000),
      MilkRate(effectiveFrom: DateTime(2025, 6, 15), ratePerLitrePaise: 10000),
    ];

    test('uses the rate effective on the entry date', () {
      expect(rateForDate(rates, DateTime(2025, 6, 14)), 8000);
      expect(rateForDate(rates, DateTime(2025, 6, 15, 20)), 10000);
      expect(rateForDate(rates, DateTime(2025, 5, 31)), isNull);
    });

    test('rate changes do not recalculate saved entry snapshots', () {
      final entries = [
        BillingEntry(
          date: DateTime(2025, 6, 14),
          quantityMl: 1000,
          rateUsedPaise: rateForDate(rates, DateTime(2025, 6, 14))!,
          status: DailyEntryStatus.delivered,
        ),
        BillingEntry(
          date: DateTime(2025, 6, 15),
          quantityMl: 1000,
          rateUsedPaise: rateForDate(rates, DateTime(2025, 6, 15))!,
          status: DailyEntryStatus.delivered,
        ),
      ];

      expect(
        calculateAccountBalance(
          openingBalancePaise: 0,
          entries: entries,
          payments: const [],
        ),
        18000,
      );
    });
  });

  test('includes opening balance in the account balance', () {
    final balance = calculateAccountBalance(
      openingBalancePaise: 2500,
      entries: [
        BillingEntry(
          date: DateTime(2025, 1, 1),
          quantityMl: 1000,
          rateUsedPaise: 12000,
          status: DailyEntryStatus.delivered,
        ),
      ],
      payments: const [],
    );

    expect(balance, 14500);
  });

  test('represents an overpayment as a negative advance balance', () {
    final balance = calculateAccountBalance(
      openingBalancePaise: 2500,
      entries: const [],
      payments: [PaymentRecord(date: DateTime(2025, 1, 1), amountPaise: 10000)],
    );

    expect(balance, -7500);
  });

  test(
    'advance shortcuts cover the bill and leave the chosen extra credit',
    () {
      expect(
        paymentAmountForAdditionalAdvancePaise(
          balancePaise: 12500,
          additionalAdvancePaise: 50000,
        ),
        62500,
      );
      expect(
        paymentAmountForAdditionalAdvancePaise(
          balancePaise: -2500,
          additionalAdvancePaise: 50000,
        ),
        50000,
      );
    },
  );

  test('bulk entries skip existing dates and apply rate changes', () {
    final entries = buildBulkDeliveryEntries(
      startDate: DateTime(2024, 2, 28, 12),
      endDate: DateTime(2024, 3, 2, 18),
      defaultQtyMl: 750,
      rates: [
        MilkRate(effectiveFrom: DateTime(2024, 2, 1), ratePerLitrePaise: 7000),
        MilkRate(effectiveFrom: DateTime(2024, 3, 1), ratePerLitrePaise: 8000),
      ],
      existingDates: {DateTime(2024, 2, 29)},
    );

    expect(entries.map((entry) => entry.date).toList(), [
      DateTime(2024, 2, 28),
      DateTime(2024, 3, 1),
      DateTime(2024, 3, 2),
    ]);
    expect(entries.map((entry) => entry.rateUsedPaise), [7000, 8000, 8000]);
    expect(entries.every((entry) => entry.quantityMl == 750), isTrue);
    expect(
      entries.every((entry) => entry.status == DailyEntryStatus.delivered),
      isTrue,
    );
  });

  test(
    'monthly summary carries the previous month balance into leap February',
    () {
      final summary = calculateMonthlySummary(
        openingBalancePaise: 0,
        entries: [
          BillingEntry(
            date: DateTime(2024, 1, 31),
            quantityMl: 1000,
            rateUsedPaise: 10000,
            status: DailyEntryStatus.delivered,
          ),
          BillingEntry(
            date: DateTime(2024, 2, 1),
            quantityMl: 500,
            rateUsedPaise: 10000,
            status: DailyEntryStatus.custom,
          ),
          BillingEntry(
            date: DateTime(2024, 2, 29),
            quantityMl: 0,
            rateUsedPaise: 10000,
            status: DailyEntryStatus.skipped,
          ),
          BillingEntry(
            date: DateTime(2024, 3, 1),
            quantityMl: 1000,
            rateUsedPaise: 10000,
            status: DailyEntryStatus.delivered,
          ),
        ],
        payments: [
          PaymentRecord(date: DateTime(2024, 1, 31), amountPaise: 2000),
          PaymentRecord(date: DateTime(2024, 2, 29), amountPaise: 2500),
        ],
        year: 2024,
        month: 2,
      );

      expect(summary.totalQuantityMl, 500);
      expect(summary.totalAmountPaise, 5000);
      expect(summary.deliveredDays, 1);
      expect(summary.skippedDays, 1);
      expect(summary.paidPaise, 2500);
      expect(summary.carriedForwardPaise, 8000);
      expect(summary.closingBalancePaise, 10500);
    },
  );

  test('rounds paise to the nearest integer without floating point', () {
    expect(
      calculateEntryAmountPaise(quantityMl: 0, ratePerLitrePaise: 15000),
      0,
    );
    expect(calculateEntryAmountPaise(quantityMl: 500, ratePerLitrePaise: 1), 1);
    expect(calculateEntryAmountPaise(quantityMl: 249, ratePerLitrePaise: 2), 0);
  });

  test('skipped days do not add charges', () {
    final balance = calculateAccountBalance(
      openingBalancePaise: 0,
      entries: [
        BillingEntry(
          date: DateTime(2025, 1, 1),
          quantityMl: 1000,
          rateUsedPaise: 12000,
          status: DailyEntryStatus.skipped,
        ),
      ],
      payments: const [],
    );

    expect(balance, 0);
  });
}
