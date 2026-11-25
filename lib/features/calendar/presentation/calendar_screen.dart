import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _vendorId;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final vendors = ref.watch(activeVendorsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.calendar)),
      body: vendors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(activeVendorsProvider),
            child: Text(strings.retry),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(strings.noVendors),
                  FilledButton(
                    onPressed: () => context.push('/vendors/new'),
                    child: Text(strings.addVendor),
                  ),
                ],
              ),
            );
          }
          final selectedVendor = items.any((item) => item.id == _vendorId)
              ? items.firstWhere((item) => item.id == _vendorId)
              : items.first;
          if (_vendorId != selectedVendor.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _vendorId = selectedVendor.id);
              }
            });
          }
          final selection = (
            vendorId: selectedVendor.id,
            year: _focusedDay.year,
            month: _focusedDay.month,
          );
          final entries = ref.watch(entriesForMonthProvider(selection));
          final summary = ref.watch(monthlyReportProvider(selection));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedVendor.id,
                decoration: InputDecoration(labelText: strings.selectVendor),
                items: [
                  for (final vendor in items)
                    DropdownMenuItem(
                      value: vendor.id,
                      child: Text(vendor.name),
                    ),
                ],
                onChanged: (value) => setState(() => _vendorId = value),
              ),
              const SizedBox(height: 12),
              summary.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => Text(strings.errorOccurred),
                data: (data) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryValue(
                            title: strings.totalLitres,
                            value:
                                '${formatLitres(data.summary.totalQuantityMl)} ${strings.litreUnit}',
                          ),
                        ),
                        Expanded(
                          child: _SummaryValue(
                            title: strings.totalAmount,
                            value: formatMoney(
                              data.summary.totalAmountPaise,
                              strings.localeName,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              entries.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => Text(strings.errorOccurred),
                data: (monthEntries) => _MonthCalendar(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  entries: monthEntries,
                  onPageChanged: (day) => setState(() => _focusedDay = day),
                  onDaySelected: (selected, focused) async {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                    DailyEntry? existing;
                    for (final entry in monthEntries) {
                      if (isSameDate(entry.date, selected)) {
                        existing = entry;
                        break;
                      }
                    }
                    await _editEntryForDate(
                      context: context,
                      ref: ref,
                      vendor: selectedVendor,
                      date: selected,
                      existing: existing,
                      strings: strings,
                    );
                  },
                  strings: strings,
                ),
              ),
              const SizedBox(height: 8),
              _Legend(strings: strings),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    _bulkMark(context, ref, selectedVendor, _focusedDay),
                icon: const Icon(Icons.done_all),
                label: Text(strings.bulkEntry),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    _openBackdatedEntry(context, ref, selectedVendor, strings),
                icon: const Icon(Icons.history),
                label: Text(strings.backdateEntry),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openBackdatedEntry(
    BuildContext context,
    WidgetRef ref,
    Vendor vendor,
    AppLocalizations strings,
  ) async {
    final today = dateOnly(DateTime.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (selectedDate == null || !context.mounted) {
      return;
    }

    final date = dateOnly(selectedDate);
    setState(() {
      _selectedDay = date;
      _focusedDay = date;
    });
    try {
      final existing = await ref
          .read(dailyEntryRepositoryProvider)
          .getEntryForDate(vendor.id, date);
      if (!context.mounted) {
        return;
      }
      await _editEntryForDate(
        context: context,
        ref: ref,
        vendor: vendor,
        date: date,
        existing: existing,
        strings: strings,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'backdated milk entry',
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.errorOccurred)));
      }
    }
  }

  Future<void> _editEntryForDate({
    required BuildContext context,
    required WidgetRef ref,
    required Vendor vendor,
    required DateTime date,
    required DailyEntry? existing,
    required AppLocalizations strings,
  }) async {
    final result = await showModalBottomSheet<DailyEntryEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          DailyEntryEditorSheet(vendor: vendor, date: date, existing: existing),
    );
    if (result == null || !context.mounted) {
      return;
    }

    ref.invalidate(entriesForMonthProvider);
    ref.invalidate(monthlyReportProvider);
    if (isSameDate(date, DateTime.now())) {
      unawaited(
        scheduleReminderAfterEntryChange(
          ref: ref,
          settings: ref.read(appSettingsProvider).value,
          strings: strings,
        ),
      );
    }
    if (result == DailyEntryEditorResult.deleted && existing != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(strings.entryDeleted),
            action: SnackBarAction(
              label: strings.undo,
              onPressed: () =>
                  unawaited(_undoDeletedEntry(ref, vendor, existing, strings)),
            ),
          ),
        );
    }
  }

  Future<void> _bulkMark(
    BuildContext context,
    WidgetRef ref,
    Vendor vendor,
    DateTime month,
  ) async {
    final strings = AppLocalizations.of(context)!;
    late final DateTime firstRateDate;
    try {
      final rateHistory = await ref
          .read(vendorRepositoryProvider)
          .getRateHistory(vendor.id);
      if (rateHistory.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(strings.noRateHistory)));
        }
        return;
      }
      firstRateDate = dateOnly(rateHistory.first.effectiveFrom);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'load rates for bulk entry',
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.errorOccurred)));
      }
      return;
    }
    if (!context.mounted) {
      return;
    }
    final monthStart = DateTime(month.year, month.month);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final today = dateOnly(DateTime.now());
    final rangeEnd = isSameDate(month, today)
        ? today
        : monthStart.isAfter(today)
        ? monthStart
        : monthEnd;
    final initialStart = monthStart.isBefore(firstRateDate)
        ? firstRateDate
        : monthStart;
    final initialEnd = rangeEnd.isBefore(initialStart)
        ? initialStart
        : rangeEnd;
    final range = await showDateRangePicker(
      context: context,
      firstDate: firstRateDate,
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );
    if (range == null || !context.mounted) {
      return;
    }
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(strings.bulkMarkQuestion),
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
    if (!confirmed || !context.mounted) {
      return;
    }
    try {
      final count = await ref
          .read(dailyEntryRepositoryProvider)
          .markUnmarkedAsDelivered(
            vendorId: vendor.id,
            startDate: range.start,
            endDate: range.end,
            defaultQtyMl: vendor.defaultQtyMl,
          );
      ref.invalidate(entriesForMonthProvider);
      ref.invalidate(monthlyReportProvider);
      if (!range.start.isAfter(dateOnly(DateTime.now())) &&
          !range.end.isBefore(dateOnly(DateTime.now()))) {
        unawaited(
          scheduleReminderAfterEntryChange(
            ref: ref,
            settings: ref.read(appSettingsProvider).value,
            strings: strings,
          ),
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.bulkMarkDone(count))));
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'bulk mark deliveries',
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError
                  ? strings.bulkEntryMissingRate
                  : strings.errorOccurred,
            ),
          ),
        );
      }
    }
  }
}

