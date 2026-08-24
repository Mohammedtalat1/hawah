import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/app_database.dart';

/// PDF Download & Offline Storage Manager
class PdfDownloadService {
  final Dio _dio = Dio();
  final AppDatabase _db;

  PdfDownloadService(this._db);

  /// Downloads a PDF file to the device local storage and registers it in SQLite.
  Future<File> downloadPdf({
    required String pdfRemoteId,
    required String title,
    required String downloadUrl,
    void Function(int received, int total)? onProgress,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(appDir.path, 'downloaded_pdfs'));
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    final safeFileName = '${pdfRemoteId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';
    final targetPath = p.join(pdfDir.path, safeFileName);
    final targetFile = File(targetPath);

    await _dio.download(
      downloadUrl,
      targetPath,
      onReceiveProgress: onProgress,
    );

    final fileSize = await targetFile.length();

    // Register into Drift local database
    await _db.addDownloadedPdf(
      DownloadedPdfsCompanion(
        pdfRemoteId: Value(pdfRemoteId),
        localPath: Value(targetPath),
        title: Value(title),
        fileSize: Value(fileSize),
        downloadedAt: Value(DateTime.now()),
      ),
    );

    return targetFile;
  }

  /// Check if a PDF is downloaded and the file actually exists on disk.
  Future<DownloadedPdf?> getDownloadedPdf(String pdfRemoteId) async {
    final record = await _db.getDownloadedPdf(pdfRemoteId);
    if (record != null) {
      final file = File(record.localPath);
      if (await file.exists()) {
        return record;
      } else {
        // Clean up stale database entry
        await _db.removeDownloadedPdf(pdfRemoteId);
      }
    }
    return null;
  }

  /// Remove a downloaded PDF from disk and database.
  Future<void> deleteDownloadedPdf(String pdfRemoteId) async {
    final record = await _db.getDownloadedPdf(pdfRemoteId);
    if (record != null) {
      final file = File(record.localPath);
      if (await file.exists()) {
        await file.delete();
      }
      await _db.removeDownloadedPdf(pdfRemoteId);
    }
  }
}
