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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final vendors = ref.watch(activeVendorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            tooltip: strings.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: vendors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            ErrorState(onRetry: () => ref.invalidate(activeVendorsProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.water_drop_rounded,
                title: strings.onboardingTitle,
                message: strings.onboardingBody,
                actionLabel: strings.addFirstVendor,
                actionIcon: Icons.person_add_alt_1,
                onAction: () => context.push('/vendors/new'),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  _TodayOverview(vendors: items),
                  const SizedBox(height: 16),
                  for (final vendor in items) ...[
                    VendorTodayCard(key: ValueKey(vendor.id), vendor: vendor),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Totals across all vendors plus a one-tap "mark everything" action.
class _TodayOverview extends ConsumerStatefulWidget {
  const _TodayOverview({required this.vendors});

  final List<Vendor> vendors;

  @override
  ConsumerState<_TodayOverview> createState() => _TodayOverviewState();
}

class _TodayOverviewState extends ConsumerState<_TodayOverview> {
  bool _saving = false;

  Future<void> _markAll(List<Vendor> pending) async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    final strings = AppLocalizations.of(context)!;
    final repository = ref.read(dailyEntryRepositoryProvider);
    final today = dateOnly(DateTime.now());
    final saved = <Vendor>[];
    var failed = false;
    for (final vendor in pending) {
      try {
        await repository.saveEntry(
          vendorId: vendor.id,
          date: today,
          quantityMl: vendor.defaultQtyMl,
          status: vendor.defaultQtyMl == 0
              ? DailyEntryStatus.skipped
              : DailyEntryStatus.delivered,
        );
        saved.add(vendor);
      } catch (error, stackTrace) {
        failed = true;
        reportUiError(error, stackTrace, 'mark all delivered');
      }
    }
    HapticFeedback.mediumImpact();
    unawaited(
      scheduleReminderAfterEntryChange(
        ref: ref,
        settings: ref.read(appSettingsProvider).value,
        strings: strings,
      ),
    );
    if (mounted) {
      setState(() => _saving = false);
      showAppSnackBar(
        context,
        failed ? strings.bulkEntryMissingRate : strings.bulkMarkDone(saved.length),
        actionLabel: saved.isEmpty ? null : strings.undo,
        onAction: saved.isEmpty
            ? null
            : () {
                for (final vendor in saved) {
                  unawaited(
                    repository.undoEntryChange(
                      vendorId: vendor.id,
                      date: today,
                      previousEntry: null,
                    ),
                  );
                }
              },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final today = dateOnly(DateTime.now());

    var totalBalance = 0;
    var balancesReady = true;
    final pending = <Vendor>[];
    for (final vendor in widget.vendors) {
      final balance = ref.watch(vendorBalanceProvider(vendor.id)).value;
      if (balance == null) {
        balancesReady = false;
      } else {
        totalBalance += balance;
      }
      final entry = ref.watch(
        entryForDateProvider((vendorId: vendor.id, date: today)),
      );
      if (entry.hasValue && entry.value == null) {
        pending.add(vendor);
      }
    }
    final isAdvance = totalBalance < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, Color.lerp(colors.primary, colors.tertiary, 0.55)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMEEEEd(strings.localeName).format(today),
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isAdvance ? strings.totalAdvance : strings.totalDue,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: kShortAnimation,
            child: Text(
              balancesReady
                  ? formatMoney(totalBalance.abs(), strings.localeName)
                  : '—',
              key: ValueKey(balancesReady ? totalBalance : null),
              style: theme.textTheme.displaySmall?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: kShortAnimation,
            child: pending.isEmpty
                ? Row(
                    key: const ValueKey('done'),
                    children: [
                      Icon(Icons.task_alt_rounded, color: colors.onPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.allDoneToday,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey('pending'),
                    children: [
                      Expanded(
                        child: Text(
                          strings.pendingToday(pending.length),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (widget.vendors.length > 1)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.onPrimary,
                            foregroundColor: colors.primary,
                            minimumSize: const Size(48, 44),
                          ),
                          onPressed: _saving ? null : () => _markAll(pending),
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.done_all_rounded),
                          label: Text(strings.markAllDelivered),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class VendorTodayCard extends ConsumerStatefulWidget {
  const VendorTodayCard({super.key, required this.vendor});

  final Vendor vendor;

  @override
  ConsumerState<VendorTodayCard> createState() => _VendorTodayCardState();
}

class _VendorTodayCardState extends ConsumerState<VendorTodayCard> {
  /// Quantity the person adjusted but has not saved yet.
  int? _draftQuantityMl;
  bool _saving = false;

  @override
  void didUpdateWidget(covariant VendorTodayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vendor.id != widget.vendor.id ||
        oldWidget.vendor.defaultQtyMl != widget.vendor.defaultQtyMl) {
      _draftQuantityMl = null;
    }
  }

  int _displayedQuantity(DailyEntry? entry) {
    if (_draftQuantityMl != null) {
      return _draftQuantityMl!;
    }
    if (entry != null && entry.status != DailyEntryStatus.skipped) {
      return entry.quantityMl;
    }
    return widget.vendor.defaultQtyMl;
  }

  Future<void> _mark(DailyEntryStatus requested, DailyEntry? current) async {
    if (_saving) {
      return;
    }
    final strings = AppLocalizations.of(context)!;
    final quantity = _displayedQuantity(current);
    final status = resolveEntryStatus(
      requested: requested,
      quantityMl: quantity,
      defaultQtyMl: widget.vendor.defaultQtyMl,
    );
    setState(() => _saving = true);
    final date = dateOnly(DateTime.now());
    final repository = ref.read(dailyEntryRepositoryProvider);
    try {
      await repository.saveEntry(
        vendorId: widget.vendor.id,
        date: date,
        quantityMl: quantity,
        status: status,
        note: current?.note,
      );
      HapticFeedback.lightImpact();
      unawaited(
        scheduleReminderAfterEntryChange(
          ref: ref,
          settings: ref.read(appSettingsProvider).value,
          strings: strings,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() => _draftQuantityMl = null);
      showAppSnackBar(
        context,
        '${widget.vendor.name} · ${strings.entrySaved}',
        actionLabel: strings.undo,
        onAction: () => unawaited(_undo(current, date)),
      );
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'today entry');
      if (mounted) {
        showAppSnackBar(
          context,
          error is StateError
              ? strings.bulkEntryMissingRate
              : strings.errorOccurred,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _undo(DailyEntry? previous, DateTime date) async {
    final strings = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(dailyEntryRepositoryProvider)
          .undoEntryChange(
            vendorId: widget.vendor.id,
            date: date,
            previousEntry: previous,
          );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(strings.entryUndone)));
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'undo daily entry');
      messenger.showSnackBar(SnackBar(content: Text(strings.errorOccurred)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final today = dateOnly(DateTime.now());
    final vendor = widget.vendor;
    final entryValue = ref.watch(
      entryForDateProvider((vendorId: vendor.id, date: today)),
    );
    final report = ref.watch(
      monthlyReportProvider((
        vendorId: vendor.id,
        year: today.year,
        month: today.month,
      )),
    );
    final step =
        ref.watch(appSettingsProvider.select((s) => s.value?.quantityStepMl)) ??
        250;
    final entry = entryValue.value;
    final status = entry?.status;
    final quantity = _displayedQuantity(entry);
    final hasDraft = _draftQuantityMl != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                VendorAvatar(name: vendor.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${strings.defaultQuantity}: ${formatLitres(vendor.defaultQtyMl)} ${strings.litreUnit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: kShortAnimation,
                  child: entryValue.isLoading && entry == null
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : StatusPill(
                          key: ValueKey(status),
                          label: entryStatusLabel(strings, status),
                          color: entryStatusColor(context, status),
                          icon: entryStatusIcon(status),
                        ),
                ),
                IconButton(
                  tooltip: strings.editTodayEntry,
                  onPressed: entryValue.hasValue
                      ? () => showDailyEntryEditor(
                          context: context,
                          ref: ref,
                          vendor: vendor,
                          date: today,
                          existing: entry,
                        )
                      : null,
                  icon: const Icon(Icons.edit_note_rounded),
                ),
              ],
            ),
            if (entry?.note?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry!.note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _MonthAtAGlance(
                report: report,
                onTap: () {
                  ref.read(selectedVendorIdProvider.notifier).select(vendor.id);
                  context.go('/reports');
                },
              ),
            ),
            const SizedBox(height: 14),
            QuantityStepper(
              quantityMl: quantity,
              stepMl: step,
              enabled: !_saving,
              onChanged: (value) => setState(() => _draftQuantityMl = value),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          _saving ||
                              (!hasDraft &&
                                  entry != null &&
                                  status != DailyEntryStatus.skipped)
                          ? null
                          : () => _mark(DailyEntryStatus.delivered, entry),
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        hasDraft && entry != null
                            ? strings.save
                            : strings.markDelivered,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving || status == DailyEntryStatus.skipped
                          ? null
                          : () => _mark(DailyEntryStatus.skipped, entry),
                      icon: const Icon(Icons.block_rounded),
                      label: Text(
                        strings.markSkipped,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthAtAGlance extends StatelessWidget {
  const _MonthAtAGlance({required this.report, required this.onTap});

  final AsyncValue<MonthlyReportData> report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = report.value;
    final locale = strings.localeName;

    Widget content;
    if (data == null) {
      content = report.hasError
          ? Text(strings.errorOccurred)
          : const LinearProgressIndicator();
    } else {
      final balance = data.summary.closingBalancePaise;
      final rate = data.currentRatePaise;
      content = Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: strings.currentMonth,
                  value: formatMoney(data.summary.totalAmountPaise, locale),
                ),
              ),
              Expanded(
                child: StatTile(
                  label: strings.totalLitres,
                  value:
                      '${formatLitres(data.summary.totalQuantityMl)} ${strings.litreUnit}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: strings.ratePerLitre,
                  value: rate == null ? '—' : formatMoney(rate, locale),
                ),
              ),
              Expanded(
                child: StatTile(
                  label: balance < 0 ? strings.advance : strings.balance,
                  value: formatMoney(balance.abs(), locale),
                  valueColor: balance > 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: data == null ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: AnimatedSize(
            duration: kShortAnimation,
            alignment: Alignment.topCenter,
            child: content,
          ),
        ),
      ),
    );
  }
}
