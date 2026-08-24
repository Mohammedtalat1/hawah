import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';
import '../../core/services/pdf_download_service.dart';

class PdfsScreen extends ConsumerStatefulWidget {
  const PdfsScreen({super.key});

  @override
  ConsumerState<PdfsScreen> createState() => _PdfsScreenState();
}

class _PdfsScreenState extends ConsumerState<PdfsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Map<String, double> _downloadProgress = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handlePdfAction(CachedPdf pdf, DownloadedPdf? downloaded) async {
    if (downloaded != null && await File(downloaded.localPath).exists()) {
      // Open offline PDF viewer
      if (mounted) {
        context.push(
          '/pdfs/viewer?filePath=${Uri.encodeComponent(downloaded.localPath)}&title=${Uri.encodeComponent(pdf.title)}',
        );
      }
    } else {
      // Download PDF
      setState(() => _downloadProgress[pdf.remoteId] = 0.01);
      final db = ref.read(databaseProvider);
      final downloadService = PdfDownloadService(db);

      try {
        final file = await downloadService.downloadPdf(
          pdfRemoteId: pdf.remoteId,
          title: pdf.title,
          downloadUrl: pdf.pdfUrl,
          onProgress: (received, total) {
            if (total > 0 && mounted) {
              setState(() {
                _downloadProgress[pdf.remoteId] = received / total;
              });
            }
          },
        );

        setState(() => _downloadProgress.remove(pdf.remoteId));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اكتمل تحميل الكتاب بنجاح')),
          );
          context.push(
            '/pdfs/viewer?filePath=${Uri.encodeComponent(file.path)}&title=${Uri.encodeComponent(pdf.title)}',
          );
        }
      } catch (e) {
        setState(() => _downloadProgress.remove(pdf.remoteId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل تحميل ملف الكتاب')),
          );
        }
      }
    }
  }

  void _toggleBookmark(CachedPdf pdf) async {
    final db = ref.read(databaseProvider);
    final isBookmarked = await db.isBookmarked('pdf', pdf.remoteId);

    if (isBookmarked) {
      await db.removeBookmark('pdf', pdf.remoteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إزالة الكتاب من المحفوظات')),
        );
      }
    } else {
      await db.addBookmark(
        BookmarksCompanion(
          type: const drift.Value('pdf'),
          referenceId: drift.Value(pdf.remoteId),
          title: drift.Value(pdf.title),
          subtitle: drift.Value(pdf.author ?? ''),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الكتاب في المحفوظات')),
        );
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المكتبة والكتب الإسلامية'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث في أسماء الكتب والمؤلفين...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CachedPdf>>(
              future: _searchQuery.isNotEmpty
                  ? db.searchCachedPdfs(_searchQuery)
                  : db.getCachedPdfs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pdfs = snapshot.data ?? [];
                if (pdfs.isEmpty) {
                  return const Center(
                    child: Text('لا توجد كتب متوفرة في المكتبة حالياً'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: pdfs.length,
                  itemBuilder: (context, index) {
                    final pdf = pdfs[index];
                    final progress = _downloadProgress[pdf.remoteId];

                    return FutureBuilder<DownloadedPdf?>(
                      future: db.getDownloadedPdf(pdf.remoteId),
                      builder: (context, downloadSnapshot) {
                        final downloaded = downloadSnapshot.data;
                        final isDownloaded = downloaded != null;

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cover
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 70,
                                    height: 95,
                                    color: AppColors.primary.withAlpha(25),
                                    child: pdf.coverUrl != null && pdf.coverUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: pdf.coverUrl!,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) => const Icon(
                                              Icons.picture_as_pdf,
                                              size: 36,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.picture_as_pdf,
                                            size: 36,
                                            color: AppColors.primary,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Metadata
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pdf.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (pdf.author != null)
                                        Text(
                                          'المؤلف: ${pdf.author}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.secondaryDark),
                                        ),
                                      if (pdf.fileSize != null)
                                        Text(
                                          'الحجم: ${pdf.fileSize}',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      if (isDownloaded)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withAlpha(25),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check, size: 12, color: AppColors.success),
                                              SizedBox(width: 4),
                                              Text('متوفر بدون إنترنت', style: TextStyle(fontSize: 10, color: AppColors.success)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Action / Download
                                Column(
                                  children: [
                                    if (progress != null)
                                      SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: CircularProgressIndicator(value: progress),
                                      )
                                    else
                                      IconButton.filledTonal(
                                        icon: Icon(isDownloaded ? Icons.menu_book : Icons.download),
                                        tooltip: isDownloaded ? 'قراءة' : 'تحميل وقراءة',
                                        onPressed: () => _handlePdfAction(pdf, downloaded),
                                      ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FutureBuilder<bool>(
                                          future: db.isBookmarked('pdf', pdf.remoteId),
                                          builder: (context, bSnapshot) {
                                            final isBookmarked = bSnapshot.data ?? false;
                                            return IconButton(
                                              icon: Icon(
                                                isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                                size: 18,
                                                color: isBookmarked ? AppColors.secondary : null,
                                              ),
                                              onPressed: () => _toggleBookmark(pdf),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.share, size: 18),
                                          onPressed: () {
                                            Share.share('${pdf.title}\n${pdf.pdfUrl}\n\nعبر تطبيق حوة');
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
