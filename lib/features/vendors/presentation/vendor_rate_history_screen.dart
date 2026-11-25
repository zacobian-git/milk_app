import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/data/repositories/vendor_repository.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class VendorRateHistoryScreen extends ConsumerWidget {
  const VendorRateHistoryScreen({super.key, required this.vendorId});

  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final repository = ref.watch(vendorRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.rateHistory)),
      body: FutureBuilder<(Vendor?, List<MilkRate>)>(
        future: _load(repository),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(strings.errorOccurred));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final vendor = snapshot.data!.$1;
          final rates = snapshot.data!.$2;
          if (vendor == null) {
            return Center(child: Text(strings.errorOccurred));
          }
          if (rates.isEmpty) {
            return Center(child: Text(strings.noRateHistory));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rates.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final rate = rates[index];
              return ListTile(
                title: Text(
                  formatMoney(rate.ratePerLitrePaise, strings.localeName),
                ),
                subtitle: Text(
                  formatDate(rate.effectiveFrom, strings.localeName),
                ),
                trailing: index == rates.length - 1 ? Text(vendor.name) : null,
              );
            },
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

  Future<(Vendor?, List<MilkRate>)> _load(VendorRepository repository) async =>
      (
        await repository.getVendor(vendorId),
        await repository.getRateHistory(vendorId),
      );

  Future<void> _addRate(BuildContext context, WidgetRef ref) async {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.rateSaved)),
        );
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred)),
        );
      }
    }
  }
}

class _RateDialog extends StatefulWidget {
  const _RateDialog();

  @override
  State<_RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<_RateDialog> {
  final _controller = TextEditingController();
  DateTime _effectiveDate = DateTime.now();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(strings.changeRate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            decoration: InputDecoration(
              labelText: '${strings.ratePerLitre} (₹)',
            ),
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
                setState(() => _effectiveDate = date);
              }
            },
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              '${strings.effectiveFrom}: ${formatDate(_effectiveDate, strings.localeName)}',
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
          onPressed: () {
            final rate = parseRupeesToPaise(_controller.text);
            if (rate == null) {
              return;
            }
            Navigator.pop(context, (rate: rate, date: _effectiveDate));
          },
          child: Text(strings.save),
        ),
      ],
    );
  }
}
