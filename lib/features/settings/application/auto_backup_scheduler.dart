import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart';
import 'package:milk_app/data/database/database_connection.dart';
import 'package:milk_app/features/settings/application/app_settings.dart';
import 'package:milk_app/features/settings/application/automatic_backup_settings.dart';
import 'package:milk_app/features/settings/data/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const _automaticBackupTaskName = 'automatic-ledger-backup';
const _automaticBackupWorkName = 'automatic-ledger-backup-periodic';

@pragma('vm:entry-point')
void automaticBackupCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    if (taskName != _automaticBackupTaskName) {
      return false;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    if (!(preferences.getBool(AutomaticBackupPreferences.enabledKey) ??
        false)) {
      return true;
    }

    final frequency = AutomaticBackupFrequency.values.firstWhere(
      (value) =>
          value.name ==
          preferences.getString(AutomaticBackupPreferences.frequencyKey),
      orElse: () => AutomaticBackupFrequency.daily,
    );
    final now = DateTime.now();
    final lastBackupValue = preferences.getString(
      AutomaticBackupPreferences.lastBackupKey,
    );
    final lastBackup = lastBackupValue == null
        ? null
        : DateTime.tryParse(lastBackupValue);
    if (!isAutomaticBackupDue(
      frequency: frequency,
      lastBackup: lastBackup,
      now: now,
    )) {
      return true;
    }

    final database = openMilkDatabase();
    try {
      await BackupService(database).createAutomaticBackup(now: now);
      await preferences.setString(
        AutomaticBackupPreferences.lastBackupKey,
        DateTime.now().toIso8601String(),
      );
      return true;
    } catch (error, stackTrace) {
      debugPrint('Automatic backup failed: $error\n$stackTrace');
      return false;
    } finally {
      await database.close();
    }
  });
}

abstract final class AutoBackupScheduler {
  static Future<void> initialize() async {
    if (!Platform.isAndroid) {
      return;
    }
    await Workmanager().initialize(automaticBackupCallbackDispatcher);
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(AutomaticBackupPreferences.enabledKey) ?? false) {
      final settings = AppSettings(
        automaticBackupEnabled: true,
        automaticBackupFrequency: _frequencyFromName(
          preferences.getString(AutomaticBackupPreferences.frequencyKey),
        ),
        automaticBackupHour:
            preferences.getInt(AutomaticBackupPreferences.hourKey) ?? 20,
        automaticBackupMinute:
            preferences.getInt(AutomaticBackupPreferences.minuteKey) ?? 0,
      );
      await _register(settings, replace: false);
    }
  }

  static Future<void> configure(AppSettings settings) async {
    if (!Platform.isAndroid) {
      return;
    }
    if (!settings.automaticBackupEnabled) {
      await Workmanager().cancelByUniqueName(_automaticBackupWorkName);
      return;
    }
    await _register(settings, replace: true);
  }

  static Future<void> _register(
    AppSettings settings, {
    required bool replace,
  }) async {
    if (replace) {
      await Workmanager().cancelByUniqueName(_automaticBackupWorkName);
    }
    await Workmanager().registerPeriodicTask(
      _automaticBackupWorkName,
      _automaticBackupTaskName,
      frequency: const Duration(days: 1),
      initialDelay: _delayUntilNextRun(
        hour: settings.automaticBackupHour,
        minute: settings.automaticBackupMinute,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static Duration _delayUntilNextRun({required int hour, required int minute}) {
    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, hour, minute);
    if (!nextRun.isAfter(now)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }
    return nextRun.difference(now);
  }

  static AutomaticBackupFrequency _frequencyFromName(String? name) =>
      AutomaticBackupFrequency.values.firstWhere(
        (frequency) => frequency.name == name,
        orElse: () => AutomaticBackupFrequency.daily,
      );
}
