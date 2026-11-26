import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';

final allVendorPaymentsProvider =
    StreamProvider<List<({Payment payment, Vendor vendor})>>(
      (ref) => ref.watch(paymentRepositoryProvider).watchAllVendorPayments(),
    );

/// All payments for a vendor, newest first.
final paymentsProvider = Provider.family<AsyncValue<List<Payment>>, int>(
  (ref, vendorId) => ref
      .watch(vendorLedgerProvider(vendorId))
      .whenData((ledger) => ledger.payments.reversed.toList(growable: false)),
);
