import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../domain/entities/financial_statistics.dart';
import '../services/pdf_report_service.dart';

class PdfPreviewPage extends StatelessWidget {
  final PeriodStatistics statistics;

  const PdfPreviewPage({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final fileName = PdfReportService.getReportFileName(statistics);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan: ${statistics.periodTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: PdfPreview(
        build: (format) => PdfReportService.generateReport(statistics),
        pdfFileName: fileName,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menyiapkan dokumen PDF...'),
            ],
          ),
        ),
        onError: (context, error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text(
                    'Gagal membuat dokumen PDF',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('$error', textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
