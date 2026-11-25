import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/core/widgets/common_widgets.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class VendorRateHistoryScreen extends ConsumerWidget {
  const VendorRateHistoryScreen({super.key, required this.vendorId});

  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final ledger = ref.watch(vendorLedgerProvider(vendorId));

    return Scaffold(
      appBar: AppBar(
        title: Text(ledger.value?.vendor.name ?? strings.rateHistory),
      ),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorState(
          onRetry: () => ref.invalidate(vendorLedgerProvider(vendorId)),
        ),
        data: (data) {
          final rates = milkRatesOf(data).reversed.toList(growable: false);
          if (rates.isEmpty) {
            return EmptyState(
              icon: Icons.price_change_outlined,
              title: strings.noRateHistory,
            );
          }
          final today = dateOnly(DateTime.now());
          // Newest first; the first rate that has started is the current one.
          final currentIndex = rates.indexWhere(
            (rate) => !dateOnly(rate.effectiveFrom).isAfter(today),
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              SectionHeader(strings.rateHistory),
              Card(
                child: Column(
                  children: [
                    for (var index = 0; index < rates.length; index++) ...[
                      if (index > 0) const Divider(height: 1, indent: 72),
                      _RateTile(
                        rate: rates[index],
                        isCurrent: index == currentIndex,
                        isFuture: dateOnly(
                          rates[index].effectiveFrom,
                        ).isAfter(today),
                        onDelete: rates.length > 1
                            ? () => _deleteRate(context, ref, rates[index])
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRate(context, ref),
        icon: const Icon(Icons.price_change_outlined),
        label: Text(strings.changeRate),
      ),
    );
  }

  Future<void> _addRate(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context)!;
    final value = await showDialog<({int rate, DateTime date})>(
      context: context,
      builder: (context) => const _RateDialog(),
    );
    if (value == null) {
      return;
    }
    try {
      await ref
          .read(vendorRepositoryProvider)
          .changeRate(
            vendorId: vendorId,
            ratePerLitrePaise: value.rate,
            effectiveFrom: value.date,
          );
      HapticFeedback.lightImpact();
      if (context.mounted) {
        showAppSnackBar(context, strings.rateSaved);
      }
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'change rate');
      if (context.mounted) {
        showAppSnackBar(context, strings.errorOccurred);
      }
    }
  }

  Future<void> _deleteRate(
    BuildContext context,
    WidgetRef ref,
    MilkRate rate,
  ) async {
    final strings = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      message: strings.deleteRateQuestion,
      confirmLabel: strings.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    try {
      final deleted = await ref
          .read(vendorRepositoryProvider)
          .deleteRate(vendorId: vendorId, effectiveFrom: rate.effectiveFrom);
      if (context.mounted) {
        showAppSnackBar(
          context,
          deleted ? strings.rateDeleted : strings.cannotDeleteOnlyRate,
        );
      }
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'delete rate');
      if (context.mounted) {
        showAppSnackBar(context, strings.errorOccurred);
      }
    }
  }
}

class _RateTile extends StatelessWidget {
  const _RateTile({
    required this.rate,
    required this.isCurrent,
    required this.isFuture,
    required this.onDelete,
  });

  final MilkRate rate;
  final bool isCurrent;
  final bool isFuture;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      leading: CircleAvatar(
        backgroundColor: isCurrent
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        foregroundColor: isCurrent
            ? colors.onPrimaryContainer
            : colors.onSurfaceVariant,
        child: Icon(
          isFuture ? Icons.upcoming_outlined : Icons.currency_rupee_rounded,
        ),
      ),
      title: Row(
        children: [
          Text(
            '${formatMoney(rate.ratePerLitrePaise, strings.localeName)}'
            ' / ${strings.litreUnit}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            StatusPill(label: strings.currentRate, color: colors.primary),
          ],
        ],
      ),
      subtitle: Text(
        '${strings.effectiveFrom}: '
        '${formatDate(rate.effectiveFrom, strings.localeName)}',
      ),
      trailing: onDelete == null
          ? null
          : IconButton(
              tooltip: strings.delete,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
    );
  }
}

class _RateDialog extends StatefulWidget {
  const _RateDialog();

  @override
  State<_RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<_RateDialog> {
  final _controller = TextEditingController();
  DateTime _effectiveDate = dateOnly(DateTime.now());
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final rate = parseRupeesToPaise(_controller.text);
    if (rate == null || rate <= 0) {
      setState(() => _error = AppLocalizations.of(context)!.invalidAmount);
      return;
    }
    Navigator.pop(context, (rate: rate, date: _effectiveDate));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(strings.changeRate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            decoration: InputDecoration(
              labelText: strings.ratePerLitre,
              prefixText: '₹ ',
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _effectiveDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() => _effectiveDate = dateOnly(date));
              }
            },
            icon: const Icon(Icons.event_rounded),
            label: Text(
              '${strings.effectiveFrom}: '
              '${formatDate(_effectiveDate, strings.localeName)}',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(48, 44)),
          onPressed: _submit,
          child: Text(strings.save),
        ),
      ],
    );
  }
}
