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

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _Section(
          title: strings.generalSection,
          children: [
            _LabeledControl(
              icon: Icons.translate_rounded,
              label: strings.language,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: 'hi', label: Text(strings.hindi)),
                  ButtonSegment(value: 'en', label: Text(strings.english)),
                ],
                selected: {settings.languageCode},
                onSelectionChanged: (value) => _runSetting(
                  context,
                  () => controller.setLanguage(value.first),
                ),
              ),
            ),
            _LabeledControl(
              icon: Icons.palette_outlined,
              label: strings.theme,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_rounded),
                    tooltip: strings.systemTheme,
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_rounded),
                    tooltip: strings.lightTheme,
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_rounded),
                    tooltip: strings.darkTheme,
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (value) => _runSetting(
                  context,
                  () => controller.setTheme(value.first),
                ),
              ),
            ),
            _LabeledControl(
              icon: Icons.straighten_rounded,
              label: strings.quantityStep,
              hint: strings.quantityStepHint,
              child: SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  for (final step in AppSettingsController.quantitySteps)
                    ButtonSegment(value: step, label: Text('$step ml')),
                ],
                selected: {settings.quantityStepMl},
                onSelectionChanged: (value) => _runSetting(
                  context,
                  () => controller.setQuantityStep(value.first),
                ),
              ),
            ),
          ],
        ),
        _Section(
          title: strings.remindersSection,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: Text(strings.enableReminder),
              subtitle: Text(strings.dailyReminder),
              value: settings.reminderEnabled,
              onChanged: (enabled) =>
                  _setReminder(context, ref, settings, enabled),
            ),
            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: Text(strings.reminderTime),
              trailing: Text(
                TimeOfDay(
                  hour: settings.reminderHour,
                  minute: settings.reminderMinute,
                ).format(context),
                style: theme.textTheme.titleSmall,
              ),
              onTap: () => _chooseReminderTime(context, ref, settings),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.event_repeat_outlined),
              title: Text(strings.enablePaymentReminder),
              value: settings.paymentReminderEnabled,
              onChanged: (enabled) =>
                  _setPaymentReminder(context, ref, settings, enabled),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: settings.paymentReminderEnabled
                  ? ListTile(
                      leading: const Icon(Icons.today_outlined),
                      title: Text(strings.paymentReminderDay),
                      trailing: DropdownButton<int>(
                        value: settings.paymentReminderDay,
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(16),
                        items: [
                          for (var day = 1; day <= 28; day++)
                            DropdownMenuItem(
                              value: day,
                              child: Text(day.toString()),
                            ),
                        ],
                        onChanged: (day) {
                          if (day != null) {
                            _setPaymentReminderDay(context, ref, settings, day);
                          }
                        },
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                strings.notificationPermission,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        _Section(
          title: strings.dataSection,
          children: [
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: Text(strings.backup),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _backup(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.restore_outlined),
              title: Text(strings.restore),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _restore(context, ref),
            ),
          ],
        ),
        _Section(
          title: strings.securitySection,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint_rounded),
              title: Text(strings.enableAppLock),
              subtitle: Text(strings.appLock),
              value: settings.appLockEnabled,
              onChanged: (enabled) => _setAppLock(context, ref, enabled),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListTile(
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
        ref.invalidate(archivedVendorsProvider);
        ref.invalidate(vendorLedgerProvider);
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: children),
        ),
      ),
    ],
  );
}

class _LabeledControl extends StatelessWidget {
  const _LabeledControl({
    required this.icon,
    required this.label,
    required this.child,
    this.hint,
  });

  final IconData icon;
  final String label;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            ],
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(left: 38, top: 2),
              child: Text(
                hint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 10),
          child,
        ],
      ),
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