enum DailyEntryEditorResult { saved, deleted }

Future<void> _undoDeletedEntry(
  WidgetRef ref,
  Vendor vendor,
  DailyEntry entry,
  AppLocalizations strings,
) async {
  try {
    await ref
        .read(dailyEntryRepositoryProvider)
        .undoEntryChange(
          vendorId: vendor.id,
          date: entry.date,
          previousEntry: entry,
        );
    ref.invalidate(entriesForMonthProvider);
    ref.invalidate(monthlyReportProvider);
    if (isSameDate(entry.date, DateTime.now())) {
      unawaited(
        scheduleReminderAfterEntryChange(
          ref: ref,
          settings: ref.read(appSettingsProvider).value,
          strings: strings,
        ),
      );
    }
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'undo deleted daily entry',
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.entries,
    required this.onPageChanged,
    required this.onDaySelected,
    required this.strings,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<DailyEntry> entries;
  final ValueChanged<DateTime> onPageChanged;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(focusedDay.year, focusedDay.month);
    final leadingDays = firstOfMonth.weekday - DateTime.monday;
    final daysInMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0).day;
    final visibleDayCount = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;
    final firstVisibleDay = firstOfMonth.subtract(Duration(days: leadingDays));
    final weekdayStart = DateTime(2024, 1, 1);
    final previousMonth = DateTime(focusedDay.year, focusedDay.month - 1);
    final nextMonth = DateTime(focusedDay.year, focusedDay.month + 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity.abs() > 100) {
              onPageChanged(
                DateTime(
                  focusedDay.year,
                  focusedDay.month + (velocity < 0 ? 1 : -1),
                ),
              );
            }
          },
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: strings.previousMonth,
                    onPressed: previousMonth.year < 2000
                        ? null
                        : () => onPageChanged(previousMonth),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        DateFormat.yMMMM(strings.localeName).format(focusedDay),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: strings.nextMonth,
                    onPressed: nextMonth.year > 2100
                        ? null
                        : () => onPageChanged(nextMonth),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Row(
                children: [
                  for (var weekday = 0; weekday < 7; weekday++)
                    Expanded(
                      child: Center(
                        child: Text(
                          DateFormat.E(
                            strings.localeName,
                          ).format(weekdayStart.add(Duration(days: weekday))),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: 48,
                ),
                itemCount: visibleDayCount,
                itemBuilder: (context, index) {
                  final day = firstVisibleDay.add(Duration(days: index));
                  DailyEntry? entry;
                  for (final item in entries) {
                    if (isSameDate(item.date, day)) {
                      entry = item;
                      break;
                    }
                  }
                  final isInMonth = day.month == focusedDay.month;
                  final isSelected =
                      selectedDay != null && isSameDate(day, selectedDay!);
                  final isToday = isSameDate(day, DateTime.now());
                  final colors = Theme.of(context).colorScheme;
                  final statusColor = switch (entry?.status) {
                    DailyEntryStatus.delivered => colors.primary,
                    DailyEntryStatus.skipped => colors.error,
                    DailyEntryStatus.custom => Colors.orange.shade700,
                    null => colors.outline,
                  };
                  final statusLabel = switch (entry?.status) {
                    DailyEntryStatus.delivered => strings.delivered,
                    DailyEntryStatus.skipped => strings.skipped,
                    DailyEntryStatus.custom => strings.customQuantity,
                    null => strings.unmarked,
                  };
                  final semanticLabel =
                      '${formatDate(day, strings.localeName)}, $statusLabel';

                  return Semantics(
                    label: semanticLabel,
                    button: true,
                    selected: isSelected,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onDaySelected(day, focusedDay),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primaryContainer
                              : entry == null
                              ? null
                              : statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: isToday
                              ? Border.all(color: colors.primary)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day.day.toString(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isInMonth
                                        ? colors.onSurface
                                        : colors.outline,
                                    fontWeight: isToday || isSelected
                                        ? FontWeight.w700
                                        : null,
                                  ),
                            ),
                            if (entry == null)
                              const SizedBox(height: 14)
                            else
                              Icon(
                                entry.status == DailyEntryStatus.skipped
                                    ? Icons.close_rounded
                                    : entry.status == DailyEntryStatus.custom
                                    ? Icons.water_drop_outlined
                                    : Icons.check_rounded,
                                size: 14,
                                color: statusColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyEntryEditorSheet extends ConsumerStatefulWidget {
  const DailyEntryEditorSheet({
    super.key,
    required this.vendor,
    required this.date,
    this.existing,
  });

  final Vendor vendor;
  final DateTime date;
  final DailyEntry? existing;

  @override
  ConsumerState<DailyEntryEditorSheet> createState() =>
      _DailyEntryEditorSheetState();
}

class _DailyEntryEditorSheetState extends ConsumerState<DailyEntryEditorSheet> {
  late int _quantityMl =
      widget.existing?.quantityMl ?? widget.vendor.defaultQtyMl;
  late DailyEntryStatus _status =
      widget.existing?.status ?? DailyEntryStatus.delivered;
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.existing?.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final date = formatDate(widget.date, strings.localeName);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.vendor.name} · $date',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SegmentedButton<DailyEntryStatus>(
            segments: [
              ButtonSegment(
                value: DailyEntryStatus.delivered,
                label: Text(strings.delivered),
              ),
              ButtonSegment(
                value: DailyEntryStatus.skipped,
                label: Text(strings.skipped),
              ),
              ButtonSegment(
                value: DailyEntryStatus.custom,
                label: Text(strings.customQuantity),
              ),
            ],
            selected: {_status},
            onSelectionChanged: (selection) =>
                setState(() => _status = selection.first),
          ),
          if (_status != DailyEntryStatus.skipped) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: strings.changeQuantity,
                  onPressed: _quantityMl >= 250
                      ? () => setState(() => _quantityMl -= 250)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${formatLitres(_quantityMl)} ${strings.litreUnit}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: strings.changeQuantity,
                  onPressed: () => setState(() => _quantityMl += 250),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(labelText: strings.notes),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const CircularProgressIndicator()
                : Text(strings.save),
          ),
          if (widget.existing != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(strings.delete),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final strings = AppLocalizations.of(context)!;
    try {
      await ref
          .read(dailyEntryRepositoryProvider)
          .saveEntry(
            vendorId: widget.vendor.id,
            date: widget.date,
            quantityMl: _quantityMl,
            status: _status,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context, DailyEntryEditorResult.saved);
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'calendar entry',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.errorOccurred)));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final entry = widget.existing;
    if (entry == null) {
      return;
    }
    final strings = AppLocalizations.of(context)!;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(strings.deleteEntryQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(strings.delete),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(dailyEntryRepositoryProvider).deleteEntry(entry.id);
      if (mounted) {
        Navigator.pop(context, DailyEntryEditorResult.deleted);
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'delete daily entry',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.errorOccurred)));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.labelMedium),
      Text(value, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 8,
    children: [
      _LegendItem(
        icon: Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
        label: strings.delivered,
      ),
      _LegendItem(
        icon: Icons.close,
        color: Theme.of(context).colorScheme.error,
        label: strings.skipped,
      ),
      _LegendItem(
        icon: Icons.water_drop_outlined,
        color: Colors.orange.shade700,
        label: strings.customQuantity,
      ),
      _LegendItem(
        icon: Icons.circle_outlined,
        color: Theme.of(context).colorScheme.outline,
        label: strings.unmarked,
      ),
    ],
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}
