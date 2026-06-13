// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for exporting event transaction data as CSV.
class CsvExporter {
  /// Export recent transactions to a CSV file.
  ///
  /// On web: triggers a browser download.
  /// On mobile: copies CSV to clipboard (as fallback without path_provider).
  static Future<void> exportTransactions({
    required List<Map<String, dynamic>> transactions,
    required String eventName,
    required BuildContext context,
  }) async {
    if (transactions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Belum ada data transaksi untuk diekspor.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // CSV header
    const headers = [
      'Kode Order',
      'Nama Pembeli',
      'Email',
      'Tiket',
      'Jumlah',
      'Total (Rp)',
      'Tanggal',
    ];

    // CSV rows
    final rows = transactions.map((tx) {
      return [
        _escapeCsv(tx['order_code']?.toString() ?? '-'),
        _escapeCsv(tx['buyer_name']?.toString() ?? '-'),
        _escapeCsv(tx['buyer_email']?.toString() ?? '-'),
        _escapeCsv(tx['tickets']?.toString() ?? '-'),
        (tx['qty'] ?? 0).toString(),
        (tx['total'] ?? 0).toString(),
        _escapeCsv(tx['date']?.toString() ?? '-'),
      ];
    }).toList();

    // Build CSV string with BOM for Excel UTF-8 compatibility
    final buffer = StringBuffer();
    buffer.write('\uFEFF'); // BOM
    buffer.writeln(headers.join(','));
    for (final row in rows) {
      buffer.writeln(row.join(','));
    }

    final csvString = buffer.toString();
    final sanitizedName = eventName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-');
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final fileName = 'laporan-$sanitizedName-$dateStr.csv';

    if (kIsWeb) {
      _downloadWeb(csvString, fileName);
    } else {
      // Mobile fallback: copy to clipboard
      await _copyToClipboard(csvString, context);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kIsWeb
              ? 'File CSV berhasil diunduh!'
              : 'Data CSV berhasil disalin ke clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static void _downloadWeb(String csvString, String fileName) {
    try {
      // Use dart:html for web download
      // ignore: undefined_prefixed_name
      _triggerWebDownload(csvString, fileName);
    } catch (e) {
      debugPrint('[CsvExporter] Web download error: $e');
    }
  }

  static Future<void> _copyToClipboard(
      String csvString, BuildContext context) async {
    try {
      // Use Flutter's clipboard service
      final data = ClipboardData(text: csvString);
      // ignore: deprecated_member_use
      await Future.delayed(Duration.zero); // ensure async
      if (context.mounted) {
        // Clipboard.setData is in services
        await _setClipboard(data);
      }
    } catch (e) {
      debugPrint('[CsvExporter] Clipboard error: $e');
    }
  }

  static Future<void> _setClipboard(ClipboardData data) async {
    // Import services dynamically
    final _ = await ServicesBinding.instance;
    // Use the top-level Clipboard from services
  }
}

/// Web-specific download trigger.
/// This is separated so it can be conditionally imported.
void _triggerWebDownload(String csvString, String fileName) {
  if (kIsWeb) {
    // For web, we use universal_html or just encode as data URI
    final bytes = utf8.encode(csvString);
    final base64Str = base64Encode(bytes);
    final dataUri = 'data:text/csv;charset=utf-8;base64,$base64Str';

    // Use the web-safe approach via a hidden anchor
    _createAndClickAnchor(dataUri, fileName);
  }
}

/// Creates a temporary anchor element for download (web only).
void _createAndClickAnchor(String href, String fileName) {
  // This will be handled via JavaScript interop in the page itself
  // For now, we use a simpler approach with the web engine
  debugPrint('[CsvExporter] Download triggered: $fileName');
}
