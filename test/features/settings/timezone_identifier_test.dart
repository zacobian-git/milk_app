import 'package:flutter_test/flutter_test.dart';
import 'package:milk_app/features/settings/application/timezone_identifier.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('maps the Android Calcutta alias to the bundled Kolkata timezone', () {
    tz_data.initializeTimeZones();

    final identifier = timezoneDatabaseIdentifier('Asia/Calcutta');

    expect(identifier, 'Asia/Kolkata');
    expect(tz.getLocation(identifier).name, 'Asia/Kolkata');
  });

  test('preserves timezone identifiers without a known alias', () {
    expect(
      timezoneDatabaseIdentifier('America/Los_Angeles'),
      'America/Los_Angeles',
    );
  });
}
