import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';
import 'package:milk_app/features/settings/application/app_settings.dart';
import 'package:milk_app/features/settings/application/reminder_service.dart';
import 'package:milk_app/l10n/app_localizations.dart';

Future<void> scheduleReminderAfterEntryChange({
  required WidgetRef ref,
  required AppSettings? settings,
  required AppLocalizations strings,
}) async {
  final activeSettings = settings;
  if (activeSettings == null || !activeSettings.reminderEnabled) {
    return;
  }
  try {
    final vendors = await ref.read(vendorRepositoryProvider).getActiveVendors();
    if (vendors.isEmpty) {
      await ReminderService.cancelDaily();
      return;
    }
    final today = dateOnly(DateTime.now());
    var hasUnmarkedDays = false;
    for (final vendor in vendors) {
      if (await ref
              .read(dailyEntryRepositoryProvider)
              .getEntryForDate(vendor.id, today) ==
          null) {
        hasUnmarkedDays = true;
        break;
      }
    }
    await ReminderService.scheduleDaily(
      hour: activeSettings.reminderHour,
      minute: activeSettings.reminderMinute,
      title: strings.reminderTitle,
      body: strings.reminderBody,
      channelName: strings.reminderChannel,
      channelDescription: strings.reminderChannelDescription,
      startTomorrow: !hasUnmarkedDays,
    );
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'daily milk reminder',
      ),
    );
  }
}
