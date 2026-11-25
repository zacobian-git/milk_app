import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
        error: (error, stackTrace) => _ErrorMessage(
          message: strings.errorOccurred,
          retry: () => ref.invalidate(activeVendorsProvider),
        ),
        data: (items) => items.isEmpty
            ? _EmptyVendors(
                title: strings.noVendors,
                message: strings.addFirstVendor,
                addLabel: strings.addVendor,
                onAdd: () => context.push('/vendors/new'),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final vendor = items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                vendor.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${formatLitres(vendor.defaultQtyMl)} ${strings.litreUnit}'
                                ' · ${formatMoney(vendor.openingBalancePaise, strings.localeName)}',
                              ),
                              onTap: () =>
                                  context.push('/vendors/${vendor.id}/edit'),
                            ),
                          ),
                          IconButton(
                            tooltip: strings.rateHistory,
                            onPressed: () =>
                                context.push('/vendors/${vendor.id}/rates'),
                            icon: const Icon(Icons.receipt_long_outlined),
                          ),
                          if (vendor.phone?.isNotEmpty ?? false)
                            IconButton(
                              tooltip: strings.callVendor,
                              onPressed: () => launchUrl(
                                Uri(scheme: 'tel', path: vendor.phone),
                              ),
                              icon: const Icon(Icons.call_outlined),
                            ),
                          PopupMenuButton<String>(
                            tooltip: strings.edit,
                            onSelected: (action) async {
                              if (action == 'edit') {
                                if (context.mounted) {
                                  context.push('/vendors/${vendor.id}/edit');
                                }
                              } else if (action == 'message') {
                                final phone = vendor.phone!.replaceAll(
                                  RegExp(r'\D'),
                                  '',
                                );
                                final normalizedPhone = phone.length == 10
                                    ? '91$phone'
                                    : phone;
                                await launchUrl(
                                  Uri.https('wa.me', '/$normalizedPhone'),
                                );
                              } else if (action == 'delete') {
                                final confirmed =
                                    await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(strings.deleteVendor),
                                        content: Text(
                                          strings.deleteVendorQuestion(
                                            vendor.name,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(strings.cancel),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(strings.confirm),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                                if (confirmed && context.mounted) {
                                  await ref
                                      .read(vendorRepositoryProvider)
                                      .archiveVendor(vendor.id);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(strings.edit),
                              ),
                              if (vendor.phone?.isNotEmpty ?? false)
                                PopupMenuItem(
                                  value: 'message',
                                  child: Text(strings.messageVendor),
                                ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline),
                                    const SizedBox(width: 8),
                                    Text(strings.deleteVendor),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

class _EmptyVendors extends StatelessWidget {
  const _EmptyVendors({
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
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_drink_outlined, size: 64),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(addLabel),
          ),
        ],
      ),
    ),
  );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.retry});

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
