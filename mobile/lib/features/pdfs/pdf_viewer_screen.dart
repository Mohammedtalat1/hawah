import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../core/theme/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';
  PDFViewController? _pdfViewController;
  bool _nightMode = false;

  @override
  Widget build(BuildContext context) {
    final fileExists = File(widget.filePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_nightMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: _nightMode ? 'الوضع الفاتح' : 'الوضع الداكن',
            onPressed: () {
              setState(() => _nightMode = !_nightMode);
            },
          ),
        ],
      ),
      bottomNavigationBar: _isReady && _totalPages > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 0
                        ? () => _pdfViewController?.setPage(_currentPage - 1)
                        : null,
                  ),
                  Text(
                    'صفحة ${_currentPage + 1} من $_totalPages',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < _totalPages - 1
                        ? () => _pdfViewController?.setPage(_currentPage + 1)
                        : null,
                  ),
                ],
              ),
            )
          : null,
      body: !fileExists
          ? const Center(
              child: Text('تعذر العثور على ملف الكتاب على هذا الجهاز'),
            )
          : Stack(
              children: [
                PDFView(
                  filePath: widget.filePath,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: true,
                  pageSnap: true,
                  nightMode: _nightMode,
                  onRender: (pages) {
                    setState(() {
                      _totalPages = pages ?? 0;
                      _isReady = true;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      _errorMessage = error.toString();
                    });
                  },
                  onPageError: (page, error) {
                    setState(() {
                      _errorMessage = '$page: ${error.toString()}';
                    });
                  },
                  onViewCreated: (PDFViewController controller) {
                    _pdfViewController = controller;
                  },
                  onPageChanged: (int? page, int? total) {
                    setState(() {
                      _currentPage = page ?? 0;
                    });
                  },
                ),
                if (!_isReady && _errorMessage.isEmpty)
                  const Center(child: CircularProgressIndicator()),
                if (_errorMessage.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'خطأ في فتح ملف PDF: $_errorMessage',
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
