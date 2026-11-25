import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class MonthlyInsights extends StatelessWidget {
  const MonthlyInsights({
    super.key,
    required this.insights,
    required this.locale,
    required this.strings,
  });

  final List<MonthlyInsight> insights;
  final String locale;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          strings.insights,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      _InsightChart(
        title: strings.monthlySpend,
        insights: insights,
        locale: locale,
        valueFor: (insight) => insight.amountPaise,
        formatValue: (value) => NumberFormat.compactCurrency(
          locale: locale == 'hi' ? 'hi_IN' : 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        ).format(value / 100),
      ),
      _InsightChart(
        title: strings.monthlyLitres,
        insights: insights,
        locale: locale,
        valueFor: (insight) => insight.quantityMl,
        formatValue: (value) =>
            '${formatLitres(value.round())} ${strings.litreUnit}',
      ),
    ],
  );
}

class _InsightChart extends StatelessWidget {
  const _InsightChart({
    required this.title,
    required this.insights,
    required this.locale,
    required this.valueFor,
    required this.formatValue,
  });

  final String title;
  final List<MonthlyInsight> insights;
  final String locale;
  final int Function(MonthlyInsight) valueFor;
  final String Function(double) formatValue;

  @override
  Widget build(BuildContext context) {
    final maximumValue = insights.fold<int>(
      0,
      (maximum, insight) =>
          valueFor(insight) > maximum ? valueFor(insight) : maximum,
    );
    final maximum = maximumValue == 0 ? 1.0 : maximumValue * 1.15;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 164,
              child: BarChart(
                BarChartData(
                  maxY: maximum,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (var index = 0; index < insights.length; index++)
                      BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: valueFor(insights[index]).toDouble(),
                            color: Theme.of(context).colorScheme.primary,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: maximum / 3,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: Text(
                            formatValue(value),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (value != index ||
                              index < 0 ||
                              index >= insights.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            space: 4,
                            child: Text(
                              DateFormat.MMM(locale)
                                  .format(insights[index].month),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
