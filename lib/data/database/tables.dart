import 'package:drift/drift.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';

class Vendors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get milkType => text()();
  IntColumn get defaultQtyMl => integer()();
  TextColumn get deliveryTime => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get openingBalancePaise =>
      integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}

@TableIndex(
  name: 'rate_histories_vendor_effective_from',
  columns: {#vendorId, #effectiveFrom},
  unique: true,
)
class RateHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vendorId =>
      integer().references(Vendors, #id, onDelete: KeyAction.cascade)();
  IntColumn get ratePerLitrePaise => integer()();
  DateTimeColumn get effectiveFrom => dateTime()();
}

@TableIndex(
  name: 'daily_entries_vendor_date',
  columns: {#vendorId, #date},
  unique: true,
)
class DailyEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vendorId =>
      integer().references(Vendors, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  IntColumn get quantityMl => integer()();
  IntColumn get rateUsedPaise => integer()();
  TextColumn get status => textEnum<DailyEntryStatus>()();
  TextColumn get note => text().nullable()();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vendorId =>
      integer().references(Vendors, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  IntColumn get amountPaise => integer()();
  TextColumn get mode => textEnum<PaymentMode>()();
  TextColumn get note => text().nullable()();
}
