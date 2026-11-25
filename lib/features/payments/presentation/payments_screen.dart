import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/features/payments/data/payments_provider.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  int? _vendorId;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final vendors = ref.watch(activeVendorsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.tabPayments)),
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
          final month = DateTime.now();
          final report = ref.watch(
            monthlyReportProvider((
              vendorId: vendor.id,
              year: month.year,
              month: month.month,
            )),
          );
          final payments = ref.watch(paymentsProvider(vendor.id));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
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
              Expanded(
                child: payments.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: TextButton(
                      onPressed: () =>
                          ref.invalidate(paymentsProvider(vendor.id)),
                      child: Text(strings.retry),
                    ),
                  ),
                  data: (items) => items.isEmpty
                      ? Center(child: Text(strings.noPayments))
                      : _PaymentsList(
                          payments: items,
                          locale: strings.localeName,
                          strings: strings,
                          onEdit: (payment) => _editPayment(
                            context,
                            vendor.id,
                            payment: payment,
                          ),
                          onDelete: (payment) =>
                              _deletePayment(context, payment),
                        ),
                ),
              ),
              if (report.hasValue)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        report.value!.summary.closingBalancePaise < 0
                            ? strings.advance
                            : strings.balance,
                      ),
                      trailing: Text(
                        formatMoney(
                          report.value!.summary.closingBalancePaise.abs(),
                          strings.localeName,
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final vendors = ref.read(activeVendorsProvider).value ?? [];
          if (vendors.isEmpty) {
            return;
          }
          _editPayment(context, _vendorId ?? vendors.first.id);
        },
        icon: const Icon(Icons.add),
        label: Text(strings.addPayment),
      ),
    );
  }

  Future<void> _editPayment(
    BuildContext context,
    int vendorId, {
    Payment? payment,
  }) async {
    final today = DateTime.now();
    final report = await ref.read(
      monthlyReportProvider((
        vendorId: vendorId,
        year: today.year,
        month: today.month,
      )).future,
    );
    if (!context.mounted) {
      return;
    }
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => PaymentEditorSheet(
        vendorId: vendorId,
        existing: payment,
        fullBalancePaise: report.summary.closingBalancePaise,
      ),
    );
    if (saved == true) {
      ref.invalidate(paymentsProvider(vendorId));
      ref.invalidate(monthlyReportProvider);
    }
  }

  Future<void> _deletePayment(BuildContext context, Payment payment) async {
    final strings = AppLocalizations.of(context)!;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.delete),
            content: Text(strings.deletePaymentQuestion),
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
    if (!confirmed) {
      return;
    }
    try {
      await ref.read(paymentRepositoryProvider).deletePayment(payment.id);
      ref.invalidate(paymentsProvider(payment.vendorId));
      ref.invalidate(monthlyReportProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(strings.paymentDeleted),
              action: SnackBarAction(
                label: strings.undo,
                onPressed: () => unawaited(_restorePayment(payment)),
              ),
            ),
          );
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'delete payment',
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.errorOccurred)));
      }
    }
  }

  Future<void> _restorePayment(Payment payment) async {
    try {
      await ref.read(paymentRepositoryProvider).restorePayment(payment);
      ref.invalidate(paymentsProvider(payment.vendorId));
      ref.invalidate(monthlyReportProvider);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'restore payment',
        ),
      );
    }
  }
}

class PaymentEditorSheet extends ConsumerStatefulWidget {
  const PaymentEditorSheet({
    super.key,
    required this.vendorId,
    required this.fullBalancePaise,
    this.existing,
  });

  final int vendorId;
  final int fullBalancePaise;
  final Payment? existing;

  @override
  ConsumerState<PaymentEditorSheet> createState() => _PaymentEditorSheetState();
}

