import 'package:drift/drift.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/data/database/tables.dart';

part 'ledger_dao.g.dart';

@DriftAccessor(tables: [Vendors, RateHistories, DailyEntries, Payments])
class LedgerDao extends DatabaseAccessor<MilkDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.attachedDatabase);

  Future<List<Vendor>> getActiveVendors() =>
      (select(vendors)
            ..where((vendor) => vendor.isActive.equals(true))
            ..orderBy([(vendor) => OrderingTerm.asc(vendor.name)]))
          .get();

  Stream<List<Vendor>> watchActiveVendors() =>
      (select(vendors)
            ..where((vendor) => vendor.isActive.equals(true))
            ..orderBy([(vendor) => OrderingTerm.asc(vendor.name)]))
          .watch();

  Future<Vendor?> getVendor(int id) => (select(
    vendors,
  )..where((vendor) => vendor.id.equals(id))).getSingleOrNull();

  Future<int> insertVendor(VendorsCompanion vendor) =>
      into(vendors).insert(vendor);

  Future<int> insertVendorWithRate({
    required VendorsCompanion vendor,
    required int ratePerLitrePaise,
    required DateTime effectiveFrom,
  }) => transaction(() async {
    final vendorId = await into(vendors).insert(vendor);
    await into(rateHistories).insert(
      RateHistoriesCompanion.insert(
        vendorId: vendorId,
        ratePerLitrePaise: ratePerLitrePaise,
        effectiveFrom: effectiveFrom,
      ),
    );
    return vendorId;
  });

  Future<bool> updateVendor(Vendor vendor) => update(vendors).replace(vendor);

  Future<void> archiveVendor(int id) async {
    await (update(vendors)..where((vendor) => vendor.id.equals(id))).write(
      const VendorsCompanion(isActive: Value(false)),
    );
  }

  Future<List<RateHistory>> getRateHistory(int vendorId) =>
      (select(rateHistories)
            ..where((rate) => rate.vendorId.equals(vendorId))
            ..orderBy([(rate) => OrderingTerm.asc(rate.effectiveFrom)]))
          .get();

  Future<void> saveRate(RateHistoriesCompanion rate) async {
    await transaction(() async {
      final existing =
          await (select(rateHistories)..where(
                (item) =>
                    item.vendorId.equals(rate.vendorId.value) &
                    item.effectiveFrom.equals(rate.effectiveFrom.value),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await into(rateHistories).insert(rate);
      } else {
        await (update(
          rateHistories,
        )..where((item) => item.id.equals(existing.id))).write(rate);
      }
    });
  }

  Future<List<DailyEntry>> getEntriesForRange(
    int vendorId,
    DateTime start,
    DateTime end,
  ) =>
      (select(dailyEntries)
            ..where(
              (entry) =>
                  entry.vendorId.equals(vendorId) &
                  entry.date.isBetweenValues(start, end),
            )
            ..orderBy([(entry) => OrderingTerm.asc(entry.date)]))
          .get();

  Future<List<DailyEntry>> getAllEntries(int vendorId) =>
      (select(dailyEntries)
            ..where((entry) => entry.vendorId.equals(vendorId))
            ..orderBy([(entry) => OrderingTerm.asc(entry.date)]))
          .get();

  Future<DailyEntry?> getEntryForDate(int vendorId, DateTime date) =>
      (select(dailyEntries)..where(
            (entry) =>
                entry.vendorId.equals(vendorId) & entry.date.equals(date),
          ))
          .getSingleOrNull();

  Future<void> saveEntry(DailyEntriesCompanion entry) async {
    await transaction(() => _saveEntry(entry));
  }

  Future<void> saveEntries(List<DailyEntriesCompanion> entries) async {
    await transaction(() async {
      for (final entry in entries) {
        await _saveEntry(entry);
      }
    });
  }

  Future<void> _saveEntry(DailyEntriesCompanion entry) async {
    final existing =
        await (select(dailyEntries)..where(
              (item) =>
                  item.vendorId.equals(entry.vendorId.value) &
                  item.date.equals(entry.date.value),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await into(dailyEntries).insert(entry);
    } else {
      await (update(
        dailyEntries,
      )..where((item) => item.id.equals(existing.id))).write(entry);
    }
  }

  Future<void> deleteEntry(int id) async {
    await (delete(dailyEntries)..where((entry) => entry.id.equals(id))).go();
  }

  Future<void> deleteEntryForDate(int vendorId, DateTime date) async {
    await (delete(dailyEntries)..where(
          (entry) => entry.vendorId.equals(vendorId) & entry.date.equals(date),
        ))
        .go();
  }

  Future<List<Payment>> getPayments(int vendorId) =>
      (select(payments)
            ..where((payment) => payment.vendorId.equals(vendorId))
            ..orderBy([(payment) => OrderingTerm.asc(payment.date)]))
          .get();

  Future<List<Payment>> getAllPayments(int vendorId) =>
      (select(payments)
            ..where((payment) => payment.vendorId.equals(vendorId))
            ..orderBy([(payment) => OrderingTerm.asc(payment.date)]))
          .get();

  Future<int> insertPayment(PaymentsCompanion payment) =>
      into(payments).insert(payment);

  Future<bool> updatePayment(Payment payment) =>
      update(payments).replace(payment);

  Future<void> deletePayment(int id) async {
    await (delete(payments)..where((payment) => payment.id.equals(id))).go();
  }
}
