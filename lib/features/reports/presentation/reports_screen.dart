import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/features/reports/data/bill_pdf_service.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/features/reports/presentation/monthly_insights.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int? _vendorId;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final vendors = ref.watch(activeVendorsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.tabReports)),
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
          final vendor = items.any((item) => item.id == _vendorId)
              ? items.firstWhere((item) => item.id == _vendorId)
              : items.first;
          final selection = (
            vendorId: vendor.id,
            year: _month.year,
            month: _month.month,
          );
          final report = ref.watch(monthlyReportProvider(selection));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: DropdownButtonFormField<int>(
                  initialValue: vendor.id,
                  decoration: InputDecoration(labelText: strings.selectVendor),
                  items: [
                    for (final item in items)
                      DropdownMenuItem(value: item.id, child: Text(item.name)),
                  ],
                  onChanged: (value) => setState(() => _vendorId = value),
                ),
              ),
              _MonthPicker(
                month: _month,
                locale: strings.localeName,
                selectLabel: strings.selectMonth,
                onChanged: (value) => setState(() => _month = value),
              ),
              Expanded(
                child: report.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(strings.errorOccurred),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(monthlyReportProvider(selection)),
                          child: Text(strings.retry),
                        ),
                      ],
                    ),
                  ),
                  data: (data) => _ReportBody(
                    report: data,
                    locale: strings.localeName,
                    strings: strings,
                    sharing: _sharing,
                    onShare: () => _share(data),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _share(MonthlyReportData report) async {
    setState(() => _sharing = true);
    final strings = AppLocalizations.of(context)!;
    try {
      await const BillPdfService().shareBill(report, strings);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'share monthly bill',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.errorOccurred)));
      }
    } finally {
      if (mounted) {
        setState(() => _sharing = false);
      }
    }
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({
    required this.month,
    required this.locale,
    required this.selectLabel,
    required this.onChanged,
  });

  final DateTime month;
  final String locale;
  final String selectLabel;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        tooltip: selectLabel,
        onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
        icon: const Icon(Icons.chevron_left),
      ),
      TextButton(
        onPressed: () async {
          final selected = await showDatePicker(
            context: context,
            initialDate: month,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDatePickerMode: DatePickerMode.year,
          );
          if (selected != null) {
            onChanged(DateTime(selected.year, selected.month));
          }
        },
        child: Text(
          DateFormat.yMMMM(locale).format(month),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      IconButton(
        tooltip: selectLabel,
        onPressed: () => onChanged(DateTime(month.year, month.month + 1)),
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.report,
    required this.locale,
    required this.strings,
    required this.sharing,
    required this.onShare,
  });

  final MonthlyReportData report;
  final String locale;
  final AppLocalizations strings;
  final bool sharing;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryRow(
                  label: strings.totalLitres,
                  value:
                      '${formatLitres(summary.totalQuantityMl)} ${strings.litreUnit}',
                ),
                _SummaryRow(
                  label: strings.totalAmount,
                  value: formatMoney(summary.totalAmountPaise, locale),
                ),
                _SummaryRow(
                  label: strings.deliveredDays,
                  value: summary.deliveredDays.toString(),
                ),
                _SummaryRow(
                  label: strings.skippedDays,
                  value: summary.skippedDays.toString(),
                ),
                _SummaryRow(
                  label: strings.paymentsThisMonth,
                  value: formatMoney(summary.paidPaise, locale),
                ),
                _SummaryRow(
                  label: strings.carriedForward,
                  value: formatMoney(summary.carriedForwardPaise, locale),
                ),
                const Divider(),
                _SummaryRow(
                  label: summary.closingBalancePaise < 0
                      ? strings.advance
                      : strings.closingBalance,
                  value: formatMoney(summary.closingBalancePaise.abs(), locale),
                  emphasized: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        MonthlyInsights(
          insights: report.insights,
          locale: locale,
          strings: strings,
        ),
        const SizedBox(height: 8),
        Text(strings.dayByDay, style: Theme.of(context).textTheme.titleLarge),
        if (report.entries.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(strings.noReportData),
          )
        else
          for (final entry in report.entries)
            Card(
              child: ListTile(
                leading: Icon(
                  entry.status == DailyEntryStatus.skipped
                      ? Icons.close
                      : entry.status == DailyEntryStatus.custom
                      ? Icons.water_drop_outlined
                      : Icons.check,
                  color: entry.status == DailyEntryStatus.skipped
                      ? Theme.of(context).colorScheme.error
                      : entry.status == DailyEntryStatus.custom
                      ? Colors.orange.shade700
                      : Theme.of(context).colorScheme.primary,
                ),
                title: Text(formatDate(entry.date, locale)),
                subtitle: Text(
                  '${formatLitres(entry.quantityMl)} ${strings.litreUnit} · '
                  '${strings.rate}: ${formatMoney(entry.rateUsedPaise, locale)}',
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
              ),
            ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: sharing ? null : onShare,
          icon: sharing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          label: Text(strings.sharePdf),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: sharing ? null : onShare,
          icon: const Icon(Icons.share_outlined),
          label: Text(strings.shareWhatsApp),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized ? Theme.of(context).textTheme.titleMedium : null,
          ),
        ),
        Text(
          value,
          style: emphasized
              ? Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)
              : null,
        ),
      ],
    ),
  );
}
