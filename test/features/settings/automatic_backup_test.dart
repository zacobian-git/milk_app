import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milk_app/features/settings/application/app_settings_provider.dart';
import 'package:milk_app/features/settings/application/automatic_backup_settings.dart';
import 'package:milk_app/features/settings/data/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'automatic backup settings persist with the selected schedule',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = await container.read(appSettingsProvider.future);
      expect(initial.automaticBackupEnabled, isFalse);
      expect(initial.automaticBackupHour, 20);
      expect(initial.automaticBackupMinute, 0);

      await container
          .read(appSettingsProvider.notifier)
          .setAutomaticBackup(
            enabled: true,
            frequency: AutomaticBackupFrequency.weekly,
            hour: 21,
            minute: 30,
          );

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getBool(AutomaticBackupPreferences.enabledKey),
        isTrue,
      );
      expect(
        preferences.getString(AutomaticBackupPreferences.frequencyKey),
        'weekly',
      );
      expect(preferences.getInt(AutomaticBackupPreferences.hourKey), 21);
      expect(preferences.getInt(AutomaticBackupPreferences.minuteKey), 30);
    },
  );

  group('isAutomaticBackupDue', () {
    final lastBackup = DateTime(2025, 1, 1, 20);

    test('daily backups become due on the next local date', () {
      expect(
        isAutomaticBackupDue(
          frequency: AutomaticBackupFrequency.daily,
          lastBackup: lastBackup,
          now: DateTime(2025, 1, 2, 8),
        ),
        isTrue,
      );
      expect(
        isAutomaticBackupDue(
          frequency: AutomaticBackupFrequency.daily,
          lastBackup: lastBackup,
          now: DateTime(2025, 1, 1, 23),
        ),
        isFalse,
      );
    });

    test('weekly and monthly frequencies use calendar periods', () {
      expect(
        isAutomaticBackupDue(
          frequency: AutomaticBackupFrequency.weekly,
          lastBackup: lastBackup,
          now: DateTime(2025, 1, 7, 23),
        ),
        isFalse,
      );
      expect(
        isAutomaticBackupDue(
          frequency: AutomaticBackupFrequency.weekly,
          lastBackup: lastBackup,
          now: DateTime(2025, 1, 8, 8),
        ),
        isTrue,
      );
      expect(
        isAutomaticBackupDue(
          frequency: AutomaticBackupFrequency.monthly,
          lastBackup: lastBackup,
          now: DateTime(2025, 2, 1, 8),
        ),
        isTrue,
      );
    });

    test('a missing previous backup is immediately due', () {
      expect(
        isAutomaticBackupDue(
          frequency: AutomaticBackupFrequency.monthly,
          lastBackup: null,
          now: DateTime(2025, 1, 1),
        ),
        isTrue,
      );
    });
  });

  test('retention keeps only the seven newest automatic backups', () async {
    final directory = await Directory.systemTemp.createTemp(
      'automatic-backup-retention-',
    );
    addTearDown(() => directory.delete(recursive: true));

    for (var index = 0; index < 9; index++) {
      final file = File('${directory.path}\\doodh-hisaab-auto-$index.json');
      await file.writeAsString('{}');
      await file.setLastModified(
        DateTime(2025, 1, 1).add(Duration(days: index)),
      );
    }
    final unrelated = File('${directory.path}\\other.json');
    await unrelated.writeAsString('{}');

    await BackupService.retainAutomaticBackups(directory);

    final names = directory
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last)
        .toSet();
    expect(names, hasLength(8));
    expect(names, contains('doodh-hisaab-auto-2.json'));
    expect(names, contains('doodh-hisaab-auto-8.json'));
    expect(names, contains('other.json'));
    expect(names, isNot(contains('doodh-hisaab-auto-1.json')));
  });
}
