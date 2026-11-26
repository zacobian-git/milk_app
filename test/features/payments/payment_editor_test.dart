import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/data/repositories/payment_repository.dart';
import 'package:milk_app/data/repositories/vendor_repository.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/features/payments/data/payments_provider.dart';
import 'package:milk_app/features/payments/presentation/payments_screen.dart';
import 'package:milk_app/l10n/app_localizations.dart';

void main() {
  late MilkDatabase database;
  late int firstVendorId;
  late int secondVendorId;

  setUp(() async {
    database = createInMemoryDatabase();
    final vendors = VendorRepository(database.ledgerDao);
    firstVendorId = await vendors.addVendor(
      name: 'A Dairy',
      milkType: 'cow',
      defaultQtyMl: 1000,
    );
    secondVendorId = await vendors.addVendor(
      name: 'B Dairy',
      milkType: 'buffalo',
      defaultQtyMl: 1500,
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('new payment is saved to the vendor selected in the form', (
    tester,
  ) async {
    await initializeDateFormatting('en');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [milkDatabaseProvider.overrideWith((ref) => database)],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => Material(
                      child: PaymentEditorSheet(
                        vendorId: firstVendorId,
                        fullBalancePaise: 0,
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B Dairy').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '15');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(await database.ledgerDao.getAllPayments(firstVendorId), isEmpty);
    final payments = await database.ledgerDao.getAllPayments(secondVendorId);
    expect(payments, hasLength(1));
    expect(payments.single.amountPaise, 1500);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('payment screen lists payments from every vendor', (
    tester,
  ) async {
    await initializeDateFormatting('en');
    final payments = PaymentRepository(database.ledgerDao);
    await payments.addPayment(
      vendorId: firstVendorId,
      date: DateTime(2025, 6, 10),
      amountPaise: 1500,
      mode: PaymentMode.cash,
    );
    await payments.addPayment(
      vendorId: secondVendorId,
      date: DateTime(2025, 6, 12),
      amountPaise: 2500,
      mode: PaymentMode.upi,
    );
    final container = ProviderContainer(
      overrides: [milkDatabaseProvider.overrideWith((ref) => database)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const PaymentsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(allVendorPaymentsProvider).value, hasLength(2));
    expect(find.text('Payment history'), findsOneWidget);
    expect(find.textContaining('A Dairy'), findsWidgets);
    expect(find.text('No payments recorded yet.'), findsNothing);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
    await tester.scrollUntilVisible(find.textContaining('B Dairy'), 300);
    await tester.pumpAndSettle();
    expect(find.textContaining('B Dairy'), findsOneWidget);
    expect(find.text('No payments recorded yet.'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(milliseconds: 1));
  });
}
