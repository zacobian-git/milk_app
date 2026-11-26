enum AutomaticBackupFrequency { daily, weekly, monthly }

abstract final class AutomaticBackupPreferences {
  static const enabledKey = 'automaticBackupEnabled';
  static const frequencyKey = 'automaticBackupFrequency';
  static const hourKey = 'automaticBackupHour';
  static const minuteKey = 'automaticBackupMinute';
  static const lastBackupKey = 'automaticBackupLastAt';
}

bool isAutomaticBackupDue({
  required AutomaticBackupFrequency frequency,
  required DateTime? lastBackup,
  required DateTime now,
}) {
  if (lastBackup == null) {
    return true;
  }

  final lastDate = DateTime.utc(
    lastBackup.year,
    lastBackup.month,
    lastBackup.day,
  );
  final currentDate = DateTime.utc(now.year, now.month, now.day);

  return switch (frequency) {
    AutomaticBackupFrequency.daily => currentDate.isAfter(lastDate),
    AutomaticBackupFrequency.weekly =>
      currentDate.difference(lastDate).inDays >= 7,
    AutomaticBackupFrequency.monthly =>
      now.year > lastBackup.year ||
          (now.year == lastBackup.year && now.month > lastBackup.month),
  };
}
