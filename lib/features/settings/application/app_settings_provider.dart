import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:milk_app/features/settings/application/app_settings.dart';

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends AsyncNotifier<AppSettings> {
  static const _languageKey = 'languageCode';
  static const _themeKey = 'themeMode';
  static const _reminderEnabledKey = 'reminderEnabled';
  static const _reminderHourKey = 'reminderHour';
  static const _reminderMinuteKey = 'reminderMinute';
  static const _paymentReminderEnabledKey = 'paymentReminderEnabled';
  static const _paymentReminderDayKey = 'paymentReminderDay';
  static const _appLockKey = 'appLockEnabled';

  @override
  Future<AppSettings> build() async {
    final preferences = await SharedPreferences.getInstance();
    return AppSettings(
      languageCode: preferences.getString(_languageKey) ?? 'hi',
      themeMode: _themeFromName(preferences.getString(_themeKey)),
      reminderEnabled: preferences.getBool(_reminderEnabledKey) ?? false,
      reminderHour: preferences.getInt(_reminderHourKey) ?? 20,
      reminderMinute: preferences.getInt(_reminderMinuteKey) ?? 0,
      paymentReminderEnabled:
          preferences.getBool(_paymentReminderEnabledKey) ?? false,
      paymentReminderDay: preferences.getInt(_paymentReminderDayKey) ?? 5,
      appLockEnabled: preferences.getBool(_appLockKey) ?? false,
    );
  }

  Future<void> setLanguage(String languageCode) =>
      _update((settings) => settings.copyWith(languageCode: languageCode));

  Future<void> setTheme(ThemeMode mode) =>
      _update((settings) => settings.copyWith(themeMode: mode));

  Future<void> setReminder({required bool enabled, int? hour, int? minute}) =>
      _update(
        (settings) => settings.copyWith(
          reminderEnabled: enabled,
          reminderHour: hour,
          reminderMinute: minute,
        ),
      );

  Future<void> setPaymentReminder({required bool enabled, int? day}) => _update(
    (settings) => settings.copyWith(
      paymentReminderEnabled: enabled,
      paymentReminderDay: day,
    ),
  );

  Future<void> setAppLock(bool enabled) =>
      _update((settings) => settings.copyWith(appLockEnabled: enabled));

  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final previous = state.requireValue;
    final updated = change(previous);
    state = AsyncData(updated);
    try {
      final preferences = await SharedPreferences.getInstance();
      await Future.wait([
        preferences.setString(_languageKey, updated.languageCode),
        preferences.setString(_themeKey, updated.themeMode.name),
        preferences.setBool(_reminderEnabledKey, updated.reminderEnabled),
        preferences.setInt(_reminderHourKey, updated.reminderHour),
        preferences.setInt(_reminderMinuteKey, updated.reminderMinute),
        preferences.setBool(
          _paymentReminderEnabledKey,
          updated.paymentReminderEnabled,
        ),
        preferences.setInt(_paymentReminderDayKey, updated.paymentReminderDay),
        preferences.setBool(_appLockKey, updated.appLockEnabled),
      ]);
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  ThemeMode _themeFromName(String? name) => switch (name) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
