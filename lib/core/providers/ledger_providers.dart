import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';

final activeVendorsProvider = StreamProvider<List<Vendor>>(
  (ref) => ref.watch(vendorRepositoryProvider).watchActiveVendors(),
);
