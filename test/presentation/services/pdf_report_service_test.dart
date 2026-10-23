import 'package:flutter_test/flutter_test.dart';
import 'package:myuang/domain/entities/transaction.dart';
import 'package:myuang/domain/usecases/calculate_statistics.dart';
import 'package:myuang/presentation/services/pdf_report_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfReportService Tests', () {
    final sampleTransactions = [
      Transaction(
        id: '1',
        type: 'income',
        amount: 2500000,
        category: 'Gaji',
        note: 'Gaji Bulanan',
        date: DateTime(2026, 10, 1),
      ),
      Transaction(
        id: '2',
        type: 'expense',
        amount: 50000,
        category: 'Makanan',
        note: 'Makan Bakso',
        date: DateTime(2026, 10, 5),
      ),
    ];

    test('getReportFileName creates expected file names for all period types', () {
      final monthlyStats = FinancialStatisticsCalculator.calculateMonthly(
        allTransactions: sampleTransactions,
        year: 2026,
        month: 10,
      );
      final monthlyName = PdfReportService.getReportFileName(monthlyStats);
      expect(monthlyName, contains('MyUang_Laporan_Bulanan'));
      expect(monthlyName.endsWith('.pdf'), isTrue);

      final threeMonthStats = FinancialStatisticsCalculator.calculateThreeMonths(
        allTransactions: sampleTransactions,
        endYear: 2026,
        endMonth: 10,
      );
      final threeMonthName = PdfReportService.getReportFileName(threeMonthStats);
      expect(threeMonthName, contains('MyUang_Laporan_3Bulan'));
      expect(threeMonthName.endsWith('.pdf'), isTrue);

      final yearlyStats = FinancialStatisticsCalculator.calculateYearly(
        allTransactions: sampleTransactions,
        year: 2026,
      );
      final yearlyName = PdfReportService.getReportFileName(yearlyStats);
      expect(yearlyName, contains('MyUang_Laporan_Tahunan'));
      expect(yearlyName.endsWith('.pdf'), isTrue);
    });

    test('generateReport generates non-empty PDF document bytes', () async {
      final monthlyStats = FinancialStatisticsCalculator.calculateMonthly(
        allTransactions: sampleTransactions,
        year: 2026,
        month: 10,
      );

      final pdfBytes = await PdfReportService.generateReport(monthlyStats);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF documents start with %PDF-
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, '%PDF-');
    });

    test('generateReport succeeds even when period has zero transactions', () async {
      final emptyStats = FinancialStatisticsCalculator.calculateMonthly(
        allTransactions: [],
        year: 2026,
        month: 10,
      );

      final pdfBytes = await PdfReportService.generateReport(emptyStats);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
    });
  });
}
