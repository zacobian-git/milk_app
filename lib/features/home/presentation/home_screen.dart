import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/core/widgets/common_widgets.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/domain/utils/ledger_dates.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showingExitConfirmation = false;

  Future<void> _confirmExit() async {
    if (_showingExitConfirmation) {
      return;
    }
    _showingExitConfirmation = true;
    try {
      final strings = AppLocalizations.of(context)!;
      final confirmed = await showConfirmDialog(
        context,
        title: strings.exitApp,
        message: strings.exitAppQuestion,
        confirmLabel: strings.yes,
      );
      if (confirmed && mounted) {
        await SystemNavigator.pop();
      }
    } finally {
      _showingExitConfirmation = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final vendors = ref.watch(activeVendorsProvider);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_confirmExit());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.appTitle),
          actions: [
            IconButton(
              tooltip: strings.settings,
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: vendors.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              ErrorState(onRetry: () => ref.invalidate(activeVendorsProvider)),
          data: (items) => items.isEmpty
              ? EmptyState(
                  icon: Icons.water_drop_rounded,
                  title: strings.onboardingTitle,
                  message: strings.onboardingBody,
                  actionLabel: strings.addFirstVendor,
                  actionIcon: Icons.person_add_alt_1,
                  onAction: () => context.push('/vendors/new'),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    for (final vendor in items) ...[
                      _VendorSummaryCard(
                        key: ValueKey(vendor.id),
                        vendor: vendor,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _VendorSummaryCard extends ConsumerWidget {
  const _VendorSummaryCard({super.key, required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final today = dateOnly(DateTime.now());
    final report = ref.watch(
      monthlyReportProvider((
        vendorId: vendor.id,
        year: today.year,
        month: today.month,
      )),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ref.read(selectedVendorIdProvider.notifier).select(vendor.id);
          context.go('/reports');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  VendorAvatar(name: vendor.name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vendor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 16),
              report.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => Text(
                  strings.errorOccurred,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                data: (data) => Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: strings.totalAmount,
                        value: formatMoney(
                          data.summary.totalAmountPaise,
                          strings.localeName,
                        ),
                      ),
                    ),
                    Expanded(
                      child: StatTile(
                        label: strings.deliveredDays,
                        value: '${data.summary.deliveredDays}',
                      ),
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
}
