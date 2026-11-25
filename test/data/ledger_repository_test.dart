import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/data/repositories/daily_entry_repository.dart';
import 'package:milk_app/data/repositories/payment_repository.dart';
import 'package:milk_app/data/repositories/vendor_repository.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';

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

  test('creates schema and stores dated entries with rate snapshots', () async {
    final vendorId = await vendors.addVendor(
      name: '  Mohan Dairy  ',
      milkType: 'cow',
      defaultQtyMl: 1000,
      openingBalancePaise: 500,
    );
    await vendors.changeRate(
      vendorId: vendorId,
      ratePerLitrePaise: 8000,
      effectiveFrom: DateTime(2025, 6, 1),
    );
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 6, 14, 8),
      quantityMl: 1000,
      status: DailyEntryStatus.delivered,
    );

    await vendors.changeRate(
      vendorId: vendorId,
      ratePerLitrePaise: 10000,
      effectiveFrom: DateTime(2025, 6, 15),
    );
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 6, 15, 8),
      quantityMl: 1000,
      status: DailyEntryStatus.delivered,
    );

    final storedEntries = await entries.getEntriesForRange(
      vendorId,
      DateTime(2025, 6, 1),
      DateTime(2025, 6, 30),
    );
    expect(await vendors.getVendor(vendorId), isNotNull);
    expect(storedEntries.map((entry) => entry.rateUsedPaise), [8000, 10000]);
    expect(storedEntries.map((entry) => entry.date.day), [14, 15]);
    expect((await vendors.getRateHistory(vendorId)).length, 2);
  });

  test('upserts duplicate vendor dates and persists payments', () async {
    final vendorId = await vendors.addVendor(
      name: 'Mohan Dairy',
      milkType: 'cow',
      defaultQtyMl: 1000,
    );
    await vendors.changeRate(
      vendorId: vendorId,
      ratePerLitrePaise: 9000,
      effectiveFrom: DateTime(2025, 6, 1),
    );
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 6, 10),
      quantityMl: 1000,
      status: DailyEntryStatus.delivered,
    );
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 6, 10, 18),
      quantityMl: 750,
      status: DailyEntryStatus.custom,
      note: 'Changed quantity',
    );
    await payments.addPayment(
      vendorId: vendorId,
      date: DateTime(2025, 6, 12, 12),
      amountPaise: 5000,
      mode: PaymentMode.upi,
    );

    final storedEntries = await entries.getEntriesForRange(
      vendorId,
      DateTime(2025, 6, 10),
      DateTime(2025, 6, 10),
    );
    final storedPayments = await payments.getPayments(vendorId);
    expect(storedEntries, hasLength(1));
    expect(storedEntries.single.quantityMl, 750);
    expect(storedEntries.single.note, 'Changed quantity');
    expect(storedPayments.single.amountPaise, 5000);
    expect(storedPayments.single.mode, PaymentMode.upi);
  });

  test('deleting a vendor archives it and preserves ledger history', () async {
    final vendorId = await vendors.addVendor(
      name: 'Mohan Dairy',
      milkType: 'cow',
      defaultQtyMl: 1000,
    );
    await vendors.changeRate(
      vendorId: vendorId,
      ratePerLitrePaise: 9000,
      effectiveFrom: DateTime(2025, 6, 1),
    );
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 6, 10),
      quantityMl: 1000,
      status: DailyEntryStatus.delivered,
    );

    await vendors.archiveVendor(vendorId);

    expect(await vendors.getActiveVendors(), isEmpty);
    expect((await vendors.getVendor(vendorId))?.isActive, isFalse);
    expect(
      (await entries.getEntriesForRange(
        vendorId,
        DateTime(2025, 6, 1),
        DateTime(2025, 6, 30),
      )),
      hasLength(1),
    );
    expect(await vendors.getRateHistory(vendorId), hasLength(1));
  });

  test('backup restores vendors, rate history, entries and payments', () async {
    final vendorId = await vendors.addVendor(
      name: 'Mohan Dairy',
      milkType: 'buffalo',
      defaultQtyMl: 1500,
      openingBalancePaise: 1200,
      phone: '9876543210',
    );
    await vendors.changeRate(
      vendorId: vendorId,
      ratePerLitrePaise: 10000,
      effectiveFrom: DateTime(2025, 6, 1),
    );
    await entries.saveEntry(
      vendorId: vendorId,
      date: DateTime(2025, 6, 2),
      quantityMl: 1500,
      status: DailyEntryStatus.custom,
      note: 'Extra milk',
    );
    await payments.addPayment(
      vendorId: vendorId,
      date: DateTime(2025, 6, 3),
      amountPaise: 5000,
      mode: PaymentMode.upi,
      note: 'PhonePe',
    );

    await database.restoreJson(await database.exportJson());

    expect((await vendors.getVendor(vendorId))?.phone, '9876543210');
    expect(
      (await vendors.getRateHistory(vendorId)).single.ratePerLitrePaise,
      10000,
    );
    expect(
      (await entries.getEntriesForRange(
        vendorId,
        DateTime(2025, 6, 1),
        DateTime(2025, 6, 30),
      )).single.note,
      'Extra milk',
    );
    expect((await payments.getPayments(vendorId)).single.amountPaise, 5000);
  });

  test('rejects invalid backups without changing the ledger', () async {
    final vendorId = await vendors.addVendor(
      name: 'Mohan Dairy',
      milkType: 'cow',
      defaultQtyMl: 1000,
    );

    await expectLater(
      database.restoreJson(
        jsonEncode({
          'schemaVersion': 1,
          'vendors': [
            {'id': 5},
          ],
          'rateHistory': [],
          'dailyEntries': [],
          'payments': [],
        }),
      ),
      throwsFormatException,
    );
    expect(await vendors.getVendor(vendorId), isNotNull);
  });
}
