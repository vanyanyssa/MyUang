import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/financial_statistics.dart';

class PdfReportService {
  static String getReportFileName(PeriodStatistics stats) {
    final sanitizedTitle = stats.periodTitle.replaceAll(' ', '_').replaceAll('-', '_');
    switch (stats.periodType) {
      case PeriodType.monthly:
        return 'MyUang_Laporan_Bulanan_$sanitizedTitle.pdf';
      case PeriodType.threeMonths:
        return 'MyUang_Laporan_3Bulan_$sanitizedTitle.pdf';
      case PeriodType.yearly:
        return 'MyUang_Laporan_Tahunan_$sanitizedTitle.pdf';
    }
  }

  static Future<Uint8List> generateReport(PeriodStatistics stats) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final generatedDateStr = DateFormatter.formatFull(now);

    pw.Font fontRegular;
    pw.Font fontBold;
    try {
      fontRegular = await PdfGoogleFonts.robotoRegular();
      fontBold = await PdfGoogleFonts.robotoBold();
    } catch (_) {
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    final theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    );

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            margin: const pw.EdgeInsets.only(bottom: 16),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.indigo900, width: 2),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MyUang',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                    pw.Text(
                      'Laporan Manajemen Keuangan Pribadi',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'LAPORAN KEUANGAN',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                    pw.Text(
                      'Periode: ${stats.periodTitle}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Dicetak: $generatedDateStr',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            margin: const pw.EdgeInsets.only(top: 16),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'MyUang - Aplikasi Keuangan Pribadi',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
        build: (context) {
          return [
            // 1. Ringkasan Keuangan (Cards)
            pw.Text(
              'RINGKASAN KEUANGAN',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                _buildSummaryBox(
                  title: 'Total Pemasukan',
                  value: CurrencyFormatter.format(stats.totalIncome),
                  color: PdfColors.green700,
                  bgColor: PdfColors.green50,
                ),
                pw.SizedBox(width: 8),
                _buildSummaryBox(
                  title: 'Total Pengeluaran',
                  value: CurrencyFormatter.format(stats.totalExpense),
                  color: PdfColors.red700,
                  bgColor: PdfColors.red50,
                ),
                pw.SizedBox(width: 8),
                _buildSummaryBox(
                  title: 'Saldo Bersih',
                  value: CurrencyFormatter.format(stats.netBalance),
                  color: stats.netBalance >= 0 ? PdfColors.indigo800 : PdfColors.red800,
                  bgColor: PdfColors.grey100,
                ),
                pw.SizedBox(width: 8),
                _buildSummaryBox(
                  title: 'Transaksi',
                  value: '${stats.transactionCount} Transaksi',
                  color: PdfColors.blueGrey800,
                  bgColor: PdfColors.blueGrey50,
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // 2. Visualisasi Bulanan (jika 3 bulan / tahunan)
            if (stats.monthlyBreakdown.length > 1) ...[
              pw.Text(
                'RINCIAN PER BULAN',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo900,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo800),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headers: ['Bulan', 'Pemasukan', 'Pengeluaran', 'Saldo Bersih', 'Jml Transaksi'],
                data: stats.monthlyBreakdown.map((m) {
                  return [
                    m.monthName,
                    CurrencyFormatter.format(m.income),
                    CurrencyFormatter.format(m.expense),
                    CurrencyFormatter.format(m.netBalance),
                    '${m.transactionCount}',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 16),
            ],

            // 3. Rincian Pengeluaran Berdasarkan Kategori
            pw.Text(
              'RINCIAN PENGELUARAN BERDASARKAN KATEGORI',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo900,
              ),
            ),
            pw.SizedBox(height: 8),
            if (stats.expenseCategories.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'Tidak ada transaksi pengeluaran pada periode ini.',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo700),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headers: ['Kategori', 'Total Pengeluaran', 'Proporsi (%)', 'Jumlah Transaksi'],
                data: stats.expenseCategories.map((c) {
                  return [
                    c.categoryName,
                    CurrencyFormatter.format(c.amount),
                    '${c.percentage.toStringAsFixed(1)} %',
                    '${c.count}',
                  ];
                }).toList(),
              ),
            pw.SizedBox(height: 16),

            // 4. Rincian Transaksi
            pw.Text(
              'DAFTAR TRANSAKSI',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo900,
              ),
            ),
            pw.SizedBox(height: 8),
            if (stats.transactions.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'Tidak terdapat transaksi keuangan pada periode ini.',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                headers: ['Tanggal', 'Jenis', 'Kategori', 'Catatan', 'Nominal'],
                data: stats.transactions.map((tx) {
                  return [
                    DateFormatter.formatFull(tx.date),
                    tx.isIncome ? 'Pemasukan' : 'Pengeluaran',
                    tx.category,
                    tx.note.isNotEmpty ? tx.note : '-',
                    '${tx.isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                  ];
                }).toList(),
              ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildSummaryBox({
    required String title,
    required String value,
    required PdfColor color,
    required PdfColor bgColor,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
