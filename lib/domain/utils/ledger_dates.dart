DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool isSameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

bool isSameMonth(DateTime first, DateTime second) =>
    first.year == second.year && first.month == second.month;

/// Adds calendar days without drifting across daylight-saving changes.
DateTime addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

DateTime monthStart(DateTime date) => DateTime(date.year, date.month);

DateTime monthEnd(DateTime date) => DateTime(date.year, date.month + 1, 0);

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
