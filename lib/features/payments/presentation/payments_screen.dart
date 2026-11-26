import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/core/widgets/common_widgets.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';
import 'package:milk_app/features/payments/data/payments_provider.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final vendors = ref.watch(activeVendorsProvider);
    final vendorList = vendors.value ?? const <Vendor>[];
    final selectedVendor = vendorList.isEmpty
        ? null
        : resolveSelectedVendor(
            vendorList,
            ref.watch(selectedVendorIdProvider),
          );

    return Scaffold(
      appBar: AppBar(title: Text(strings.tabPayments)),
      body: vendors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            ErrorState(onRetry: () => ref.invalidate(activeVendorsProvider)),
        data: (items) {
          if (items.isEmpty || selectedVendor == null) {
            return EmptyState(
              icon: Icons.payments_rounded,
              title: strings.noVendors,
              message: strings.addFirstVendor,
              actionLabel: strings.addVendor,
              actionIcon: Icons.person_add_alt_1,
              onAction: () => context.push('/vendors/new'),
            );
          }
          final vendor = selectedVendor;
          final payments = ref.watch(allVendorPaymentsProvider);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _VendorDropdown(vendors: items, selected: vendor),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: _BalanceHeader(
                    vendor: vendor,
                    onPayFull: (amount) => showPaymentEditor(
                      context,
                      ref,
                      vendorId: vendor.id,
                      initialAmountPaise: amount,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(strings.paymentHistory),
                ),
              ),
              ...payments.when(
                loading: () => <Widget>[
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (error, stackTrace) => <Widget>[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorState(
                      onRetry: () => ref.invalidate(allVendorPaymentsProvider),
                    ),
                  ),
                ],
                data: (list) => list.isEmpty
                    ? <Widget>[
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(
                            icon: Icons.receipt_long_rounded,
                            title: strings.noPayments,
                          ),
                        ),
                      ]
                    : _paymentSlivers(context, ref, list),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
      ),
      floatingActionButton: selectedVendor == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  showPaymentEditor(context, ref, vendorId: selectedVendor.id),
              icon: const Icon(Icons.add_rounded),
              label: Text(strings.addPayment),
            ),
    );
  }

  List<Widget> _paymentSlivers(
    BuildContext context,
    WidgetRef ref,
    List<({Payment payment, Vendor vendor})> payments,
  ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.separated(
          itemCount: payments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = payments[index];
            return _PaymentTile(
              key: ValueKey(item.payment.id),
              payment: item.payment,
              vendor: item.vendor,
              onTap: () => showPaymentEditor(
                context,
                ref,
                vendorId: item.payment.vendorId,
                payment: item.payment,
              ),
              onDelete: () => _deletePayment(context, ref, item.payment),
            );
          },
        ),
      ),
    ];
  }

  Future<void> _deletePayment(
    BuildContext context,
    WidgetRef ref,
    Payment payment,
  ) async {
    final strings = AppLocalizations.of(context)!;
    final repository = ref.read(paymentRepositoryProvider);
    try {
      await repository.deletePayment(payment.id);
      HapticFeedback.mediumImpact();
      if (context.mounted) {
        showAppSnackBar(
          context,
          strings.paymentDeleted,
          actionLabel: strings.undo,
          onAction: () => unawaited(
            repository
                .restorePayment(payment)
                .then<void>((_) {})
                .catchError(
                  (Object error, StackTrace stackTrace) =>
                      reportUiError(error, stackTrace, 'restore payment'),
                ),
          ),
        );
      }
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'delete payment');
      if (context.mounted) {
        showAppSnackBar(context, strings.errorOccurred);
      }
    }
  }
}

class _VendorDropdown extends ConsumerWidget {
  const _VendorDropdown({required this.vendors, required this.selected});

  final List<Vendor> vendors;
  final Vendor selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: strings.selectVendor,
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: selected.id,
            isExpanded: true,
            items: [
              for (final vendor in vendors)
                DropdownMenuItem(
                  value: vendor.id,
                  child: Text(
                    vendor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (vendorId) {
              if (vendorId != null) {
                ref.read(selectedVendorIdProvider.notifier).select(vendorId);
              }
            },
          ),
        ),
      ),
    );
  }
}

