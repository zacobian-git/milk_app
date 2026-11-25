import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/features/reports/data/bill_pdf_service.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations_hi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a Hindi PDF bill using the bundled Devanagari font', () async {
    await initializeDateFormatting('hi');
    final report = MonthlyReportData(
      vendor: Vendor(
        id: 1,
        name: 'रमेश डेयरी',
        milkType: 'cow',
        defaultQtyMl: 1000,
        openingBalancePaise: 0,
        isActive: true,
        createdAt: DateTime(2025, 6, 1),
      ),
      summary: const MonthlySummary(
        totalQuantityMl: 1000,
        totalAmountPaise: 8000,
        deliveredDays: 1,
        skippedDays: 0,
        paidPaise: 0,
        carriedForwardPaise: 0,
        closingBalancePaise: 8000,
      ),
      year: 2025,
      month: 6,
      entries: const [],
      payments: const [],
      insights: const [],
    );

    final bytes = await const BillPdfService().buildBill(
      report,
      AppLocalizationsHi(),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
