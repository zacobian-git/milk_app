import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/core/widgets/common_widgets.dart';
import 'package:milk_app/data/database/database_providers.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';
import 'package:milk_app/features/settings/application/app_settings_provider.dart';
import 'package:milk_app/features/settings/application/reminder_actions.dart';
import 'package:milk_app/l10n/app_localizations.dart';

enum DailyEntryEditorResult { saved, deleted }

/// Picks the status that matches what was actually delivered: a delivery that
/// differs from the vendor's usual quantity is recorded as custom, and a
/// delivery of zero is recorded as no delivery.
DailyEntryStatus resolveEntryStatus({
  required DailyEntryStatus requested,
  required int quantityMl,
  required int defaultQtyMl,
}) {
  if (requested == DailyEntryStatus.skipped || quantityMl == 0) {
    return DailyEntryStatus.skipped;
  }
  return quantityMl == defaultQtyMl
      ? DailyEntryStatus.delivered
      : DailyEntryStatus.custom;
}

/// Opens the editor for one day and handles the follow-up work: reminder
/// rescheduling and an undo action after a delete.
Future<void> showDailyEntryEditor({
  required BuildContext context,
  required WidgetRef ref,
  required Vendor vendor,
  required DateTime date,
  required DailyEntry? existing,
}) async {
  final strings = AppLocalizations.of(context)!;
  final result = await showModalBottomSheet<DailyEntryEditorResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) =>
        DailyEntryEditorSheet(vendor: vendor, date: date, existing: existing),
  );
  if (result == null || !context.mounted) {
    return;
  }
  if (isSameDate(date, DateTime.now())) {
    unawaited(
      scheduleReminderAfterEntryChange(
        ref: ref,
        settings: ref.read(appSettingsProvider).value,
        strings: strings,
      ),
    );
  }
  if (result == DailyEntryEditorResult.deleted && existing != null) {
    showAppSnackBar(
      context,
      strings.entryDeleted,
      actionLabel: strings.undo,
      onAction: () => unawaited(
        ref
            .read(dailyEntryRepositoryProvider)
            .undoEntryChange(
              vendorId: vendor.id,
              date: existing.date,
              previousEntry: existing,
            )
            .catchError(
              (Object error, StackTrace stackTrace) =>
                  reportUiError(error, stackTrace, 'undo deleted daily entry'),
            ),
      ),
    );
  }
}

class DailyEntryEditorSheet extends ConsumerStatefulWidget {
  const DailyEntryEditorSheet({
    super.key,
    required this.vendor,
    required this.date,
    this.existing,
  });

  final Vendor vendor;
  final DateTime date;
  final DailyEntry? existing;

  @override
  ConsumerState<DailyEntryEditorSheet> createState() =>
      _DailyEntryEditorSheetState();
}

class _DailyEntryEditorSheetState extends ConsumerState<DailyEntryEditorSheet> {
  late int _quantityMl = _initialQuantity();
  late bool _delivered =
      widget.existing?.status != DailyEntryStatus.skipped;
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  bool _saving = false;

  int _initialQuantity() {
    final existing = widget.existing;
    if (existing != null && existing.status != DailyEntryStatus.skipped) {
      return existing.quantityMl;
    }
    return widget.vendor.defaultQtyMl;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final step =
        ref.watch(appSettingsProvider.select((s) => s.value?.quantityStepMl)) ??
        250;
    final status = resolveEntryStatus(
      requested: _delivered
          ? DailyEntryStatus.delivered
          : DailyEntryStatus.skipped,
      quantityMl: _quantityMl,
      defaultQtyMl: widget.vendor.defaultQtyMl,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                VendorAvatar(name: widget.vendor.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vendor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        formatDate(widget.date, strings.localeName),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(
                  label: entryStatusLabel(strings, status),
                  color: entryStatusColor(context, status),
                  icon: entryStatusIcon(status),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(strings.markDelivered),
                ),
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.block_rounded),
                  label: Text(strings.markSkipped),
                ),
              ],
              selected: {_delivered},
              onSelectionChanged: (selection) {
                HapticFeedback.selectionClick();
                setState(() {
                  _delivered = selection.first;
                  if (_delivered && _quantityMl == 0) {
                    _quantityMl = widget.vendor.defaultQtyMl;
                  }
                });
              },
            ),
            AnimatedSize(
              duration: kShortAnimation,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _delivered
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: QuantityStepper(
                        quantityMl: _quantityMl,
                        stepMl: step,
                        large: true,
                        onChanged: (value) =>
                            setState(() => _quantityMl = value),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: strings.notes,
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
            if (widget.existing != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: _saving ? null : _delete,
                icon: const Icon(Icons.delete_outline),
                label: Text(strings.delete),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final strings = AppLocalizations.of(context)!;
    final note = _noteController.text.trim();
    try {
      await ref
          .read(dailyEntryRepositoryProvider)
          .saveEntry(
            vendorId: widget.vendor.id,
            date: widget.date,
            quantityMl: _quantityMl,
            status: resolveEntryStatus(
              requested: _delivered
                  ? DailyEntryStatus.delivered
                  : DailyEntryStatus.skipped,
              quantityMl: _quantityMl,
              defaultQtyMl: widget.vendor.defaultQtyMl,
            ),
            note: note.isEmpty ? null : note,
          );
      HapticFeedback.lightImpact();
      if (mounted) {
        Navigator.pop(context, DailyEntryEditorResult.saved);
      }
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'calendar entry');
      if (mounted) {
        showAppSnackBar(
          context,
          error is StateError
              ? strings.bulkEntryMissingRate
              : strings.errorOccurred,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final entry = widget.existing;
    if (entry == null) {
      return;
    }
    final strings = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      message: strings.deleteEntryQuestion,
      confirmLabel: strings.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(dailyEntryRepositoryProvider).deleteEntry(entry.id);
      if (mounted) {
        Navigator.pop(context, DailyEntryEditorResult.deleted);
      }
    } catch (error, stackTrace) {
      reportUiError(error, stackTrace, 'delete daily entry');
      if (mounted) {
        showAppSnackBar(context, strings.errorOccurred);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
