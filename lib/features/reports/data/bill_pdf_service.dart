import 'dart:io';

import 'package:flutter/services.dart';
import 'package:milk_app/core/utils/formatters.dart';
import 'package:milk_app/domain/billing/billing_calculator.dart';
import 'package:milk_app/domain/models/billing_models.dart';
import 'package:milk_app/features/reports/data/report_providers.dart';
import 'package:milk_app/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class BillPdfService {
  const BillPdfService();

  Future<void> shareBill(
    MonthlyReportData report,
    AppLocalizations strings,
  ) async {
    final bytes = await buildBill(report, strings);
    final directory = await getTemporaryDirectory();
    final file = File(
      p.join(
        directory.path,
        'doodh-hisaab-${report.vendor.id}-${report.year}-${report.month}.pdf',
      ),
    );
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        text: '${strings.report} · ${report.vendor.name}',
      ),
    );
  }

  Future<Uint8List> buildBill(
    MonthlyReportData report,
    AppLocalizations strings,
  ) async {
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansDevanagari-Regular.ttf',
    );
    final font = pw.Font.ttf(fontData);
    final document = pw.Document();
    final locale = strings.localeName;
    final entries = report.entries.toList()
      ..sort((first, second) => first.date.compareTo(second.date));

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => [
          pw.Text(
            strings.report,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(report.vendor.name),
          pw.Text(
            strings.reportMonth(
              DateFormat.MMMM(locale)
                  .format(DateTime(report.year, report.month)),
              report.year,
            ),
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Divider(),
          pw.Text(
            '${strings.totalLitres}: '
            '${formatLitres(report.summary.totalQuantityMl)} ${strings.litreUnit}',
          ),
          pw.Text(
            '${strings.totalAmount}: '
            '${formatMoney(report.summary.totalAmountPaise, locale)}',
          ),
          pw.Text(
            '${strings.paid}: ${formatMoney(report.summary.paidPaise, locale)}',
          ),
          pw.Text(
            '${strings.carriedForward}: '
            '${formatMoney(report.summary.carriedForwardPaise, locale)}',
          ),
          pw.Text(
            '${strings.closingBalance}: '
            '${formatMoney(report.summary.closingBalancePaise, locale)}',
          ),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: [
              strings.today,
              strings.quantity,
              strings.rate,
              strings.amount,
            ],
            data: [
              for (final entry in entries)
                [
                  formatDate(entry.date, locale),
                  '${formatLitres(entry.quantityMl)} ${strings.litreUnit}',
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
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF176B63),
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    return document.save();
  }
}
