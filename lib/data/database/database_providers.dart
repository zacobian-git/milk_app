import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milk_app/data/daos/ledger_dao.dart';
import 'package:milk_app/data/database/database_connection.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/data/repositories/daily_entry_repository.dart';
import 'package:milk_app/data/repositories/payment_repository.dart';
import 'package:milk_app/data/repositories/vendor_repository.dart';

final milkDatabaseProvider = Provider<MilkDatabase>((ref) {
  final database = openMilkDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final ledgerDaoProvider = Provider<LedgerDao>(
  (ref) => ref.watch(milkDatabaseProvider).ledgerDao,
);

final vendorRepositoryProvider = Provider<VendorRepository>(
  (ref) => VendorRepository(ref.watch(ledgerDaoProvider)),
);

final dailyEntryRepositoryProvider = Provider<DailyEntryRepository>(
  (ref) => DailyEntryRepository(ref.watch(ledgerDaoProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(ref.watch(ledgerDaoProvider)),
);
