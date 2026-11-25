import 'package:drift/drift.dart';
import 'package:milk_app/data/daos/ledger_dao.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';

class VendorRepository {
  const VendorRepository(this._dao);

  final LedgerDao _dao;

  Future<List<Vendor>> getActiveVendors() => _dao.getActiveVendors();

  Stream<List<Vendor>> watchActiveVendors() => _dao.watchActiveVendors();

  Future<Vendor?> getVendor(int id) => _dao.getVendor(id);

  Future<int> addVendor({
    required String name,
    required String milkType,
    required int defaultQtyMl,
    String? phone,
    String? deliveryTime,
    String? notes,
    int openingBalancePaise = 0,
  }) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Vendor name cannot be empty.');
    }
    if (defaultQtyMl < 0) {
      throw ArgumentError.value(defaultQtyMl, 'defaultQtyMl');
    }
    return _dao.insertVendor(
      VendorsCompanion.insert(
        name: normalizedName,
        milkType: milkType,
        defaultQtyMl: defaultQtyMl,
        phone: Value(phone),
        deliveryTime: Value(deliveryTime),
        notes: Value(notes),
        openingBalancePaise: Value(openingBalancePaise),
      ),
    );
  }

  Future<int> addVendorWithRate({
    required String name,
    required String milkType,
    required int defaultQtyMl,
    required int ratePerLitrePaise,
    required DateTime effectiveFrom,
    String? phone,
    String? deliveryTime,
    String? notes,
    int openingBalancePaise = 0,
  }) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Vendor name cannot be empty.');
    }
    if (defaultQtyMl < 0 || ratePerLitrePaise < 0) {
      throw ArgumentError('Quantity and rate must not be negative.');
    }
    return _dao.insertVendorWithRate(
      vendor: VendorsCompanion.insert(
        name: normalizedName,
        milkType: milkType,
        defaultQtyMl: defaultQtyMl,
        phone: Value(phone),
        deliveryTime: Value(deliveryTime),
        notes: Value(notes),
        openingBalancePaise: Value(openingBalancePaise),
      ),
      ratePerLitrePaise: ratePerLitrePaise,
      effectiveFrom: dateOnly(effectiveFrom),
    );
  }

  Future<bool> updateVendor(Vendor vendor) => _dao.updateVendor(vendor);

  Future<void> archiveVendor(int id) => _dao.archiveVendor(id);

  Future<List<MilkRate>> getRateHistory(int vendorId) async {
    final history = await _dao.getRateHistory(vendorId);
    return history
        .map(
          (rate) => MilkRate(
            effectiveFrom: rate.effectiveFrom,
            ratePerLitrePaise: rate.ratePerLitrePaise,
          ),
        )
        .toList(growable: false);
  }

  Future<void> changeRate({
    required int vendorId,
    required int ratePerLitrePaise,
    required DateTime effectiveFrom,
  }) {
    if (ratePerLitrePaise < 0) {
      throw ArgumentError.value(ratePerLitrePaise, 'ratePerLitrePaise');
    }
    return _dao.saveRate(
      RateHistoriesCompanion.insert(
        vendorId: vendorId,
        ratePerLitrePaise: ratePerLitrePaise,
        effectiveFrom: dateOnly(effectiveFrom),
      ),
    );
  }
}
