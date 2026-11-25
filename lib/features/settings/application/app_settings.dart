import 'package:material_ui/material_ui.dart';

class AppSettings {
  const AppSettings({
    this.languageCode = 'hi',
    this.themeMode = ThemeMode.system,
    this.reminderEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.paymentReminderEnabled = false,
    this.paymentReminderDay = 5,
    this.appLockEnabled = false,
    this.quantityStepMl = 250,
  });

  final String languageCode;
  final ThemeMode themeMode;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool paymentReminderEnabled;
  final int paymentReminderDay;
  final bool appLockEnabled;

  /// How much the + and − buttons change a quantity, in millilitres.
  final int quantityStepMl;

  AppSettings copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? paymentReminderEnabled,
    int? paymentReminderDay,
    bool? appLockEnabled,
    int? quantityStepMl,
  }) => AppSettings(
    languageCode: languageCode ?? this.languageCode,
    themeMode: themeMode ?? this.themeMode,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    paymentReminderEnabled:
        paymentReminderEnabled ?? this.paymentReminderEnabled,
    paymentReminderDay: paymentReminderDay ?? this.paymentReminderDay,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    quantityStepMl: quantityStepMl ?? this.quantityStepMl,
  );
}
