import 'package:drift/drift.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/data/database/tables.dart';

part 'ledger_dao.g.dart';

/// Everything needed to compute balances and reports for one vendor.
class VendorLedgerSnapshot {
  const VendorLedgerSnapshot({
    required this.vendor,
    required this.rates,
    required this.entries,
    required this.payments,
  });

  final Vendor vendor;

  /// Sorted by effective date, oldest first.
  final List<RateHistory> rates;

  /// Sorted by date, oldest first.
  final List<DailyEntry> entries;

  /// Sorted by date, oldest first.
  final List<Payment> payments;
}

@DriftAccessor(tables: [Vendors, RateHistories, DailyEntries, Payments])
class LedgerDao extends DatabaseAccessor<MilkDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.attachedDatabase);

  /// Emits a fresh snapshot of a vendor's ledger now and after every write to
  /// any ledger table, so every screen stays in sync without manual refreshes.
  /// Emits `null` when the vendor does not exist.
  Stream<VendorLedgerSnapshot?> watchVendorLedger(int vendorId) =>
      // A trivial query that drift re-runs whenever one of these tables
      // changes; each run triggers one fresh snapshot load.
      customSelect(
        'SELECT 1',
        readsFrom: {vendors, rateHistories, dailyEntries, payments},
      ).watch().asyncMap((_) => _loadVendorLedger(vendorId));

  Future<VendorLedgerSnapshot?> _loadVendorLedger(int vendorId) async {
    final vendor = await getVendor(vendorId);
    if (vendor == null) {
      return null;
    }
    final (rates, entries, payments) = await (
      getRateHistory(vendorId),
      getAllEntries(vendorId),
      getAllPayments(vendorId),
    ).wait;
    return VendorLedgerSnapshot(
      vendor: vendor,
      rates: rates,
      entries: entries,
      payments: payments,
    );
  }

  Stream<List<Vendor>> watchArchivedVendors() =>
      (select(vendors)
            ..where((vendor) => vendor.isActive.equals(false))
            ..orderBy([(vendor) => OrderingTerm.asc(vendor.name)]))
          .watch();

  Future<void> restoreVendor(int id) async {
    await (update(vendors)..where((vendor) => vendor.id.equals(id))).write(
      const VendorsCompanion(isActive: Value(true)),
    );
  }

  /// Deletes one rate. Refuses to delete the last remaining rate because
  /// every entry needs a rate to be priced.
  Future<bool> deleteRate(int vendorId, DateTime effectiveFrom) =>
      transaction(() async {
        final rates = await getRateHistory(vendorId);
        if (rates.length <= 1) {
          return false;
        }
        final removed =
            await (delete(rateHistories)..where(
                  (rate) =>
                      rate.vendorId.equals(vendorId) &
                      rate.effectiveFrom.equals(effectiveFrom),
                ))
                .go();
        return removed > 0;
      });

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

  Future<void> deleteVendor(int id) async {
    await (delete(vendors)..where((vendor) => vendor.id.equals(id))).go();
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

  Stream<List<({Payment payment, Vendor vendor})>> watchAllVendorPayments() =>
      (select(payments).join([
            innerJoin(vendors, vendors.id.equalsExp(payments.vendorId)),
          ])..orderBy([
            OrderingTerm.desc(payments.date),
            OrderingTerm.desc(payments.id),
          ]))
          .watch()
          .map(
            (rows) => [
              for (final row in rows)
                (
                  payment: row.readTable(payments),
                  vendor: row.readTable(vendors),
                ),
            ],
          );

  Future<int> insertPayment(PaymentsCompanion payment) =>
      into(payments).insert(payment);

  Future<bool> updatePayment(Payment payment) =>
      update(payments).replace(payment);

  Future<void> deletePayment(int id) async {
    await (delete(payments)..where((payment) => payment.id.equals(id))).go();
  }
}
