import 'package:flutter_test/flutter_test.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/data/repositories/daily_entry_repository.dart';
import 'package:milk_app/data/repositories/payment_repository.dart';
import 'package:milk_app/data/repositories/vendor_repository.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/features/calendar/presentation/daily_entry_editor_sheet.dart';
import 'package:milk_app/features/reports/data/bill_pdf_service.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';

void main() {
  late MilkDatabase database;
  late VendorRepository vendors;
  late DailyEntryRepository entries;
  late PaymentRepository payments;

  setUp(() {
    database = createInMemoryDatabase();
    vendors = VendorRepository(database.ledgerDao);
    entries = DailyEntryRepository(database.ledgerDao);
    payments = PaymentRepository(database.ledgerDao);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> addVendor() => vendors.addVendorWithRate(
    name: 'Mohan Dairy',
    milkType: 'cow',
    defaultQtyMl: 1000,
    ratePerLitrePaise: 6000,
    effectiveFrom: DateTime(2025, 1, 1),
  );

  test('ledger stream ignores writes that belong to another vendor', () async {
    final vendorId = await addVendor();
    final otherVendorId = await vendors.addVendorWithRate(
      name: 'Shyam Dairy',
      milkType: 'buffalo',
      defaultQtyMl: 500,
      ratePerLitrePaise: 7000,
      effectiveFrom: DateTime(2025, 1, 1),
    );
    var emissions = 0;
    final subscription = vendors
        .watchVendorLedger(vendorId)
        .listen((_) => emissions++);

    await pumpEventQueue();
    expect(emissions, 1);
    await entries.saveEntry(
      vendorId: otherVendorId,
      date: DateTime(2025, 1, 2),
      quantityMl: 500,
      status: DailyEntryStatus.delivered,
    );
    await pumpEventQueue();
    expect(emissions, 1);
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 1, 2),
      quantityMl: 1000,
      status: DailyEntryStatus.delivered,
    );
    await pumpEventQueue();
    expect(emissions, 2);
    await subscription.cancel();
  });

  test('bulk marking upserts in one batch and keeps existing days', () async {
    final vendorId = await addVendor();
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 1, 3),
      quantityMl: 0,
      status: DailyEntryStatus.skipped,
    );
    final count = await entries.markUnmarkedDays(
      vendorId: vendorId,
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2025, 1, 5),
      defaultQtyMl: 1000,
      status: DailyEntryStatus.delivered,
    );
    final saved = await entries.getAllEntries(vendorId);

    expect(count, 4);
    expect(saved, hasLength(5));
    expect(
      saved.firstWhere((entry) => entry.date.day == 3).status,
      DailyEntryStatus.skipped,
    );
  });

  test('ledger stream re-emits after writes to any ledger table', () async {
    final vendorId = await addVendor();
    final emissions = <int>[];
    final subscription = vendors
        .watchVendorLedger(vendorId)
        .listen((ledger) => emissions.add(ledger!.entries.length));

    await pumpEventQueue();
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 1, 2),
      quantityMl: 1000,
      status: DailyEntryStatus.delivered,
    );
    await pumpEventQueue();
    await payments.addPayment(
      vendorId: vendorId,
      date: DateTime(2025, 1, 3),
      amountPaise: 1000,
      mode: PaymentMode.cash,
    );
    await pumpEventQueue();
    await subscription.cancel();

    expect(emissions.first, 0);
    expect(emissions.last, 1);
    expect(emissions.length, greaterThanOrEqualTo(3));
  });

  test('the only rate cannot be deleted, an extra one can', () async {
    final vendorId = await addVendor();
    expect(
      await vendors.deleteRate(
        vendorId: vendorId,
        effectiveFrom: DateTime(2025, 1, 1),
      ),
      isFalse,
    );
    await vendors.changeRate(
      vendorId: vendorId,
      ratePerLitrePaise: 7000,
      effectiveFrom: DateTime(2025, 3, 1),
    );
    expect(
      await vendors.deleteRate(
        vendorId: vendorId,
        effectiveFrom: DateTime(2025, 3, 1),
      ),
      isTrue,
    );
    expect(await vendors.getRateHistory(vendorId), hasLength(1));
  });

  test('holiday bulk marking skips only unmarked days', () async {
    final vendorId = await addVendor();
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 2, 2),
      quantityMl: 1500,
      status: DailyEntryStatus.custom,
    );
    final count = await entries.markUnmarkedDays(
      vendorId: vendorId,
      startDate: DateTime(2025, 2, 1),
      endDate: DateTime(2025, 2, 3),
      defaultQtyMl: 1000,
      status: DailyEntryStatus.skipped,
    );
    final saved = await entries.getEntriesForRange(
      vendorId,
      DateTime(2025, 2, 1),
      DateTime(2025, 2, 3),
    );

    expect(count, 2);
    expect(saved.map((entry) => entry.status), [
      DailyEntryStatus.skipped,
      DailyEntryStatus.custom,
      DailyEntryStatus.skipped,
    ]);
    expect(saved.first.quantityMl, 0);
  });

  test('archived vendors can be restored', () async {
    final vendorId = await addVendor();
    await vendors.archiveVendor(vendorId);
    expect(await vendors.getActiveVendors(), isEmpty);
    await vendors.restoreVendor(vendorId);
    expect((await vendors.getActiveVendors()).single.id, vendorId);
  });

  test(
    'monthly report builds six months of insights ending at the month',
    () async {
      final vendorId = await addVendor();
      await entries.saveEntry(
        vendorId: vendorId,
        date: DateTime(2025, 1, 10),
        quantityMl: 1000,
        status: DailyEntryStatus.delivered,
      );
      await entries.saveEntry(
        vendorId: vendorId,
        date: DateTime(2025, 6, 10),
        quantityMl: 2000,
        status: DailyEntryStatus.custom,
      );
      final ledger = await vendors.watchVendorLedger(vendorId).first;
      final report = buildMonthlyReport(ledger!, year: 2025, month: 6);

      expect(report.insights, hasLength(6));
      expect(report.insights.first.month, DateTime(2025, 1));
      expect(report.insights.last.month, DateTime(2025, 6));
      expect(report.insights.first.amountPaise, 6000);
      expect(report.insights.last.quantityMl, 2000);
      expect(report.entries, hasLength(1));
      expect(report.summary.carriedForwardPaise, 6000);
      expect(report.averageDailyMl, 2000);
    },
  );

  test('bulk entries walk calendar days across month ends', () {
    final drafts = buildBulkDeliveryEntries(
      startDate: DateTime(2025, 3, 29),
      endDate: DateTime(2025, 4, 1),
      defaultQtyMl: 500,
      rates: [
        MilkRate(effectiveFrom: DateTime(2025, 1, 1), ratePerLitrePaise: 6000),
      ],
      existingDates: const {},
    );
    expect(drafts.map((draft) => draft.date), [
      DateTime(2025, 3, 29),
      DateTime(2025, 3, 30),
      DateTime(2025, 3, 31),
      DateTime(2025, 4, 1),
    ]);
  });

  test('entry status follows the delivered quantity', () {
    expect(
      resolveEntryStatus(
        requested: DailyEntryStatus.delivered,
        quantityMl: 1000,
        defaultQtyMl: 1000,
      ),
      DailyEntryStatus.delivered,
    );
    expect(
      resolveEntryStatus(
        requested: DailyEntryStatus.delivered,
        quantityMl: 1500,
        defaultQtyMl: 1000,
      ),
      DailyEntryStatus.custom,
    );
    expect(
      resolveEntryStatus(
        requested: DailyEntryStatus.delivered,
        quantityMl: 0,
        defaultQtyMl: 1000,
      ),
      DailyEntryStatus.skipped,
    );
  });

  test('WhatsApp numbers are normalised for Indian phones', () {
    expect(whatsAppNumber('98765 43210'), '919876543210');
    expect(whatsAppNumber('09876543210'), '919876543210');
    expect(whatsAppNumber('+91 98765-43210'), '919876543210');
    expect(whatsAppNumber('12345'), isNull);
    expect(whatsAppNumber(null), isNull);
  });
}
