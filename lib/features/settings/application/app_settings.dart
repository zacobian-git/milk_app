import 'package:material_ui/material_ui.dart';
import 'package:milk_app/features/settings/application/automatic_backup_settings.dart';

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
    this.automaticBackupEnabled = false,
    this.automaticBackupFrequency = AutomaticBackupFrequency.daily,
    this.automaticBackupHour = 20,
    this.automaticBackupMinute = 0,
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
  final bool automaticBackupEnabled;
  final AutomaticBackupFrequency automaticBackupFrequency;
  final int automaticBackupHour;
  final int automaticBackupMinute;

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
    bool? automaticBackupEnabled,
    AutomaticBackupFrequency? automaticBackupFrequency,
    int? automaticBackupHour,
    int? automaticBackupMinute,
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
    automaticBackupEnabled:
        automaticBackupEnabled ?? this.automaticBackupEnabled,
    automaticBackupFrequency:
        automaticBackupFrequency ?? this.automaticBackupFrequency,
    automaticBackupHour: automaticBackupHour ?? this.automaticBackupHour,
    automaticBackupMinute: automaticBackupMinute ?? this.automaticBackupMinute,
  );
}
