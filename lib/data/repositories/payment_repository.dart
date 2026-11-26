import 'package:drift/drift.dart';
import 'package:milk_app/data/daos/ledger_dao.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';

class PaymentRepository {
  const PaymentRepository(this._dao);

  final LedgerDao _dao;

  Future<List<Payment>> getPayments(int vendorId) => _dao.getPayments(vendorId);

  Future<List<Payment>> getAllPayments(int vendorId) =>
      _dao.getAllPayments(vendorId);

  Stream<List<({Payment payment, Vendor vendor})>> watchAllVendorPayments() =>
      _dao.watchAllVendorPayments();

  Future<int> addPayment({
    required int vendorId,
    required DateTime date,
    required int amountPaise,
    required PaymentMode mode,
    String? note,
  }) {
    if (amountPaise <= 0) {
      throw ArgumentError.value(amountPaise, 'amountPaise');
    }
    return _dao.insertPayment(
      PaymentsCompanion.insert(
        vendorId: vendorId,
        date: dateOnly(date),
        amountPaise: amountPaise,
        mode: mode,
        note: Value(note),
      ),
    );
  }

  Future<bool> updatePayment(Payment payment) {
    if (payment.amountPaise <= 0) {
      throw ArgumentError.value(payment.amountPaise, 'amountPaise');
    }
    return _dao.updatePayment(payment);
  }

  Future<int> restorePayment(Payment payment) => _dao.insertPayment(
    PaymentsCompanion.insert(
      id: Value(payment.id),
      vendorId: payment.vendorId,
      date: payment.date,
      amountPaise: payment.amountPaise,
      mode: payment.mode,
      note: Value(payment.note),
    ),
  );

  Future<void> deletePayment(int id) => _dao.deletePayment(id);
}
