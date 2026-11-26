import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _finishStartup(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows branded loading screen during app startup', (
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
    await tester.pump();

    expect(find.text('दूध हिसाब'), findsOneWidget);
    expect(find.textContaining('घर के दूध का ऑफ़लाइन हिसाब'), findsOneWidget);

    await _finishStartup(tester);
    expect(
      find.textContaining('शुरू करने के लिए अपना दूधवाला जोड़ें'),
      findsOneWidget,
    );
  });

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
    await _finishStartup(tester);

    expect(find.text('दूध हिसाब'), findsOneWidget);
    expect(find.textContaining('दूध का साफ़ और आसान हिसाब'), findsOneWidget);
    expect(
      find.textContaining('शुरू करने के लिए अपना दूधवाला जोड़ें'),
      findsOneWidget,
    );
  });

  testWidgets('asks before closing when back is pressed on home', (
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
    await _finishStartup(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('ऐप बंद करें'), findsOneWidget);
    expect(find.text('क्या आप वाकई ऐप बंद करना चाहते हैं?'), findsOneWidget);

    await tester.tap(find.text('रद्द करें'));
    await tester.pumpAndSettle();

    expect(find.text('ऐप बंद करें'), findsNothing);
  });
}