class _PaymentEditorSheetState extends ConsumerState<PaymentEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController(
    text: widget.existing == null
        ? ''
        : _amountInput(widget.existing!.amountPaise),
  );
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  late DateTime _date = widget.existing?.date ?? DateTime.now();
  late PaymentMode _mode = widget.existing?.mode ?? PaymentMode.cash;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.existing == null ? strings.addPayment : strings.edit,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,₹]')),
              ],
              decoration: InputDecoration(
                labelText: '${strings.paymentAmount} (₹)',
              ),
              validator: (value) =>
                  parseRupeesToPaise(value ?? '') == null ||
                      parseRupeesToPaise(value ?? '') == 0
                  ? strings.invalidAmount
                  : null,
            ),
            if (widget.existing == null) ...[
              const SizedBox(height: 8),
              Text(
                strings.advancePaymentHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.fullBalancePaise > 0)
                    ActionChip(
                      label: Text(strings.payFullBalance),
                      onPressed: () => _amountController.text = _amountInput(
                        widget.fullBalancePaise,
                      ),
                    ),
                  for (final amount in [50000, 100000, 200000])
                    ActionChip(
                      label: Text(formatMoney(amount, strings.localeName)),
                      onPressed: () =>
                          _amountController.text = _amountInput(amount),
                    ),
                  for (final amount in [50000, 100000])
                    ActionChip(
                      label: Text(
                        strings.addAdvanceAmount(
                          formatMoney(amount, strings.localeName),
                        ),
                      ),
                      onPressed: () {
                        final paymentAmount =
                            paymentAmountForAdditionalAdvancePaise(
                              balancePaise: widget.fullBalancePaise,
                              additionalAdvancePaise: amount,
                            );
                        _amountController.text = _amountInput(paymentAmount);
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.paymentDate),
              subtitle: Text(formatDate(_date, strings.localeName)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            DropdownButtonFormField<PaymentMode>(
              initialValue: _mode,
              decoration: InputDecoration(labelText: strings.paymentMode),
              items: [
                DropdownMenuItem(
                  value: PaymentMode.cash,
                  child: Text(strings.cash),
                ),
                DropdownMenuItem(
                  value: PaymentMode.upi,
                  child: Text(strings.upi),
                ),
                DropdownMenuItem(
                  value: PaymentMode.bank,
                  child: Text(strings.bank),
                ),
                DropdownMenuItem(
                  value: PaymentMode.other,
                  child: Text(strings.otherPayment),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  setState(() => _mode = mode);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(labelText: strings.paymentNote),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : Text(strings.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => _date = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final strings = AppLocalizations.of(context)!;
    final amount = parseRupeesToPaise(_amountController.text);
    if (amount == null || amount <= 0) {
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = ref.read(paymentRepositoryProvider);
      if (widget.existing == null) {
        await repository.addPayment(
          vendorId: widget.vendorId,
          date: _date,
          amountPaise: amount,
          mode: _mode,
          note: _optionalNote,
        );
      } else {
        await repository.updatePayment(
          widget.existing!.copyWith(
            date: _date,
            amountPaise: amount,
            mode: _mode,
            note: Value(_optionalNote),
          ),
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'save payment',
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

  String? get _optionalNote =>
      _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

  String _amountInput(int amountPaise) =>
      '${amountPaise ~/ 100}.${(amountPaise % 100).toString().padLeft(2, '0')}';
}

class _PaymentsList extends StatelessWidget {
  const _PaymentsList({
    required this.payments,
    required this.locale,
    required this.strings,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Payment> payments;
  final String locale;
  final AppLocalizations strings;
  final ValueChanged<Payment> onEdit;
  final ValueChanged<Payment> onDelete;

  @override
  Widget build(BuildContext context) {
    final grouped = <(int, int), List<Payment>>{};
    for (final payment in payments.reversed) {
      grouped
          .putIfAbsent((payment.date.year, payment.date.month), () => [])
          .add(payment);
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final group in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
            child: Text(
              DateFormat.yMMMM(locale)
                  .format(DateTime(group.key.$1, group.key.$2)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final payment in group.value)
            Card(
              child: ListTile(
                title: Text(
                  formatMoney(payment.amountPaise, locale),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${formatDate(payment.date, locale)} · ${_modeLabel(payment.mode)}',
                ),
                onTap: () => onEdit(payment),
                trailing: IconButton(
                  tooltip: strings.delete,
                  onPressed: () => onDelete(payment),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _modeLabel(PaymentMode mode) => switch (mode) {
    PaymentMode.cash => strings.cash,
    PaymentMode.upi => strings.upi,
    PaymentMode.bank => strings.bank,
    PaymentMode.other => strings.otherPayment,
  };
}
