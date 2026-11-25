import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('starts in Hindi with the Doodh Hisaab welcome shell', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeVendorsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const DoodhHisaabApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('दूध हिसाब'), findsOneWidget);
    expect(find.textContaining('दूध का साफ़ और आसान हिसाब'), findsOneWidget);
    expect(
      find.textContaining('शुरू करने के लिए अपना दूधवाला जोड़ें'),
      findsOneWidget,
    );
  });
}
