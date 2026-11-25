import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/data/repositories/vendor_repository.dart';
import 'package:milk_app/features/vendors/presentation/vendor_list_screen.dart'
    show milkTypeLabel;
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
    final opening = vendor.openingBalancePaise;
    _openingController.text = opening % 100 == 0
        ? '${opening ~/ 100}'
        : '${opening ~/ 100}.${(opening % 100).toString().padLeft(2, '0')}';
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
        (existing == null && (ratePaise == null || ratePaise <= 0))) {
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

  Future<void> _pickTime() async {
    final parts = _timeController.text.split(':');
    final initial = parts.length == 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 7,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : const TimeOfDay(hour: 7, minute: 0);
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected != null) {
      _timeController.text =
          '${selected.hour.toString().padLeft(2, '0')}:'
          '${selected.minute.toString().padLeft(2, '0')}';
    }
  }

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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Text(
                      strings.milkType,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final type in const [
                          'cow',
                          'buffalo',
                          'mixed',
                          'other',
                        ])
                          ChoiceChip(
                            label: Text(milkTypeLabel(strings, type)),
                            selected: _milkType == type,
                            onSelected: (_) =>
                                setState(() => _milkType = type),
                          ),
                      ],
                    ),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: InputDecoration(
                        labelText: strings.deliveryTime,
                        hintText: strings.notSet,
                        prefixIcon: const Icon(Icons.schedule_rounded),
                        suffixIcon: ValueListenableBuilder(
                          valueListenable: _timeController,
                          builder: (context, value, child) =>
                              value.text.isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                  tooltip: strings.clear,
                                  onPressed: _timeController.clear,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                    ),
                  ),
                  _textField(
                    controller: _notesController,
                    label: strings.notes,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _save(repository, existing),
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(strings.save),
                  ),
                  if (existing != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/vendors/${existing.id}/rates'),
                      icon: const Icon(Icons.price_change_outlined),
                      label: Text(strings.rateHistory),
                    ),
                  ],
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
