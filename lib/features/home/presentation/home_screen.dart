import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';
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
        title: Text(
          strings.appTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
        error: (error, stackTrace) => _HomeError(
          message: strings.errorOccurred,
          retry: () => ref.invalidate(activeVendorsProvider),
        ),
        data: (items) => items.isEmpty
            ? _Welcome(
                title: strings.onboardingTitle,
                message: strings.onboardingBody,
                addLabel: strings.addFirstVendor,
                onAdd: () => context.push('/vendors/new'),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text(
                    '${strings.today} · ${formatDate(DateTime.now(), strings.localeName)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final vendor in items) ...[
                    VendorTodayCard(vendor: vendor),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
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
  late int _quantityMl = widget.vendor.defaultQtyMl;
  bool _saving = false;

  @override
  void didUpdateWidget(covariant VendorTodayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vendor.id != widget.vendor.id) {
      _quantityMl = widget.vendor.defaultQtyMl;
    }
  }

  Future<void> _mark(DailyEntryStatus status) async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    final strings = AppLocalizations.of(context)!;
    final date = dateOnly(DateTime.now());
    final repository = ref.read(dailyEntryRepositoryProvider);
    try {
      final previous = await repository.getEntryForDate(widget.vendor.id, date);
      await repository.saveEntry(
        vendorId: widget.vendor.id,
        date: date,
        quantityMl: _quantityMl,
        status: status,
      );
      unawaited(
        scheduleReminderAfterEntryChange(
          ref: ref,
          settings: ref.read(appSettingsProvider).value,
          strings: strings,
        ),
      );
      ref.invalidate(entryForDateProvider);
      ref.invalidate(entriesForMonthProvider);
      ref.invalidate(monthlyReportProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(strings.entrySaved),
            action: SnackBarAction(
              label: strings.undo,
              onPressed: () => unawaited(_undo(previous, date)),
            ),
          ),
        );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'today entry',
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

  Future<void> _undo(DailyEntry? previous, DateTime date) async {
    try {
      await ref
          .read(dailyEntryRepositoryProvider)
          .undoEntryChange(
            vendorId: widget.vendor.id,
            date: date,
            previousEntry: previous,
          );
      ref.invalidate(entryForDateProvider);
      ref.invalidate(entriesForMonthProvider);
      ref.invalidate(monthlyReportProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.entryUndone)),
        );
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'undo daily entry',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final today = dateOnly(DateTime.now());
    final selection = (vendorId: widget.vendor.id, date: today);
    final entry = ref.watch(entryForDateProvider(selection));
    final summary = ref.watch(
      monthlyReportProvider((
        vendorId: widget.vendor.id,
        year: today.year,
        month: today.month,
      )),
    );
    final rateHistory = ref.watch(vendorRateHistoryProvider(widget.vendor.id));
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.vendor.name,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                entry.when(
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (error, stackTrace) => Icon(
                    Icons.error_outline,
                    semanticLabel: strings.errorOccurred,
                  ),
                  data: (value) => _StatusPill(
                    label: value == null
                        ? strings.unmarked
                        : _statusLabel(strings, value.status),
                    color: value == null
                        ? colors.outline
                        : value.status == DailyEntryStatus.skipped
                        ? colors.error
                        : colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${strings.defaultQuantity}: ${formatLitres(widget.vendor.defaultQtyMl)} ${strings.litreUnit}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            summary.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => Text(strings.errorOccurred),
              data: (report) => rateHistory.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => Text(strings.errorOccurred),
                data: (rates) {
                  final currentRate = rateForDate(rates, DateTime.now());
                  return _MonthAtAGlance(
                    total: formatMoney(
                      report.summary.totalAmountPaise,
                      strings.localeName,
                    ),
                    litres:
                        '${formatLitres(report.summary.totalQuantityMl)} ${strings.litreUnit}',
                    deliveredDays: report.summary.deliveredDays.toString(),
                    rate: currentRate == null
                        ? strings.noRateHistory
                        : formatMoney(currentRate, strings.localeName),
                    balance: formatMoney(
                      report.summary.closingBalancePaise.abs(),
                      strings.localeName,
                    ),
                    balanceLabel: report.summary.closingBalancePaise < 0
                        ? strings.advance
                        : strings.balance,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
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
                const SizedBox(width: 12),
                Text(
                  '${formatLitres(_quantityMl)} ${strings.litreUnit}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  tooltip: strings.changeQuantity,
                  onPressed: () => setState(() => _quantityMl += 250),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _mark(DailyEntryStatus.delivered),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(strings.markDelivered),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _mark(DailyEntryStatus.skipped),
                    icon: const Icon(Icons.close),
                    label: Text(strings.markSkipped),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations strings, DailyEntryStatus status) =>
      switch (status) {
        DailyEntryStatus.delivered => strings.delivered,
        DailyEntryStatus.skipped => strings.skipped,
        DailyEntryStatus.custom => strings.customQuantity,
      };
}

class _MonthAtAGlance extends StatelessWidget {
  const _MonthAtAGlance({
    required this.total,
    required this.litres,
    required this.deliveredDays,
    required this.rate,
    required this.balance,
    required this.balanceLabel,
  });

  final String total;
  final String litres;
  final String deliveredDays;
  final String rate;
  final String balance;
  final String balanceLabel;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: itemWidth,
                child: _AmountLabel(
                  label: strings.deliveredDays,
                  value: deliveredDays,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _AmountLabel(label: strings.ratePerLitre, value: rate),
              ),
              SizedBox(
                width: itemWidth,
                child: _AmountLabel(label: strings.totalAmount, value: total),
              ),
              SizedBox(
                width: itemWidth,
                child: _AmountLabel(label: strings.totalLitres, value: litres),
              ),
              SizedBox(
                width: itemWidth,
                child: _AmountLabel(label: balanceLabel, value: balance),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  const _AmountLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 4),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    ),
  );
}

class _Welcome extends StatelessWidget {
  const _Welcome({
    required this.title,
    required this.message,
    required this.addLabel,
    required this.onAdd,
  });

  final String title;
  final String message;
  final String addLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          children: [
            Icon(
              Icons.water_drop_rounded,
              size: 96,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(addLabel),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.retry});

  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: 8),
        TextButton(
          onPressed: retry,
          child: Text(AppLocalizations.of(context)!.retry),
        ),
      ],
    ),
  );
}
