import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/providers/ledger_providers.dart';
import 'package:milk_app/core/theme/app_theme.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/core/widgets/common_widgets.dart';
import 'package:milk_app/core/widgets/motion.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';

/// Cards beyond this index appear without a stagger delay, so long lists
/// never make the person wait.
const int _maxStaggeredItems = 6;

Duration _stagger(int index) =>
    Duration(milliseconds: 60 * index.clamp(0, _maxStaggeredItems));

MonthSelection _currentMonth(int vendorId) {
  final today = DateTime.now();
  return (vendorId: vendorId, year: today.year, month: today.month);
}

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
        body: AnimatedSwitcher(
          duration: kShortAnimation,
          child: vendors.when(
            loading: () => const Center(
              key: ValueKey('loading'),
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => ErrorState(
              key: const ValueKey('error'),
              onRetry: () => ref.invalidate(activeVendorsProvider),
            ),
            data: (items) => items.isEmpty
                ? EntranceAnimation(
                    key: const ValueKey('empty'),
                    child: EmptyState(
                      icon: Icons.water_drop_rounded,
                      title: strings.onboardingTitle,
                      message: strings.onboardingBody,
                      actionLabel: strings.addFirstVendor,
                      actionIcon: Icons.person_add_alt_1,
                      onAction: () => context.push('/vendors/new'),
                    ),
                  )
                : _Dashboard(key: const ValueKey('dashboard'), vendors: items),
          ),
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({super.key, required this.vendors});

  final List<Vendor> vendors;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverList.list(
            children: [
              EntranceAnimation(child: _DashboardHero(vendors: vendors)),
              const SizedBox(height: 16),
              const _QuickActions(),
              SectionHeader(strings.tabVendors),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.separated(
            itemCount: vendors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final vendor = vendors[index];
              return EntranceAnimation(
                key: ValueKey(vendor.id),
                delay: _stagger(index + 2),
                child: _VendorSummaryCard(vendor: vendor),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero: greeting, this month's total and the overall balance
// ---------------------------------------------------------------------------

class _DashboardTotals {
  const _DashboardTotals({
    required this.monthAmountPaise,
    required this.monthQuantityMl,
    required this.balancePaise,
  });

  final int monthAmountPaise;
  final int monthQuantityMl;
  final int balancePaise;
}

class _DashboardHero extends ConsumerWidget {
  const _DashboardHero({required this.vendors});

  final List<Vendor> vendors;

  /// Sums whatever has loaded so far; the figures animate up as each
  /// vendor's ledger arrives, rather than waiting for all of them.
  _DashboardTotals _totals(WidgetRef ref) {
    var amount = 0;
    var quantity = 0;
    var balance = 0;
    for (final vendor in vendors) {
      final summary = ref
          .watch(monthlyReportProvider(_currentMonth(vendor.id)))
          .value
          ?.summary;
      amount += summary?.totalAmountPaise ?? 0;
      quantity += summary?.totalQuantityMl ?? 0;
      balance += ref.watch(vendorBalanceProvider(vendor.id)).value ?? 0;
    }
    return _DashboardTotals(
      monthAmountPaise: amount,
      monthQuantityMl: quantity,
      balancePaise: balance,
    );
  }

  String _greeting(AppLocalizations strings) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return strings.goodMorning;
    }
    if (hour < 17) {
      return strings.goodAfternoon;
    }
    return strings.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final totals = _totals(ref);
    final isDark = theme.brightness == Brightness.dark;
    final onHero = isDark ? colors.onPrimaryContainer : colors.onPrimary;
    final monthLabel = DateFormat.yMMMM(strings.localeName)
        .format(DateTime.now());
    final hasAdvance = totals.balancePaise < 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [colors.primaryContainer, colors.surfaceContainerHigh]
              : [
                  colors.primary,
                  Color.lerp(colors.primary, Colors.black, 0.35)!,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.15 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MilkWave(color: onHero),
            ),
            Positioned(
              right: -24,
              top: -24,
              child: Icon(
                Icons.water_drop_rounded,
                size: 140,
                color: onHero.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(strings),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: onHero,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${strings.currentMonth} · $monthLabel',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onHero.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: AnimatedMoney(
                      amountPaise: totals.monthAmountPaise,
                      locale: strings.localeName,
                      compact: true,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: onHero,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Text(
                    strings.totalAmount,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: onHero.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroStat(
                          icon: Icons.water_drop_outlined,
                          label: strings.totalLitres,
                          value:
                              '${formatLitres(totals.monthQuantityMl)} ${strings.litreUnit}',
                          color: onHero,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HeroStat(
                          icon: hasAdvance
                              ? Icons.savings_outlined
                              : Icons.account_balance_wallet_outlined,
                          label: hasAdvance
                              ? strings.totalAdvance
                              : strings.totalDue,
                          valueWidget: AnimatedMoney(
                            amountPaise: totals.balancePaise.abs(),
                            locale: strings.localeName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: onHero,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          color: onHero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.color,
    this.value,
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color.withValues(alpha: 0.85)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child:
                valueWidget ??
                Text(
                  value ?? '',
                  maxLines: 1,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions
// ---------------------------------------------------------------------------

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final actions = [
      (
        Icons.calendar_month_rounded,
        strings.calendar,
        () => context.go('/calendar'),
      ),
      (
        Icons.add_card_rounded,
        strings.addPayment,
        () => context.go('/payments'),
      ),
      (
        Icons.receipt_long_rounded,
        strings.report,
        () => context.go('/reports'),
      ),
      (
        Icons.person_add_alt_1_rounded,
        strings.addVendor,
        () => context.push('/vendors/new'),
      ),
    ];
    return Semantics(
      label: strings.quickActions,
      container: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < actions.length; index++)
            Expanded(
              child: EntranceAnimation(
                delay: _stagger(index + 1),
                offset: const Offset(0, 0.25),
                child: _QuickActionButton(
                  icon: actions[index].$1,
                  label: actions[index].$2,
                  onTap: actions[index].$3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return PressableScale(
      scale: 0.92,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vendor cards
// ---------------------------------------------------------------------------

class _VendorSummaryCard extends ConsumerWidget {
  const _VendorSummaryCard({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final report = ref.watch(monthlyReportProvider(_currentMonth(vendor.id)));
    final balance = ref.watch(vendorBalanceProvider(vendor.id)).value;

    return PressableScale(
      child: Card(
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
                    _GradientAvatar(name: vendor.name),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        vendor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (balance != null && balance != 0)
                      StatusPill(
                        label: formatMoney(balance.abs(), strings.localeName),
                        icon: balance > 0
                            ? Icons.arrow_upward_rounded
                            : Icons.savings_outlined,
                        color: balance > 0
                            ? colors.error
                            : AppTheme.positiveColor(context),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedSize(
                  duration: kShortAnimation,
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: report.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stackTrace) => Text(
                      strings.errorOccurred,
                      style: TextStyle(color: colors.error),
                    ),
                    data: (data) => _VendorCardBody(data: data),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VendorCardBody extends StatelessWidget {
  const _VendorCardBody({required this.data});

  final MonthlyReportData data;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final summary = data.summary;
    final daysSoFar = DateTime.now().day;
    final delivered = summary.deliveredDays.clamp(0, daysSoFar);
    final progress = daysSoFar == 0 ? 0.0 : delivered / daysSoFar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.totalAmount,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: AnimatedMoney(
                      amountPaise: summary.totalAmountPaise,
                      locale: strings.localeName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatLitres(summary.totalQuantityMl)} ${strings.litreUnit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Tooltip(
                message: strings.spendingLastSixMonths,
                child: MiniBarChart(
                  values: [for (final item in data.insights) item.amountPaise],
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                strings.monthProgress(delivered, daysSoFar),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            if (summary.skippedDays > 0)
              Text(
                '${strings.skippedDays}: ${summary.skippedDays}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _AnimatedProgressBar(value: progress, color: colors.primary),
      ],
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget bar(double progress) => ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        color: color,
        backgroundColor: color.withValues(alpha: 0.12),
      ),
    );
    if (!motionEnabled(context)) {
      return bar(value);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => bar(progress),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  const _GradientAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.tertiary],
        ),
      ),
      child: Text(
        vendorInitial(name),
        style: TextStyle(
          color: colors.onPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}
