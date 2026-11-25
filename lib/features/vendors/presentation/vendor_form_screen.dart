import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/data/repositories/vendor_repository.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class VendorFormScreen extends ConsumerStatefulWidget {
  const VendorFormScreen({super.key, this.vendorId});

  final int? vendorId;

  @override
  ConsumerState<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends ConsumerState<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _rateController = TextEditingController(text: '70');
  final _openingController = TextEditingController(text: '0');
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  String _milkType = 'cow';
  bool _saving = false;
  late final Future<Vendor?> _vendorFuture;

  @override
  void initState() {
    super.initState();
    _vendorFuture = widget.vendorId == null
        ? Future.value(null)
        : ref.read(vendorRepositoryProvider).getVendor(widget.vendorId!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _openingController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _fill(Vendor? vendor) {
    if (vendor == null || _nameController.text.isNotEmpty) {
      return;
    }
    _nameController.text = vendor.name;
    _phoneController.text = vendor.phone ?? '';
    _quantityController.text = formatLitres(vendor.defaultQtyMl);
    _openingController.text = (vendor.openingBalancePaise ~/ 100).toString();
    _timeController.text = vendor.deliveryTime ?? '';
    _notesController.text = vendor.notes ?? '';
    _milkType = vendor.milkType;
  }

  Future<void> _save(VendorRepository repository, Vendor? existing) async {
    final strings = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final quantityMl = parseLitresToMl(_quantityController.text);
    final openingBalancePaise = parseRupeesToPaise(_openingController.text);
    final ratePaise = parseRupeesToPaise(_rateController.text);
    if (quantityMl == null ||
        openingBalancePaise == null ||
        (existing == null && ratePaise == null)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.invalidAmount)));
      return;
    }

    setState(() => _saving = true);
    try {
      if (existing == null) {
        await repository.addVendorWithRate(
          name: _nameController.text,
          milkType: _milkType,
          defaultQtyMl: quantityMl,
          ratePerLitrePaise: ratePaise!,
          effectiveFrom: DateTime.now(),
          phone: _optional(_phoneController.text),
          deliveryTime: _optional(_timeController.text),
          notes: _optional(_notesController.text),
          openingBalancePaise: openingBalancePaise,
        );
      } else {
        await repository.updateVendor(
          existing.copyWith(
            name: _nameController.text.trim(),
            phone: Value(_optional(_phoneController.text)),
            milkType: _milkType,
            defaultQtyMl: quantityMl,
            deliveryTime: Value(_optional(_timeController.text)),
            notes: Value(_optional(_notesController.text)),
            openingBalancePaise: openingBalancePaise,
          ),
        );
      }
      ref.invalidate(activeVendorsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.vendorSaved)));
        context.pop();
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'vendor form',
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

  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final repository = ref.read(vendorRepositoryProvider);
    return FutureBuilder<Vendor?>(
      future: _vendorFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(strings.editVendor)),
            body: Center(child: Text(strings.errorOccurred)),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(strings.vendorDetails)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final existing = snapshot.data;
        if (widget.vendorId != null && existing == null) {
          return Scaffold(
            appBar: AppBar(title: Text(strings.vendorDetails)),
            body: Center(child: Text(strings.errorOccurred)),
          );
        }
        _fill(existing);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              existing == null ? strings.addVendor : strings.editVendor,
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _textField(
                    controller: _nameController,
                    label: strings.vendorName,
                    hint: strings.vendorNameHint,
                    required: true,
                  ),
                  _textField(
                    controller: _phoneController,
                    label: strings.phoneNumber,
                    keyboardType: TextInputType.phone,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _milkType,
                    decoration: InputDecoration(labelText: strings.milkType),
                    items: [
                      DropdownMenuItem(
                        value: 'cow',
                        child: Text(strings.cowMilk),
                      ),
                      DropdownMenuItem(
                        value: 'buffalo',
                        child: Text(strings.buffaloMilk),
                      ),
                      DropdownMenuItem(
                        value: 'mixed',
                        child: Text(strings.mixedMilk),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(strings.otherMilk),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _milkType = value ?? 'cow'),
                  ),
                  _textField(
                    controller: _quantityController,
                    label: '${strings.defaultQuantity} (${strings.litreUnit})',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    required: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                  ),
                  if (existing == null)
                    _textField(
                      controller: _rateController,
                      label: '${strings.ratePerLitre} (₹)',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      required: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                    ),
                  _textField(
                    controller: _openingController,
                    label: '${strings.openingBalance} (₹)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                  ),
                  _textField(
                    controller: _timeController,
                    label: strings.deliveryTime,
                    hint: '08:00',
                  ),
                  _textField(
                    controller: _notesController,
                    label: strings.notes,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _saving
                        ? null
                        : () => _save(repository, existing),
                    child: _saving
                        ? const CircularProgressIndicator()
                        : Text(strings.save),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? AppLocalizations.of(context)!.requiredField
                : null
          : null,
    ),
  );
}
