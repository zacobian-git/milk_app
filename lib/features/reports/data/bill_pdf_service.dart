import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/domain/models/ledger_enums.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BillPdfService {
  const BillPdfService();

  static const _brand = PdfColor.fromInt(0xFF176B63);
  static const _muted = PdfColor.fromInt(0xFF5C6B69);
  static const _rowShade = PdfColor.fromInt(0xFFF1F5F4);

  /// The font is loaded once and reused for every bill.
  static Future<pw.Font>? _font;

  static Future<pw.Font> _loadFont() => _font ??= rootBundle
      .load('assets/fonts/NotoSansDevanagari-Regular.ttf')
      .then(pw.Font.ttf);

  String fileName(MonthlyReportData report) =>
      'doodh-hisaab-${report.vendor.id}-${report.year}-'
      '${report.month.toString().padLeft(2, '0')}.pdf';

  Future<void> shareBill(
    MonthlyReportData report,
    AppLocalizations strings,
  ) async {
    final bytes = await buildBill(report, strings);
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, fileName(report)));
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        text: '${strings.report} · ${report.vendor.name}',
      ),
    );
  }

  /// Opens the system print dialog, which also offers "Save as PDF".
  Future<void> printBill(
    MonthlyReportData report,
    AppLocalizations strings,
  ) async {
    final bytes = await buildBill(report, strings);
    await Printing.layoutPdf(
      name: fileName(report),
      format: PdfPageFormat.a4,
      onLayout: (_) async => bytes,
    );
  }

  /// Sends a short text bill on WhatsApp to the vendor when a phone number is
  /// saved, otherwise opens the normal share sheet with the same text.
  Future<void> shareSummaryText(
    MonthlyReportData report,
    AppLocalizations strings,
  ) async {
    final text = buildSummaryText(report, strings);
    final phone = whatsAppNumber(report.vendor.phone);
    if (phone != null) {
      final uri = Uri.https('wa.me', '/$phone', {'text': text});
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    }
    await SharePlus.instance.share(ShareParams(text: text));
  }

  String buildSummaryText(MonthlyReportData report, AppLocalizations strings) {
    final locale = strings.localeName;
    final summary = report.summary;
    final monthName = DateFormat.yMMMM(
      locale,
    ).format(DateTime(report.year, report.month));
    final closingLabel = summary.closingBalancePaise < 0
        ? strings.advance
        : strings.closingBalance;
    return [
      '*${strings.report}* · ${report.vendor.name}',
      monthName,
      '',
      '${strings.totalLitres}: ${formatLitres(summary.totalQuantityMl)} ${strings.litreUnit}',
      '${strings.deliveredDays}: ${summary.deliveredDays}',
      '${strings.totalAmount}: ${formatMoney(summary.totalAmountPaise, locale)}',
      '${strings.carriedForward}: ${formatMoney(summary.carriedForwardPaise, locale)}',
      '${strings.paid}: ${formatMoney(summary.paidPaise, locale)}',
      '*$closingLabel: ${formatMoney(summary.closingBalancePaise.abs(), locale)}*',
    ].join('\n');
  }

  Future<Uint8List> buildBill(
    MonthlyReportData report,
    AppLocalizations strings,
  ) async {
    final font = await _loadFont();
    final document = pw.Document(
      title: '${strings.report} · ${report.vendor.name}',
    );
    final locale = strings.localeName;
    final summary = report.summary;
    final entries = report.entries.toList()
      ..sort((first, second) => first.date.compareTo(second.date));
    final payments = report.payments.toList()
      ..sort((first, second) => first.date.compareTo(second.date));

    String statusLabel(DailyEntryStatus status) => switch (status) {
      DailyEntryStatus.delivered => strings.delivered,
      DailyEntryStatus.skipped => strings.skipped,
      DailyEntryStatus.custom => strings.customQuantity,
    };

    String modeLabel(PaymentMode mode) => switch (mode) {
      PaymentMode.cash => strings.cash,
      PaymentMode.upi => strings.upi,
      PaymentMode.bank => strings.bank,
      PaymentMode.other => strings.otherPayment,
    };

    pw.Widget summaryRow(String label, String value, {bool strong = false}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: strong ? 12 : 10,
                    color: strong ? PdfColors.black : _muted,
                  ),
                ),
              ),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: strong ? 13 : 10,
                  fontWeight: strong ? pw.FontWeight.bold : null,
                ),
              ),
            ],
          ),
        );

    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
      fontSize: 9,
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              strings.billGeneratedOn(formatDate(DateTime.now(), locale)),
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
            pw.Text(
              '${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ],
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: _brand,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        strings.report,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        report.vendor.name,
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.white,
                        ),
                      ),
                      if (report.vendor.phone?.isNotEmpty ?? false)
                        pw.Text(
                          report.vendor.phone!,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Text(
                  strings.reportMonth(
                    DateFormat.MMMM(
                      locale,
                    ).format(DateTime(report.year, report.month)),
                    report.year,
                  ),
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                summaryRow(
                  strings.totalLitres,
                  '${formatLitres(summary.totalQuantityMl)} ${strings.litreUnit}',
                ),
                summaryRow(
                  strings.deliveredDays,
                  summary.deliveredDays.toString(),
                ),
                summaryRow(strings.skippedDays, summary.skippedDays.toString()),
                summaryRow(
                  strings.totalAmount,
                  formatMoney(summary.totalAmountPaise, locale),
                ),
                summaryRow(
                  strings.carriedForward,
                  formatMoney(summary.carriedForwardPaise, locale),
                ),
                summaryRow(
                  strings.paid,
                  formatMoney(summary.paidPaise, locale),
                ),
                pw.Divider(color: PdfColors.grey300),
                summaryRow(
                  summary.closingBalancePaise < 0
                      ? strings.advance
                      : strings.closingBalance,
                  formatMoney(summary.closingBalancePaise.abs(), locale),
                  strong: true,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            strings.dayByDay,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (entries.isEmpty)
            pw.Text(strings.noReportData)
          else
            pw.TableHelper.fromTextArray(
              headers: [
                strings.date,
                strings.status,
                strings.quantity,
                strings.rate,
                strings.amount,
              ],
              data: [
                for (final entry in entries)
                  [
                    formatDate(entry.date, locale),
                    statusLabel(entry.status),
                    entry.status == DailyEntryStatus.skipped
                        ? '—'
                        : '${formatLitres(entry.quantityMl)} ${strings.litreUnit}',
                    formatMoney(entry.rateUsedPaise, locale),
                    formatMoney(
                      amountForEntry(
                        BillingEntry(
                          date: entry.date,
                          quantityMl: entry.quantityMl,
                          rateUsedPaise: entry.rateUsedPaise,
                          status: entry.status,
                        ),
                      ),
                      locale,
                    ),
                  ],
              ],
              headerStyle: headerStyle,
              headerDecoration: const pw.BoxDecoration(color: _brand),
              oddRowDecoration: const pw.BoxDecoration(color: _rowShade),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {4: pw.Alignment.centerRight},
            ),
          if (payments.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            pw.Text(
              strings.paymentsThisMonth,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: [
                strings.date,
                strings.paymentMode,
                strings.notes,
                strings.amount,
              ],
              data: [
                for (final payment in payments)
                  [
                    formatDate(payment.date, locale),
                    modeLabel(payment.mode),
                    payment.note ?? '',
                    formatMoney(payment.amountPaise, locale),
                  ],
              ],
              headerStyle: headerStyle,
              headerDecoration: const pw.BoxDecoration(color: _brand),
              oddRowDecoration: const pw.BoxDecoration(color: _rowShade),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {3: pw.Alignment.centerRight},
            ),
          ],
        ],
      ),
    );

    return document.save();
  }
}

/// Normalises a saved phone number for wa.me links. Ten-digit Indian numbers
/// get the 91 country code. Returns `null` when there is no usable number.
String? whatsAppNumber(String? phone) {
  if (phone == null) {
    return null;
  }
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0') && digits.length == 11) {
    digits = digits.substring(1);
  }
  if (digits.length == 10) {
    return '91$digits';
  }
  return digits.length >= 11 ? digits : null;
}
