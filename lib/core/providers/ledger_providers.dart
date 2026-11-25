import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';

final activeVendorsProvider = StreamProvider<List<Vendor>>(
  (ref) => ref.watch(vendorRepositoryProvider).watchActiveVendors(),
);

final archivedVendorsProvider = StreamProvider<List<Vendor>>(
  (ref) => ref.watch(vendorRepositoryProvider).watchArchivedVendors(),
);

/// The vendor chosen on the Calendar, Payments and Reports tabs. Shared so
/// that switching tabs keeps the same vendor in view.
final selectedVendorIdProvider =
    NotifierProvider<SelectedVendorController, int?>(
      SelectedVendorController.new,
    );

class SelectedVendorController extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int vendorId) => state = vendorId;
}

/// Resolves the selected vendor against the current list, falling back to the
/// first vendor when nothing (or an archived vendor) is selected.
Vendor resolveSelectedVendor(List<Vendor> vendors, int? selectedId) {
  for (final vendor in vendors) {
    if (vendor.id == selectedId) {
      return vendor;
    }
  }
  return vendors.first;
}
