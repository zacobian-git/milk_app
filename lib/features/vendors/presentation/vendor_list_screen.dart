import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/core/widgets/common_widgets.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/features/reports/data/bill_pdf_service.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

enum _VendorAction { edit, rates, message, delete }

String milkTypeLabel(AppLocalizations strings, String milkType) =>
    switch (milkType) {
      'cow' => strings.cowMilk,
      'buffalo' => strings.buffaloMilk,
      'mixed' => strings.mixedMilk,
      _ => strings.otherMilk,
    };

class VendorListScreen extends ConsumerWidget {
  const VendorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final vendors = ref.watch(activeVendorsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.tabVendors)),
      body: vendors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            ErrorState(onRetry: () => ref.invalidate(activeVendorsProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.storefront_rounded,
                title: strings.noVendors,
                message: strings.addFirstVendor,
                actionLabel: strings.addVendor,
                actionIcon: Icons.person_add_alt_1,
                onAction: () => context.push('/vendors/new'),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  for (final vendor in items) ...[
                    _VendorCard(key: ValueKey(vendor.id), vendor: vendor),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vendors/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(strings.addVendor),
      ),
    );
  }
}

class _VendorCard extends ConsumerWidget {
  const _VendorCard({super.key, required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = strings.localeName;
    final balance = ref.watch(vendorBalanceProvider(vendor.id)).value;
    final rates = ref.watch(vendorRateHistoryProvider(vendor.id)).value;
    final currentRate = rates == null
        ? null
        : rateForDate(rates, DateTime.now());
    final hasPhone = vendor.phone?.trim().isNotEmpty ?? false;

    final details = [
      milkTypeLabel(strings, vendor.milkType),
      '${formatLitres(vendor.defaultQtyMl)} ${strings.litreUnit}',
      if (currentRate != null)
        '${formatMoney(currentRate, locale)}/${strings.litreUnit}',
      if (vendor.deliveryTime?.isNotEmpty ?? false) vendor.deliveryTime!,
    ].join(' · ');

    return Card(
      child: InkWell(
        onTap: () => context.push('/vendors/${vendor.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          details,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_VendorAction>(
                    tooltip: strings.edit,
                    onSelected: (action) =>
                        _onAction(context, ref, action, hasPhone),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _VendorAction.edit,
                        child: ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: Text(strings.edit),
                        ),
                      ),
                      PopupMenuItem(
                        value: _VendorAction.rates,
                        child: ListTile(
                          leading: const Icon(Icons.price_change_outlined),
                          title: Text(strings.rateHistory),
                        ),
                      ),
                      if (hasPhone)
                        PopupMenuItem(
                          value: _VendorAction.message,
                          child: ListTile(
                            leading: const Icon(Icons.chat_outlined),
                            title: Text(strings.messageVendor),
                          ),
                        ),
                      PopupMenuItem(
                        value: _VendorAction.delete,
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: colors.error,
                          ),
                          title: Text(
                            strings.deleteVendor,
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: (balance ?? 0) < 0
                            ? strings.advance
                            : strings.balance,
                        value: balance == null
                            ? '—'
                            : formatMoney(balance.abs(), locale),
                        valueColor: (balance ?? 0) > 0
                            ? colors.error
                            : colors.primary,
                      ),
                    ),
                    if (hasPhone)
                      IconButton.filledTonal(
                        tooltip: strings.callVendor,
                        onPressed: () => launchUrl(
                          Uri(scheme: 'tel', path: vendor.phone!.trim()),
                        ),
                        icon: const Icon(Icons.call_outlined),
                      ),
                    const SizedBox(width: 4),
                    IconButton.filledTonal(
                      tooltip: strings.rateHistory,
                      onPressed: () =>
                          context.push('/vendors/${vendor.id}/rates'),
                      icon: const Icon(Icons.price_change_outlined),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _VendorAction action,
    bool hasPhone,
  ) async {
    final strings = AppLocalizations.of(context)!;
    switch (action) {
      case _VendorAction.edit:
        context.push('/vendors/${vendor.id}/edit');
      case _VendorAction.rates:
        context.push('/vendors/${vendor.id}/rates');
      case _VendorAction.message:
        final phone = whatsAppNumber(vendor.phone);
        if (phone != null) {
          await launchUrl(
            Uri.https('wa.me', '/$phone'),
            mode: LaunchMode.externalApplication,
          );
        }
      case _VendorAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.deleteVendor),
            content: Text(strings.deleteVendorQuestion(vendor.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.no),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(strings.yes),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) {
          return;
        }
        final repository = ref.read(vendorRepositoryProvider);
        try {
          await repository.deleteVendor(vendor.id);
          if (context.mounted) {
            showAppSnackBar(context, strings.vendorDeleted);
          }
        } catch (error, stackTrace) {
          reportUiError(error, stackTrace, 'delete vendor');
          if (context.mounted) {
            showAppSnackBar(context, strings.errorOccurred);
          }
        }
    }
  }
}
