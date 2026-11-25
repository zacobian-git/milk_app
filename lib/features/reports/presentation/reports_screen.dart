import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/core/widgets/common_widgets.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';
import 'package:milk_app/features/reports/data/bill_pdf_service.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/features/reports/presentation/monthly_insights.dart';
import 'package:milk_app/l10n/app_localizations.dart';

enum _ShareAction { pdf, print, text }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _month = monthStart(DateTime.now());
  _ShareAction? _busyAction;

  void _setMonth(DateTime month) {
    final target = monthStart(month);
    if (target != _month) {
      HapticFeedback.selectionClick();
      setState(() => _month = target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final vendors = ref.watch(activeVendorsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.tabReports)),
      body: vendors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            ErrorState(onRetry: () => ref.invalidate(activeVendorsProvider)),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_rounded,
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
          return Column(
            children: [
              VendorSelector(vendors: items, selected: vendor),
              _MonthPicker(month: _month, onChanged: _setMonth),
              Expanded(
                child: report.when(
                  skipLoadingOnReload: true,
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => ErrorState(
                    onRetry: () =>
                        ref.invalidate(vendorLedgerProvider(vendor.id)),
                  ),
                  data: (data) => _ReportBody(
                    report: data,
                    busyAction: _busyAction,
                    onShare: (action) => _share(action, data),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _share(_ShareAction action, MonthlyReportData report) async {
    if (_busyAction != null) {
      return;
    }
    setState(() => _busyAction = action);
    final strings = AppLocalizations.of(context)!;
    const service = BillPdfService();
    try {
      switch (action) {
        case _ShareAction.pdf:
          await service.shareBill(report, strings);
        case _ShareAction.print:
          await service.printBill(report, strings);
        case _ShareAction.text:
          await service.shareSummaryText(report, strings);
      }
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'share monthly bill');
      if (mounted) {
        showAppSnackBar(context, strings.errorOccurred);
      }
    } finally {
      if (mounted) {
        setState(() => _busyAction = null);
      }
    }
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: strings.previousMonth,
            onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: TextButton.icon(
              onPressed: () async {
                final selected = await showDialog<DateTime>(
                  context: context,
                  builder: (context) => _MonthGridDialog(initial: month),
                );
                if (selected != null) {
                  onChanged(selected);
                }
              },
              icon: const Icon(Icons.calendar_month_outlined, size: 20),
              label: AnimatedSwitcher(
                duration: kShortAnimation,
                child: Text(
                  DateFormat.yMMMM(strings.localeName).format(month),
                  key: ValueKey(month),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: strings.nextMonth,
            onPressed: () => onChanged(DateTime(month.year, month.month + 1)),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

/// A compact year + 12-month grid; quicker than a full date picker.
class _MonthGridDialog extends StatefulWidget {
  const _MonthGridDialog({required this.initial});

  final DateTime initial;

  @override
  State<_MonthGridDialog> createState() => _MonthGridDialogState();
}

class _MonthGridDialogState extends State<_MonthGridDialog> {
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();
    return AlertDialog(
      title: Row(
        children: [
          IconButton(
            onPressed: _year > 2000 ? () => setState(() => _year--) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(child: Center(child: Text('$_year'))),
          IconButton(
            onPressed: _year < 2100 ? () => setState(() => _year++) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2,
          children: [
            for (var month = 1; month <= 12; month++)
              _monthButton(
                context,
                DateTime(_year, month),
                label: DateFormat.MMM(
                  strings.localeName,
                ).format(DateTime(_year, month)),
                selected:
                    _year == widget.initial.year &&
                    month == widget.initial.month,
                current: _year == now.year && month == now.month,
                colors: colors,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
      ],
    );
  }

  Widget _monthButton(
    BuildContext context,
    DateTime value, {
    required String label,
    required bool selected,
    required bool current,
    required ColorScheme colors,
  }) {
    final style = selected
        ? FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 40),
          )
        : OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 40),
            side: BorderSide(
              color: current ? colors.primary : colors.outlineVariant,
            ),
          );
    void select() => Navigator.pop(context, value);
    return selected
        ? FilledButton(style: style, onPressed: select, child: Text(label))
        : OutlinedButton(style: style, onPressed: select, child: Text(label));
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.report,
    required this.busyAction,
    required this.onShare,
  });

  final MonthlyReportData report;
  final _ShareAction? busyAction;
  final ValueChanged<_ShareAction> onShare;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = strings.localeName;
    final summary = report.summary;
    final closing = summary.closingBalancePaise;

    Widget actionIcon(_ShareAction action, IconData icon) => busyAction == action
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  closing < 0 ? strings.advance : strings.closingBalance,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  formatMoney(closing.abs(), locale),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: closing > 0
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _StatGrid(
                  stats: [
                    (
                      strings.totalLitres,
                      '${formatLitres(summary.totalQuantityMl)} ${strings.litreUnit}',
                    ),
                    (
                      strings.totalAmount,
                      formatMoney(summary.totalAmountPaise, locale),
                    ),
                    (strings.deliveredDays, '${summary.deliveredDays}'),
                    (strings.skippedDays, '${summary.skippedDays}'),
                    (
                      strings.averagePerDay,
                      '${formatLitres(report.averageDailyMl)} ${strings.litreUnit}',
                    ),
                    (
                      strings.paymentsThisMonth,
                      formatMoney(summary.paidPaise, locale),
                    ),
                    (
                      strings.carriedForward,
                      formatMoney(summary.carriedForwardPaise, locale),
                    ),
                    (
                      strings.currentRate,
                      report.currentRatePaise == null
                          ? '—'
                          : formatMoney(report.currentRatePaise!, locale),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: busyAction == null ? () => onShare(_ShareAction.pdf) : null,
          icon: actionIcon(_ShareAction.pdf, Icons.picture_as_pdf_outlined),
          label: Text(strings.sharePdf),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busyAction == null
                    ? () => onShare(_ShareAction.text)
                    : null,
                icon: actionIcon(_ShareAction.text, Icons.chat_outlined),
                label: Text(
                  strings.shareWhatsApp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busyAction == null
                    ? () => onShare(_ShareAction.print)
                    : null,
                icon: actionIcon(_ShareAction.print, Icons.print_outlined),
                label: Text(
                  strings.printBill,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        MonthlyInsights(
          insights: report.insights,
          locale: locale,
          strings: strings,
        ),
        SectionHeader(strings.dayByDay),
        if (report.entries.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(strings.noReportData),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (var index = 0; index < report.entries.length; index++) ...[
                  if (index > 0) const Divider(height: 1, indent: 64),
                  _EntryRow(entry: report.entries[index]),
                ],
              ],
            ),
          ),
        if (report.payments.isNotEmpty) ...[
          SectionHeader(strings.paymentsThisMonth),
          Card(
            child: Column(
              children: [
                for (final payment in report.payments)
                  ListTile(
                    leading: Icon(paymentModeIcon(payment.mode)),
                    title: Text(formatDate(payment.date, locale)),
                    subtitle: Text(
                      [
                        paymentModeLabel(strings, payment.mode),
                        if (payment.note?.isNotEmpty ?? false) payment.note!,
                      ].join(' · '),
                    ),
                    trailing: Text(
                      formatMoney(payment.amountPaise, locale),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth > 520 ? 4 : 2;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [
          for (final (label, value) in stats)
            SizedBox(
              width: width,
              child: StatTile(label: label, value: value),
            ),
        ],
      );
    },
  );
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final DailyEntry entry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final locale = strings.localeName;
    final color = entryStatusColor(context, entry.status);
    final isSkipped = entry.status == DailyEntryStatus.skipped;
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.14),
        child: Icon(entryStatusIcon(entry.status), size: 18, color: color),
      ),
      title: Text(DateFormat.MMMEd(locale).format(entry.date)),
      subtitle: Text(
        isSkipped
            ? strings.skipped
            : '${formatLitres(entry.quantityMl)} ${strings.litreUnit} × '
                  '${formatMoney(entry.rateUsedPaise, locale)}'
                  '${entry.note?.isNotEmpty ?? false ? ' · ${entry.note}' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        formatMoney(
          amountForEntry(
            BillingEntry(
              date: entry.date,
              quantityMl: entry.quantityMl,
              rateUsedPaise: entry.rateUsedPaise,
              status: entry.status,
            ),
          ),
          locale,
        ),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
