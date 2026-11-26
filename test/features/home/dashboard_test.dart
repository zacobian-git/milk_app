import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/data/daos/ledger_dao.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/features/home/presentation/home_screen.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';

void main() {
  final today = DateTime.now();
  final vendor = Vendor(
    id: 1,
    name: 'Mohan Dairy',
    milkType: 'cow',
    defaultQtyMl: 1000,
    openingBalancePaise: 0,
    isActive: true,
    createdAt: DateTime(2025),
  );
  final ledger = VendorLedgerSnapshot(
    vendor: vendor,
    rates: [
      RateHistory(
        id: 1,
        vendorId: 1,
        ratePerLitrePaise: 6000,
        effectiveFrom: DateTime(2025),
      ),
    ],
    entries: [
      DailyEntry(
        id: 1,
        vendorId: 1,
        date: DateTime(today.year, today.month),
        quantityMl: 2000,
        rateUsedPaise: 6000,
        status: DailyEntryStatus.delivered,
      ),
    ],
    payments: const [],
  );

  Future<void> pumpDashboard(WidgetTester tester, {required bool motion}) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeVendorsProvider.overrideWith((ref) => Stream.value([vendor])),
            vendorLedgerProvider.overrideWith(
              (ref, vendorId) => Stream.value(ledger),
            ),
          ],
          child: MediaQuery(
            data: MediaQueryData(disableAnimations: !motion),
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const HomeScreen(),
            ),
          ),
        ),
      );

  testWidgets('dashboard shows month totals, balance and vendor card', (
    tester,
  ) async {
    await pumpDashboard(tester, motion: false);
    await tester.pump();
    await tester.pump();

    expect(find.text('Mohan Dairy'), findsOneWidget);
    // 2 L at ₹60 = ₹120, shown as the hero total and on the vendor card.
    expect(find.text('₹120'), findsOneWidget);
    expect(find.text('₹120.00'), findsWidgets);
    expect(find.text('Total due'), findsOneWidget);
    expect(find.text('Quick actions'), findsNothing);
    expect(find.text('Add payment'), findsOneWidget);
  });

  testWidgets('dashboard animations settle when motion is enabled', (
    tester,
  ) async {
    await pumpDashboard(tester, motion: true);
    // The milk wave loops forever, so advance time instead of settling.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('₹120'), findsOneWidget);
  });
}
