import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/theme/app_theme.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/l10n/app_localizations.dart';

const Duration kShortAnimation = Duration(milliseconds: 220);

// ---------------------------------------------------------------------------
// Status helpers
// ---------------------------------------------------------------------------

Color entryStatusColor(BuildContext context, DailyEntryStatus? status) {
  final colors = Theme.of(context).colorScheme;
  return switch (status) {
    DailyEntryStatus.delivered => colors.primary,
    DailyEntryStatus.skipped => colors.error,
    DailyEntryStatus.custom => AppTheme.customColor(context),
    null => colors.outline,
  };
}

IconData entryStatusIcon(DailyEntryStatus? status) => switch (status) {
  DailyEntryStatus.delivered => Icons.check_rounded,
  DailyEntryStatus.skipped => Icons.close_rounded,
  DailyEntryStatus.custom => Icons.water_drop_outlined,
  null => Icons.circle_outlined,
};

String entryStatusLabel(AppLocalizations strings, DailyEntryStatus? status) =>
    switch (status) {
      DailyEntryStatus.delivered => strings.delivered,
      DailyEntryStatus.skipped => strings.skipped,
      DailyEntryStatus.custom => strings.customQuantity,
      null => strings.unmarked,
    };

String paymentModeLabel(AppLocalizations strings, PaymentMode mode) =>
    switch (mode) {
      PaymentMode.cash => strings.cash,
      PaymentMode.upi => strings.upi,
      PaymentMode.bank => strings.bank,
      PaymentMode.other => strings.otherPayment,
    };

IconData paymentModeIcon(PaymentMode mode) => switch (mode) {
  PaymentMode.cash => Icons.payments_outlined,
  PaymentMode.upi => Icons.qr_code_2_rounded,
  PaymentMode.bank => Icons.account_balance_outlined,
  PaymentMode.other => Icons.more_horiz_rounded,
};

// ---------------------------------------------------------------------------
// Feedback helpers
// ---------------------------------------------------------------------------

void reportUiError(Object error, StackTrace stackTrace, String library) {
  FlutterError.reportError(
    FlutterErrorDetails(exception: error, stack: stackTrace, library: library),
  );
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String message,
  String? title,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final strings = AppLocalizations.of(context)!;
  final colors = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(strings.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                  minimumSize: const Size(48, 44),
                )
              : FilledButton.styleFrom(minimumSize: const Size(48, 44)),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel ?? strings.confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ---------------------------------------------------------------------------
// Layout building blocks
// ---------------------------------------------------------------------------

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 10),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon ?? Icons.add),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(strings.errorOccurred, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            maxLines: 1,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: kShortAnimation,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

/// Horizontal chips to switch vendors. Hidden when there is only one vendor,
/// because there is nothing to choose.
class VendorSelector extends ConsumerWidget {
  const VendorSelector({
    super.key,
    required this.vendors,
    required this.selected,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 8),
  });

  final List<Vendor> vendors;
  final Vendor selected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vendors.length < 2) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: vendors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          final isSelected = vendor.id == selected.id;
          return ChoiceChip(
            avatar: isSelected
                ? null
                : CircleAvatar(child: Text(vendorInitial(vendor.name))),
            label: Text(vendor.name),
            selected: isSelected,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              ref.read(selectedVendorIdProvider.notifier).select(vendor.id);
            },
          );
        },
      ),
    );
  }
}

String vendorInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}

class VendorAvatar extends StatelessWidget {
  const VendorAvatar({super.key, required this.name, this.radius = 22});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      child: Text(
        vendorInitial(name),
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: radius * 0.8),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quantity input
// ---------------------------------------------------------------------------

/// A − value + control. Tapping the value lets the person type an exact
/// quantity, which is faster than tapping + many times.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantityMl,
    required this.stepMl,
    required this.onChanged,
    this.large = false,
    this.enabled = true,
  });

  final int quantityMl;
  final int stepMl;
  final ValueChanged<int> onChanged;
  final bool large;
  final bool enabled;

  static const int maxQuantityMl = 50000;

  void _change(int value) {
    final clamped = value.clamp(0, maxQuantityMl);
    if (clamped != quantityMl) {
      HapticFeedback.selectionClick();
      onChanged(clamped);
    }
  }

  Future<void> _typeExact(BuildContext context) async {
    final strings = AppLocalizations.of(context)!;
    final value = await showDialog<int>(
      context: context,
      builder: (context) => _ExactQuantityDialog(
        initialMl: quantityMl,
        title: strings.changeQuantity,
        unit: strings.litreUnit,
      ),
    );
    if (value != null) {
      _change(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textStyle =
        (large ? theme.textTheme.headlineMedium : theme.textTheme.titleLarge)
            ?.copyWith(fontWeight: FontWeight.w800);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          tooltip: strings.changeQuantity,
          onPressed: enabled && quantityMl > 0
              ? () => _change(quantityMl - stepMl)
              : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        Flexible(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? () => _typeExact(context) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: AnimatedSwitcher(
                duration: kShortAnimation,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.85, end: 1.0).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  '${formatLitres(quantityMl)} ${strings.litreUnit}',
                  key: ValueKey(quantityMl),
                  maxLines: 1,
                  style: textStyle,
                ),
              ),
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: strings.changeQuantity,
          onPressed: enabled && quantityMl < maxQuantityMl
              ? () => _change(quantityMl + stepMl)
              : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _ExactQuantityDialog extends StatefulWidget {
  const _ExactQuantityDialog({
    required this.initialMl,
    required this.title,
    required this.unit,
  });

  final int initialMl;
  final String title;
  final String unit;

  @override
  State<_ExactQuantityDialog> createState() => _ExactQuantityDialogState();
}

class _ExactQuantityDialogState extends State<_ExactQuantityDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: formatLitres(widget.initialMl),
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseLitresToMl(_controller.text);
    if (value == null || value > QuantityStepper.maxQuantityMl) {
      setState(
        () => _error = AppLocalizations.of(context)!.invalidQuantity,
      );
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
        decoration: InputDecoration(
          suffixText: widget.unit,
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
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
