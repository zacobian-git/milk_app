// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_dao.dart';

// ignore_for_file: type=lint
mixin _$LedgerDaoMixin on DatabaseAccessor<MilkDatabase> {
  $VendorsTable get vendors => attachedDatabase.vendors;
  $RateHistoriesTable get rateHistories => attachedDatabase.rateHistories;
  $DailyEntriesTable get dailyEntries => attachedDatabase.dailyEntries;
  $PaymentsTable get payments => attachedDatabase.payments;
  LedgerDaoManager get managers => LedgerDaoManager(this);
}

class LedgerDaoManager {
  final _$LedgerDaoMixin _db;
  LedgerDaoManager(this._db);
  $$VendorsTableTableManager get vendors =>
      $$VendorsTableTableManager(_db.attachedDatabase, _db.vendors);
  $$RateHistoriesTableTableManager get rateHistories =>
      $$RateHistoriesTableTableManager(_db.attachedDatabase, _db.rateHistories);
  $$DailyEntriesTableTableManager get dailyEntries =>
      $$DailyEntriesTableTableManager(_db.attachedDatabase, _db.dailyEntries);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db.attachedDatabase, _db.payments);
}
