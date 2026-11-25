import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:milk_app/data/daos/ledger_dao.dart';
import 'package:milk_app/data/database/tables.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';

part 'milk_database.g.dart';

@DriftDatabase(
  tables: [Vendors, RateHistories, DailyEntries, Payments],
  daos: [LedgerDao],
)
class MilkDatabase extends _$MilkDatabase {
  MilkDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 1) {
        await migrator.createAll();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<String> exportJson() async {
    final vendorRows = await select(vendors).get();
    final rateRows = await select(rateHistories).get();
    final entryRows = await select(dailyEntries).get();
    final paymentRows = await select(payments).get();
    return jsonEncode({
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'vendors': [
        for (final vendor in vendorRows)
          {
            'id': vendor.id,
            'name': vendor.name,
            'phone': vendor.phone,
            'milkType': vendor.milkType,
            'defaultQtyMl': vendor.defaultQtyMl,
            'deliveryTime': vendor.deliveryTime,
            'notes': vendor.notes,
            'openingBalancePaise': vendor.openingBalancePaise,
            'isActive': vendor.isActive,
            'createdAt': vendor.createdAt.toIso8601String(),
          },
      ],
      'rateHistory': [
        for (final rate in rateRows)
          {
            'id': rate.id,
            'vendorId': rate.vendorId,
            'ratePerLitrePaise': rate.ratePerLitrePaise,
            'effectiveFrom': rate.effectiveFrom.toIso8601String(),
          },
      ],
      'dailyEntries': [
        for (final entry in entryRows)
          {
            'id': entry.id,
            'vendorId': entry.vendorId,
            'date': entry.date.toIso8601String(),
            'quantityMl': entry.quantityMl,
            'rateUsedPaise': entry.rateUsedPaise,
            'status': entry.status.name,
            'note': entry.note,
          },
      ],
      'payments': [
        for (final payment in paymentRows)
          {
            'id': payment.id,
            'vendorId': payment.vendorId,
            'date': payment.date.toIso8601String(),
            'amountPaise': payment.amountPaise,
            'mode': payment.mode.name,
            'note': payment.note,
          },
      ],
    });
  }

  Future<void> restoreJson(String source) async {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> ||
        decoded['schemaVersion'] != schemaVersion) {
      throw const FormatException('Unsupported backup format.');
    }
    final backupVendors = _readRows(decoded, 'vendors');
    final backupRates = _readRows(decoded, 'rateHistory');
    final backupEntries = _readRows(decoded, 'dailyEntries');
    final backupPayments = _readRows(decoded, 'payments');

    await transaction(() async {
      await delete(payments).go();
      await delete(dailyEntries).go();
      await delete(rateHistories).go();
      await delete(vendors).go();

      for (final row in backupVendors) {
        await into(vendors).insert(
          VendorsCompanion.insert(
            id: Value(_readInt(row, 'id')),
            name: _readString(row, 'name'),
            phone: Value(_readNullableString(row, 'phone')),
            milkType: _readString(row, 'milkType'),
            defaultQtyMl: _readInt(row, 'defaultQtyMl'),
            deliveryTime: Value(_readNullableString(row, 'deliveryTime')),
            notes: Value(_readNullableString(row, 'notes')),
            openingBalancePaise: Value(_readInt(row, 'openingBalancePaise')),
            isActive: Value(_readBool(row, 'isActive')),
            createdAt: Value(_readDate(row, 'createdAt')),
          ),
        );
      }
      for (final row in backupRates) {
        await into(rateHistories).insert(
          RateHistoriesCompanion.insert(
            id: Value(_readInt(row, 'id')),
            vendorId: _readInt(row, 'vendorId'),
            ratePerLitrePaise: _readInt(row, 'ratePerLitrePaise'),
            effectiveFrom: _readDate(row, 'effectiveFrom'),
          ),
        );
      }
      for (final row in backupEntries) {
        await into(dailyEntries).insert(
          DailyEntriesCompanion.insert(
            id: Value(_readInt(row, 'id')),
            vendorId: _readInt(row, 'vendorId'),
            date: _readDate(row, 'date'),
            quantityMl: _readInt(row, 'quantityMl'),
            rateUsedPaise: _readInt(row, 'rateUsedPaise'),
            status: DailyEntryStatus.values.byName(_readString(row, 'status')),
            note: Value(_readNullableString(row, 'note')),
          ),
        );
      }
      for (final row in backupPayments) {
        await into(payments).insert(
          PaymentsCompanion.insert(
            id: Value(_readInt(row, 'id')),
            vendorId: _readInt(row, 'vendorId'),
            date: _readDate(row, 'date'),
            amountPaise: _readInt(row, 'amountPaise'),
            mode: PaymentMode.values.byName(_readString(row, 'mode')),
            note: Value(_readNullableString(row, 'note')),
          ),
        );
      }
    });
  }
}

MilkDatabase createInMemoryDatabase() => MilkDatabase(NativeDatabase.memory());

List<Map<String, dynamic>> _readRows(Map<String, dynamic> backup, String key) {
  final rows = backup[key];
  if (rows is! List) {
    throw FormatException('The backup is missing "$key".');
  }
  return rows
      .map((row) {
        if (row is! Map<String, dynamic>) {
          throw FormatException('The "$key" table contains an invalid row.');
        }
        return row;
      })
      .toList(growable: false);
}

int _readInt(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is! int) {
    throw FormatException('The backup field "$key" must be an integer.');
  }
  return value;
}

String _readString(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is! String) {
    throw FormatException('The backup field "$key" must be text.');
  }
  return value;
}

String? _readNullableString(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value != null && value is! String) {
    throw FormatException('The backup field "$key" must be text or null.');
  }
  return value as String?;
}

bool _readBool(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is! bool) {
    throw FormatException('The backup field "$key" must be a boolean.');
  }
  return value;
}

DateTime _readDate(Map<String, dynamic> row, String key) {
  final value = _readString(row, key);
  try {
    return DateTime.parse(value);
  } on FormatException {
    throw FormatException('The backup field "$key" must be an ISO date.');
  }
}
