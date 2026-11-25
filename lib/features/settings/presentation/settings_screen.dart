import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/features/settings/application/app_settings.dart';
import 'package:milk_app/features/settings/application/app_settings_provider.dart';
import 'package:milk_app/features/settings/application/reminder_service.dart';
import 'package:milk_app/features/settings/application/reminder_actions.dart';
import 'package:milk_app/features/settings/data/backup_service.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/features/payments/data/payments_provider.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _SettingsError(retry: () => ref.invalidate(appSettingsProvider)),
        data: (value) => _SettingsList(settings: value),
      ),
    );
  }
}

class _SettingsList extends ConsumerWidget {
  const _SettingsList({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final controller = ref.read(appSettingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: settings.languageCode,
          decoration: InputDecoration(labelText: strings.language),
          items: [
            DropdownMenuItem(value: 'hi', child: Text(strings.hindi)),
            DropdownMenuItem(value: 'en', child: Text(strings.english)),
          ],
          onChanged: (value) {
            if (value != null) {
              _runSetting(context, () => controller.setLanguage(value));
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ThemeMode>(
          initialValue: settings.themeMode,
          decoration: InputDecoration(labelText: strings.theme),
          items: [
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Text(strings.systemTheme),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text(strings.lightTheme),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Text(strings.darkTheme),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              _runSetting(context, () => controller.setTheme(value));
            }
          },
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.enableReminder),
          subtitle: Text(strings.dailyReminder),
          value: settings.reminderEnabled,
          onChanged: (enabled) => _setReminder(context, ref, settings, enabled),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.reminderTime),
          subtitle: Text(
            TimeOfDay(
              hour: settings.reminderHour,
              minute: settings.reminderMinute,
            ).format(context),
          ),
          trailing: const Icon(Icons.schedule_outlined),
          onTap: () => _chooseReminderTime(context, ref, settings),
        ),
        Text(
          strings.notificationPermission,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.enablePaymentReminder),
          value: settings.paymentReminderEnabled,
          onChanged: (enabled) =>
              _setPaymentReminder(context, ref, settings, enabled),
        ),
        if (settings.paymentReminderEnabled)
          DropdownButtonFormField<int>(
            initialValue: settings.paymentReminderDay,
            decoration: InputDecoration(labelText: strings.paymentReminderDay),
            items: [
              for (var day = 1; day <= 28; day++)
                DropdownMenuItem(value: day, child: Text(day.toString())),
            ],
            onChanged: (day) {
              if (day != null) {
                _setPaymentReminderDay(context, ref, settings, day);
              }
            },
          ),
        const Divider(height: 32),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.backup_outlined),
          title: Text(strings.backup),
          onTap: () => _backup(context, ref),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.restore_outlined),
          title: Text(strings.restore),
          onTap: () => _restore(context, ref),
        ),
        const Divider(height: 32),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.enableAppLock),
          subtitle: Text(strings.appLock),
          value: settings.appLockEnabled,
          onChanged: (enabled) => _setAppLock(context, ref, enabled),
        ),
        const Divider(height: 32),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline),
          title: Text(strings.about),
          subtitle: Text(strings.appDescription),
        ),
      ],
    );
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context)!;
    try {
      await BackupService(ref.read(milkDatabaseProvider)).shareBackup();
      if (context.mounted) {
        _showMessage(context, strings.backupCreated);
      }
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'backup');
      if (context.mounted) {
        _showMessage(context, strings.backupUnavailable);
      }
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context)!;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(strings.restoreConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(strings.confirm),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    try {
      final restored = await BackupService(ref.read(milkDatabaseProvider))
          .restoreBackup();
      if (restored) {
        ref.invalidate(activeVendorsProvider);
        ref.invalidate(paymentsProvider);
        ref.invalidate(monthlyReportProvider);
        ref.invalidate(entriesForMonthProvider);
        ref.invalidate(entryForDateProvider);
        if (context.mounted) {
          _showMessage(context, strings.restoreSuccess);
        }
      }
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'restore backup');
      if (context.mounted) {
        _showMessage(context, strings.errorOccurred);
      }
    }
  }

  Future<void> _setReminder(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    bool enabled,
  ) async {
    final strings = AppLocalizations.of(context)!;
    final controller = ref.read(appSettingsProvider.notifier);
    try {
      if (enabled) {
        final granted = await ReminderService.requestPermissionAndSchedule(
          hour: settings.reminderHour,
          minute: settings.reminderMinute,
          title: strings.reminderTitle,
          body: strings.reminderBody,
          channelName: strings.reminderChannel,
          channelDescription: strings.reminderChannelDescription,
        );
        if (!granted) {
          if (context.mounted) {
            _showMessage(context, strings.notificationPermission);
          }
          return;
        }
      } else {
        await ReminderService.cancelDaily();
      }
      await controller.setReminder(enabled: enabled);
      if (enabled) {
        await scheduleReminderAfterEntryChange(
          ref: ref,
          settings: settings.copyWith(reminderEnabled: true),
          strings: strings,
        );
      }
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'daily reminder');
      if (context.mounted) {
        _showMessage(context, strings.errorOccurred);
      }
    }
  }

  Future<void> _chooseReminderTime(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final strings = AppLocalizations.of(context)!;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
    );
    if (selected == null || !context.mounted) {
      return;
    }
    final controller = ref.read(appSettingsProvider.notifier);
    try {
      if (settings.reminderEnabled) {
        await ReminderService.scheduleDaily(
          hour: selected.hour,
          minute: selected.minute,
          title: strings.reminderTitle,
          body: strings.reminderBody,
          channelName: strings.reminderChannel,
          channelDescription: strings.reminderChannelDescription,
        );
      }
      await controller.setReminder(
        enabled: settings.reminderEnabled,
        hour: selected.hour,
        minute: selected.minute,
      );
      if (settings.reminderEnabled) {
        await scheduleReminderAfterEntryChange(
          ref: ref,
          settings: settings.copyWith(
            reminderHour: selected.hour,
            reminderMinute: selected.minute,
          ),
          strings: strings,
        );
      }
      if (settings.paymentReminderEnabled) {
        await ReminderService.scheduleMonthlyPayment(
          day: settings.paymentReminderDay,
          hour: selected.hour,
          minute: selected.minute,
          title: strings.paymentReminderTitle,
          body: strings.paymentReminderBody,
          channelName: strings.reminderChannel,
          channelDescription: strings.reminderChannelDescription,
        );
      }
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'reminder time');
      if (context.mounted) {
        _showMessage(context, strings.errorOccurred);
      }
    }
  }

  Future<void> _setPaymentReminder(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    bool enabled,
  ) async {
    final strings = AppLocalizations.of(context)!;
    try {
      if (enabled) {
        final granted = await ReminderService.requestPermission();
        if (!granted) {
          if (context.mounted) {
            _showMessage(context, strings.notificationPermission);
          }
          return;
        }
        await ReminderService.scheduleMonthlyPayment(
          day: settings.paymentReminderDay,
          hour: settings.reminderHour,
          minute: settings.reminderMinute,
          title: strings.paymentReminderTitle,
          body: strings.paymentReminderBody,
          channelName: strings.reminderChannel,
          channelDescription: strings.reminderChannelDescription,
        );
      } else {
        await ReminderService.cancelMonthlyPayment();
      }
      await ref
          .read(appSettingsProvider.notifier)
          .setPaymentReminder(enabled: enabled);
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'monthly payment reminder');
      if (context.mounted) {
        _showMessage(context, strings.errorOccurred);
      }
    }
  }

  Future<void> _setPaymentReminderDay(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    int day,
  ) async {
    final strings = AppLocalizations.of(context)!;
    try {
      await ReminderService.scheduleMonthlyPayment(
        day: day,
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
        title: strings.paymentReminderTitle,
        body: strings.paymentReminderBody,
        channelName: strings.reminderChannel,
        channelDescription: strings.reminderChannelDescription,
      );
      await ref
          .read(appSettingsProvider.notifier)
          .setPaymentReminder(enabled: true, day: day);
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'monthly payment reminder day');
      if (context.mounted) {
        _showMessage(context, strings.errorOccurred);
      }
    }
  }

  Future<void> _setAppLock(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final strings = AppLocalizations.of(context)!;
    if (enabled) {
      final authentication = LocalAuthentication();
      try {
        if (!await authentication.isDeviceSupported()) {
          if (context.mounted) {
            _showMessage(context, strings.lockUnavailable);
          }
          return;
        }
        final authenticated = await authentication.authenticate(
          localizedReason: strings.authReason,
          persistAcrossBackgrounding: true,
        );
        if (!authenticated || !context.mounted) {
          return;
        }
      } on LocalAuthException catch (error, stackTrace) {
        _report(error, stackTrace, 'device authentication');
        if (context.mounted) {
          _showMessage(context, strings.errorOccurred);
        }
        return;
      } on PlatformException catch (error, stackTrace) {
        _report(error, stackTrace, 'device authentication');
        if (context.mounted) {
          _showMessage(context, strings.errorOccurred);
        }
        return;
      }
    }
    await _runSetting(
      context,
      () => ref.read(appSettingsProvider.notifier).setAppLock(enabled),
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.retry});

  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.errorOccurred),
          TextButton(onPressed: retry, child: Text(strings.retry)),
        ],
      ),
    );
  }
}

Future<void> _runSetting(
  BuildContext context,
  Future<void> Function() update,
) async {
  try {
    await update();
  } catch (error, stackTrace) {
    _report(error, stackTrace, 'settings');
    if (context.mounted) {
      _showMessage(context, AppLocalizations.of(context)!.errorOccurred);
    }
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void _report(Object error, StackTrace stackTrace, String library) {
  FlutterError.reportError(
    FlutterErrorDetails(exception: error, stack: stackTrace, library: library),
  );
}