/// Opens the payment editor. The balance shown in quick actions is read from
/// the already-cached ledger, so this opens instantly.
Future<void> showPaymentEditor(
  BuildContext context,
  WidgetRef ref, {
  required int vendorId,
  Payment? payment,
  int? initialAmountPaise,
}) async {
  final strings = AppLocalizations.of(context)!;
  final balance = ref.read(vendorBalanceProvider(vendorId)).value ?? 0;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Material(
      child: PaymentEditorSheet(
        vendorId: vendorId,
        existing: payment,
        fullBalancePaise: balance,
        initialAmountPaise: initialAmountPaise,
      ),
    ),
  );
  if (saved == true && context.mounted) {
    showAppSnackBar(context, strings.paymentSaved);
  }
}

class _BalanceHeader extends ConsumerWidget {
  const _BalanceHeader({required this.vendor, required this.onPayFull});

  final Vendor vendor;
  final ValueChanged<int> onPayFull;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = strings.localeName;
    final balance = ref.watch(vendorBalanceProvider(vendor.id)).value;
    final now = DateTime.now();
    final report = ref
        .watch(
          monthlyReportProvider((
            vendorId: vendor.id,
            year: now.year,
            month: now.month,
          )),
        )
        .value;
    final isDue = (balance ?? 0) > 0;
    final accent = isDue ? colors.error : colors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (balance ?? 0) < 0 ? strings.advance : strings.balance,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: kShortAnimation,
                        child: Text(
                          balance == null
                              ? '—'
                              : formatMoney(balance.abs(), locale),
                          key: ValueKey(balance),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (report != null)
                  Expanded(
                    child: StatTile(
                      label: strings.paymentsThisMonth,
                      value: formatMoney(report.summary.paidPaise, locale),
                    ),
                  ),
              ],
            ),
            if (isDue) ...[
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: () => onPayFull(balance!),
                icon: const Icon(Icons.done_all_rounded),
                label: Text(strings.payFullBalance),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    super.key,
    required this.payment,
    required this.vendor,
    required this.onTap,
    required this.onDelete,
  });

  final Payment payment;
  final Vendor vendor;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = strings.localeName;
    final details = [
      vendor.name,
      formatDate(payment.date, locale),
      paymentModeLabel(strings, payment.mode),
      if (payment.note?.isNotEmpty ?? false) payment.note!,
    ].join(' · ');

    return Dismissible(
      key: ValueKey('payment-${payment.id}'),
      direction: DismissDirection.endToStart,
      // Delete first, then let the row animate away once the list updates.
      confirmDismiss: (_) async {
        await onDelete();
        return true;
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
      ),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: colors.secondaryContainer,
            foregroundColor: colors.onSecondaryContainer,
            child: Icon(paymentModeIcon(payment.mode), size: 20),
          ),
          title: Text(
            formatMoney(payment.amountPaise, locale),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(details, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            tooltip: strings.delete,
            onPressed: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: strings.delete,
                message: strings.deletePaymentQuestion,
                confirmLabel: strings.delete,
                destructive: true,
              );
              if (confirmed) {
                await onDelete();
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ),
      ),
    );
  }
}

class PaymentEditorSheet extends ConsumerStatefulWidget {
  const PaymentEditorSheet({
    super.key,
    required this.vendorId,
    required this.fullBalancePaise,
    this.existing,
    this.initialAmountPaise,
  });

  final int vendorId;
  final int fullBalancePaise;
  final Payment? existing;
  final int? initialAmountPaise;

  @override
  ConsumerState<PaymentEditorSheet> createState() => _PaymentEditorSheetState();
}

