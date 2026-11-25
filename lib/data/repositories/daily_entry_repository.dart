import 'package:drift/drift.dart';
import 'package:milk_app/data/daos/ledger_dao.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';

class DailyEntryRepository {
  const DailyEntryRepository(this._dao);

  final LedgerDao _dao;

  Future<List<DailyEntry>> getEntriesForRange(
    int vendorId,
    DateTime start,
    DateTime end,
  ) => _dao.getEntriesForRange(vendorId, dateOnly(start), dateOnly(end));

  Future<List<DailyEntry>> getAllEntries(int vendorId) =>
      _dao.getAllEntries(vendorId);

  Future<DailyEntry?> getEntryForDate(int vendorId, DateTime date) =>
      _dao.getEntryForDate(vendorId, dateOnly(date));

  Future<void> saveEntry({
    required int vendorId,
    required DateTime date,
    required int quantityMl,
    required DailyEntryStatus status,
    String? note,
  }) async {
    if (quantityMl < 0) {
      throw ArgumentError.value(quantityMl, 'quantityMl');
    }
    final entryDate = dateOnly(date);
    final rates = await _dao.getRateHistory(vendorId);
    final rate = rateForDate(
      rates.map(
        (item) => MilkRate(
          effectiveFrom: item.effectiveFrom,
          ratePerLitrePaise: item.ratePerLitrePaise,
        ),
      ),
      entryDate,
    );
    if (rate == null) {
      throw StateError('No milk rate is configured for this date.');
    }
    await _dao.saveEntry(
      DailyEntriesCompanion.insert(
        vendorId: vendorId,
        date: entryDate,
        quantityMl: status == DailyEntryStatus.skipped ? 0 : quantityMl,
        rateUsedPaise: rate,
        status: status,
        note: Value(note),
      ),
    );
  }

  Future<void> deleteEntry(int id) => _dao.deleteEntry(id);

  Future<void> undoEntryChange({
    required int vendorId,
    required DateTime date,
    required DailyEntry? previousEntry,
  }) async {
    if (previousEntry == null) {
      await _dao.deleteEntryForDate(vendorId, dateOnly(date));
      return;
    }
    await _dao.saveEntry(
      DailyEntriesCompanion.insert(
        id: Value(previousEntry.id),
        vendorId: previousEntry.vendorId,
        date: previousEntry.date,
        quantityMl: previousEntry.quantityMl,
        rateUsedPaise: previousEntry.rateUsedPaise,
        status: previousEntry.status,
        note: Value(previousEntry.note),
      ),
    );
  }

  Future<int> markUnmarkedAsDelivered({
    required int vendorId,
    required DateTime startDate,
    required DateTime endDate,
    required int defaultQtyMl,
  }) => markUnmarkedDays(
    vendorId: vendorId,
    startDate: startDate,
    endDate: endDate,
    defaultQtyMl: defaultQtyMl,
    status: DailyEntryStatus.delivered,
  );

  /// Fills every unmarked day in the range with [status]. Days that already
  /// have an entry are left untouched. Returns the number of days written.
  Future<int> markUnmarkedDays({
    required int vendorId,
    required DateTime startDate,
    required DateTime endDate,
    required int defaultQtyMl,
    required DailyEntryStatus status,
  }) async {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);
    final existingEntries = await _dao.getEntriesForRange(vendorId, start, end);
    final rates = await _dao.getRateHistory(vendorId);
    final drafts = buildBulkDeliveryEntries(
      startDate: start,
      endDate: end,
      defaultQtyMl: defaultQtyMl,
      rates: rates
          .map(
            (rate) => MilkRate(
              effectiveFrom: rate.effectiveFrom,
              ratePerLitrePaise: rate.ratePerLitrePaise,
            ),
          )
          .toList(growable: false),
      existingDates: existingEntries.map((entry) => entry.date).toSet(),
      status: status,
    );
    await _dao.saveEntries(
      drafts
          .map(
            (draft) => DailyEntriesCompanion.insert(
              vendorId: vendorId,
              date: draft.date,
              quantityMl: draft.quantityMl,
              rateUsedPaise: draft.rateUsedPaise,
              status: draft.status,
            ),
          )
          .toList(growable: false),
    );
    return drafts.length;
  }
}
