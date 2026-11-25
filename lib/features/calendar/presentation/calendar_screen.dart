import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/core/widgets/common_widgets.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';
import 'package:milk_app/features/calendar/presentation/daily_entry_editor_sheet.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/features/settings/application/app_settings_provider.dart';
import 'package:milk_app/features/settings/application/reminder_actions.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _month = monthStart(DateTime.now());
  DateTime? _selectedDay;

  /// +1 when moving forward in time, -1 when moving back; drives the slide.
  int _direction = 1;

  void _changeMonth(DateTime month) {
    final target = monthStart(month);
    if (target.year < 2000 || target.year > 2100 || target == _month) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _direction = target.isAfter(_month) ? 1 : -1;
      _month = target;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final vendors = ref.watch(activeVendorsProvider);
    final isCurrentMonth = isSameMonth(_month, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.calendar),
        actions: [
          AnimatedOpacity(
            duration: kShortAnimation,
            opacity: isCurrentMonth ? 0 : 1,
            child: IconButton(
              tooltip: strings.today,
              onPressed: isCurrentMonth
                  ? null
                  : () => _changeMonth(DateTime.now()),
              icon: const Icon(Icons.today_rounded),
            ),
          ),
        ],
      ),
      body: vendors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            ErrorState(onRetry: () => ref.invalidate(activeVendorsProvider)),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.calendar_month_rounded,
              title: strings.noVendors,
              message: strings.addFirstVendor,
              actionLabel: strings.addVendor,
              actionIcon: Icons.person_add_alt_1,
              onAction: () => context.push('/vendors/new'),
            );
          }
          final vendor = resolveSelectedVendor(
            items,
            ref.watch(selectedVendorIdProvider),
          );
          final selection = (
            vendorId: vendor.id,
            year: _month.year,
            month: _month.month,
          );
          final report = ref.watch(monthlyReportProvider(selection));

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              VendorSelector(vendors: items, selected: vendor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MonthSummary(report: report),
                    const SizedBox(height: 12),
                    _MonthCalendar(
                      month: _month,
                      direction: _direction,
                      selectedDay: _selectedDay,
                      entries: report.value?.entries,
                      onMonthChanged: _changeMonth,
                      onDaySelected: (day) =>
                          _openDay(vendor, day, report.value?.entries),
                    ),
                    const SizedBox(height: 12),
                    const _Legend(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _bulkMark(vendor),
                            icon: const Icon(Icons.done_all_rounded),
                            label: Text(
                              strings.bulkEntry,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openBackdatedEntry(vendor),
                            icon: const Icon(Icons.history_rounded),
                            label: Text(
                              strings.backdateEntry,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openDay(
    Vendor vendor,
    DateTime day,
    List<DailyEntry>? monthEntries,
  ) async {
    final inViewedMonth = isSameMonth(day, _month);
    setState(() => _selectedDay = day);
    if (!inViewedMonth) {
      _changeMonth(day);
    }
    DailyEntry? existing;
    if (monthEntries != null && inViewedMonth) {
      for (final entry in monthEntries) {
        if (isSameDate(entry.date, day)) {
          existing = entry;
          break;
        }
      }
    } else {
      existing = await ref
          .read(dailyEntryRepositoryProvider)
          .getEntryForDate(vendor.id, day);
    }
    if (!mounted) {
      return;
    }
    await showDailyEntryEditor(
      context: context,
      ref: ref,
      vendor: vendor,
      date: day,
      existing: existing,
    );
  }

  Future<void> _openBackdatedEntry(Vendor vendor) async {
    final today = dateOnly(DateTime.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay != null && !_selectedDay!.isAfter(today)
          ? _selectedDay!
          : today,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (selectedDate == null || !mounted) {
      return;
    }
    try {
      await _openDay(vendor, dateOnly(selectedDate), null);
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'backdated milk entry');
      if (mounted) {
        showAppSnackBar(context, AppLocalizations.of(context)!.errorOccurred);
      }
    }
  }

  Future<void> _bulkMark(Vendor vendor) async {
    final strings = AppLocalizations.of(context)!;
    final status = await showModalBottomSheet<DailyEntryStatus>(
      context: context,
      useSafeArea: true,
      builder: (context) => _BulkStatusSheet(strings: strings),
    );
    if (status == null || !mounted) {
      return;
    }

    late final DateTime firstRateDate;
    try {
      final ledger = await ref.read(vendorLedgerProvider(vendor.id).future);
      if (ledger.rates.isEmpty) {
        if (mounted) {
          showAppSnackBar(context, strings.noRateHistory);
        }
        return;
      }
      firstRateDate = dateOnly(ledger.rates.first.effectiveFrom);
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'load rates for bulk entry');
      if (mounted) {
        showAppSnackBar(context, strings.errorOccurred);
      }
      return;
    }
    if (!mounted) {
      return;
    }

    // Deliveries can only be recorded up to today; holidays can be planned.
    final today = dateOnly(DateTime.now());
    final isSkip = status == DailyEntryStatus.skipped;
    final lastDate = isSkip ? addDays(today, 366) : today;
    if (firstRateDate.isAfter(lastDate)) {
      showAppSnackBar(context, strings.bulkEntryMissingRate);
      return;
    }
    DateTime clamp(DateTime date) => date.isBefore(firstRateDate)
        ? firstRateDate
        : date.isAfter(lastDate)
        ? lastDate
        : date;
    final viewedStart = monthStart(_month);
    final viewedEnd = monthEnd(_month);
    var initialStart = clamp(
      isSkip && isSameMonth(_month, today) ? today : viewedStart,
    );
    var initialEnd = clamp(viewedEnd);
    if (initialStart.isAfter(initialEnd)) {
      initialStart = clamp(today);
      initialEnd = initialStart;
    }

    final range = await showDateRangePicker(
      context: context,
      firstDate: firstRateDate,
      lastDate: lastDate,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );
    if (range == null || !mounted) {
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: strings.markRangeTitle,
      message: isSkip ? strings.bulkSkipQuestion : strings.bulkMarkQuestion,
    );
    if (!confirmed || !mounted) {
      return;
    }
    try {
      final count = await ref
          .read(dailyEntryRepositoryProvider)
          .markUnmarkedDays(
            vendorId: vendor.id,
            startDate: range.start,
            endDate: range.end,
            defaultQtyMl: vendor.defaultQtyMl,
            status: status,
          );
      HapticFeedback.lightImpact();
      if (!range.start.isAfter(today) && !range.end.isBefore(today)) {
        unawaited(
          scheduleReminderAfterEntryChange(
            ref: ref,
            settings: ref.read(appSettingsProvider).value,
            strings: strings,
          ),
        );
      }
      if (mounted) {
        showAppSnackBar(context, strings.bulkMarkDone(count));
      }
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'bulk mark days');
      if (mounted) {
        showAppSnackBar(
          context,
          error is StateError
              ? strings.bulkEntryMissingRate
              : strings.errorOccurred,
        );
      }
    }
  }
}

class _BulkStatusSheet extends StatelessWidget {
  const _BulkStatusSheet({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              strings.markRangeTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.check_circle_rounded,
              color: entryStatusColor(context, DailyEntryStatus.delivered),
            ),
            title: Text(strings.markRangeDelivered),
            onTap: () => Navigator.pop(context, DailyEntryStatus.delivered),
          ),
          ListTile(
            leading: Icon(
              Icons.beach_access_rounded,
              color: entryStatusColor(context, DailyEntryStatus.skipped),
            ),
            title: Text(strings.markRangeSkipped),
            onTap: () => Navigator.pop(context, DailyEntryStatus.skipped),
          ),
        ],
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.report});

  final AsyncValue<MonthlyReportData> report;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final locale = strings.localeName;
    final data = report.value;
    if (data == null) {
      return report.hasError
          ? Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(strings.errorOccurred),
              ),
            )
          : const SizedBox(height: 4, child: LinearProgressIndicator());
    }
    final summary = data.summary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: StatTile(
                label: strings.totalLitres,
                value:
                    '${formatLitres(summary.totalQuantityMl)} ${strings.litreUnit}',
              ),
            ),
            Expanded(
              child: StatTile(
                label: strings.totalAmount,
                value: formatMoney(summary.totalAmountPaise, locale),
              ),
            ),
            Expanded(
              child: StatTile(
                label: strings.deliveredDays,
                value: summary.deliveredDays.toString(),
                valueColor: entryStatusColor(
                  context,
                  DailyEntryStatus.delivered,
                ),
              ),
            ),
            Expanded(
              child: StatTile(
                label: strings.skippedDays,
                value: summary.skippedDays.toString(),
                valueColor: entryStatusColor(context, DailyEntryStatus.skipped),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.direction,
    required this.selectedDay,
    required this.entries,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  final DateTime month;
  final int direction;
  final DateTime? selectedDay;
  final List<DailyEntry>? entries;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final weekdayStart = DateTime(2024, 1, 1); // A Monday.

    return Card(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity.abs() > 150) {
            onMonthChanged(
              DateTime(month.year, month.month + (velocity < 0 ? 1 : -1)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: strings.previousMonth,
                    onPressed: () =>
                        onMonthChanged(DateTime(month.year, month.month - 1)),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: kShortAnimation,
                      child: Text(
                        DateFormat.yMMMM(strings.localeName).format(month),
                        key: ValueKey(month),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: strings.nextMonth,
                    onPressed: () =>
                        onMonthChanged(DateTime(month.year, month.month + 1)),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  for (var weekday = 0; weekday < 7; weekday++)
                    Expanded(
                      child: Center(
                        child: Text(
                          DateFormat.E(
                            strings.localeName,
                          ).format(addDays(weekdayStart, weekday)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previousChildren, ?currentChild],
                ),
                transitionBuilder: (child, animation) {
                  final incoming = child.key == ValueKey(month);
                  final offset = Tween<Offset>(
                    begin: Offset(
                      (incoming ? 0.25 : -0.25) * direction,
                      0,
                    ),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: _DayGrid(
                  key: ValueKey(month),
                  month: month,
                  selectedDay: selectedDay,
                  entries: entries,
                  onDaySelected: onDaySelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayGrid extends StatelessWidget {
  const _DayGrid({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.entries,
    required this.onDaySelected,
  });

  final DateTime month;
  final DateTime? selectedDay;
  final List<DailyEntry>? entries;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final firstOfMonth = monthStart(month);
    final leadingDays = firstOfMonth.weekday - DateTime.monday;
    final dayCount = daysInMonth(month.year, month.month);
    final cellCount = ((leadingDays + dayCount + 6) ~/ 7) * 7;
    final today = dateOnly(DateTime.now());

    // One lookup table instead of scanning the list for every cell.
    final byDay = <int, DailyEntry>{
      for (final entry in entries ?? const <DailyEntry>[])
        if (isSameMonth(entry.date, month)) entry.date.day: entry,
    };

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 56,
      ),
      itemCount: cellCount,
      itemBuilder: (context, index) {
        final dayNumber = index - leadingDays + 1;
        if (dayNumber < 1 || dayNumber > dayCount) {
          return const SizedBox.shrink();
        }
        final day = DateTime(month.year, month.month, dayNumber);
        final entry = byDay[dayNumber];
        final status = entry?.status;
        final statusColor = entryStatusColor(context, status);
        final isSelected = selectedDay != null && isSameDate(day, selectedDay!);
        final isToday = day == today;
        final isFuture = day.isAfter(today);

        return Semantics(
          label:
              '${formatDate(day, strings.localeName)}, ${entryStatusLabel(strings, status)}',
          button: true,
          selected: isSelected,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Material(
              color: isSelected
                  ? colors.primaryContainer
                  : entry == null
                  ? Colors.transparent
                  : statusColor.withValues(alpha: 0.13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: isToday
                    ? BorderSide(color: colors.primary, width: 1.6)
                    : BorderSide.none,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onDaySelected(day),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isFuture
                            ? colors.onSurfaceVariant.withValues(alpha: 0.6)
                            : colors.onSurface,
                        fontWeight: isToday || isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 14,
                      child: entry == null
                          ? null
                          : status == DailyEntryStatus.custom
                          ? FittedBox(
                              child: Text(
                                formatLitres(entry.quantityMl),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : Icon(
                              entryStatusIcon(status),
                              size: 14,
                              color: statusColor,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final status in [
          DailyEntryStatus.delivered,
          DailyEntryStatus.skipped,
          DailyEntryStatus.custom,
          null,
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                entryStatusIcon(status),
                size: 16,
                color: entryStatusColor(context, status),
              ),
              const SizedBox(width: 4),
              Text(
                entryStatusLabel(strings, status),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
      ],
    );
  }
}