class _PaymentEditorSheetState extends ConsumerState<PaymentEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late int _selectedVendorId = widget.existing?.vendorId ?? widget.vendorId;
  late final TextEditingController _amountController = TextEditingController(
    text: switch ((widget.existing, widget.initialAmountPaise)) {
      (final Payment payment, _) => _amountInput(payment.amountPaise),
      (null, final int amount) when amount > 0 => _amountInput(amount),
      _ => '',
    },
  );
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  late DateTime _date = widget.existing?.date ?? dateOnly(DateTime.now());
  late PaymentMode _mode = widget.existing?.mode ?? PaymentMode.cash;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setAmount(int amountPaise) {
    HapticFeedback.selectionClick();
    final text = _amountInput(amountPaise);
    _amountController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = strings.localeName;
    final vendors = ref.watch(activeVendorsProvider).value ?? const <Vendor>[];
    final selectedBalance =
        ref.watch(vendorBalanceProvider(_selectedVendorId)).value ??
        (_selectedVendorId == widget.vendorId ? widget.fullBalancePaise : 0);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? strings.addPayment : strings.edit,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.existing == null) ...[
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: strings.selectVendor,
                    border: const OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedVendorId,
                      isExpanded: true,
                      items: [
                        for (final vendor in vendors)
                          DropdownMenuItem(
                            value: vendor.id,
                            child: Text(
                              vendor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _saving
                          ? null
                          : (vendorId) {
                              if (vendorId != null) {
                                setState(() => _selectedVendorId = vendorId);
                              }
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _amountController,
                autofocus:
                    widget.existing == null &&
                    widget.initialAmountPaise == null,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,₹]')),
                ],
                decoration: InputDecoration(
                  labelText: strings.paymentAmount,
                  prefixText: '₹ ',
                ),
                validator: (value) {
                  final amount = parseRupeesToPaise(value ?? '');
                  return amount == null || amount == 0
                      ? strings.invalidAmount
                      : null;
                },
              ),
              if (widget.existing == null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (selectedBalance > 0)
                      ActionChip(
                        avatar: const Icon(Icons.done_all_rounded, size: 18),
                        label: Text(
                          '${strings.payFullBalance} · '
                          '${formatMoney(selectedBalance, locale)}',
                        ),
                        onPressed: () => _setAmount(selectedBalance),
                      ),
                    for (final amount in [50000, 100000, 200000])
                      ActionChip(
                        label: Text(formatMoney(amount, locale)),
                        onPressed: () => _setAmount(amount),
                      ),
                    for (final amount in [50000, 100000])
                      ActionChip(
                        label: Text(
                          strings.addAdvanceAmount(formatMoney(amount, locale)),
                        ),
                        onPressed: () => _setAmount(
                          paymentAmountForAdditionalAdvancePaise(
                            balancePaise: selectedBalance,
                            additionalAdvancePaise: amount,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  strings.advancePaymentHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Text(strings.paymentMode, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mode in PaymentMode.values)
                    ChoiceChip(
                      avatar: Icon(paymentModeIcon(mode), size: 18),
                      label: Text(paymentModeLabel(strings, mode)),
                      selected: _mode == mode,
                      showCheckmark: false,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() => _mode = mode);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.event_rounded),
                title: Text(strings.paymentDate),
                subtitle: Text(formatDate(_date, locale)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _pickDate,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: strings.paymentNote,
                  prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(strings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (selected != null) {
      setState(() => _date = dateOnly(selected));
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
      final existing = widget.existing;
      if (existing == null) {
        await repository.addPayment(
          vendorId: _selectedVendorId,
          date: _date,
          amountPaise: amount,
          mode: _mode,
          note: _optionalNote,
        );
      } else {
        await repository.updatePayment(
          existing.copyWith(
            date: dateOnly(_date),
            amountPaise: amount,
            mode: _mode,
            note: Value(_optionalNote),
          ),
        );
      }
      HapticFeedback.lightImpact();
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'save payment');
      if (mounted) {
        showAppSnackBar(context, strings.errorOccurred);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? get _optionalNote =>
      _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

  static String _amountInput(int amountPaise) {
    final rupees = amountPaise ~/ 100;
    final paise = amountPaise % 100;
    return paise == 0
        ? '$rupees'
        : '$rupees.${paise.toString().padLeft(2, '0')}';
  }
}
