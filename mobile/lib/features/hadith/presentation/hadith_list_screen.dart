import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/database/app_database.dart';

class HadithListScreen extends ConsumerStatefulWidget {
  final int collectionId;
  final String title;

  const HadithListScreen({
    super.key,
    required this.collectionId,
    required this.title,
  });

  @override
  ConsumerState<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends ConsumerState<HadithListScreen> {
  final List<Hadith> _hadiths = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 25;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMoreHadiths();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreHadiths();
    }
  }

  Future<void> _loadMoreHadiths() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final db = ref.read(databaseProvider);
    final results = await db.getHadithsByCollectionPaginated(
      widget.collectionId,
      _limit,
      _offset,
    );

    if (mounted) {
      setState(() {
        _hadiths.addAll(results);
        _offset += results.length;
        _isLoading = false;
        if (results.length < _limit) {
          _hasMore = false;
        }
      });
    }
  }

  void _toggleBookmark(Hadith hadith) async {
    final db = ref.read(databaseProvider);
    final refId = '${widget.collectionId}:${hadith.id}';
    final isBookmarked = await db.isBookmarked('hadith', refId);

    if (isBookmarked) {
      await db.removeBookmark('hadith', refId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إزالة الحديث من المحفوظات')),
        );
      }
    } else {
      await db.addBookmark(
        BookmarksCompanion(
          type: const drift.Value('hadith'),
          referenceId: drift.Value(refId),
          title: drift.Value('${widget.title} — حديث رقم ${hadith.hadithNumber}'),
          subtitle: drift.Value(hadith.arabic.length > 80 ? '${hadith.arabic.substring(0, 80)}...' : hadith.arabic),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الحديث في المحفوظات')),
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
        title: Text(widget.title),
      ),
      body: _hadiths.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hadiths.isEmpty
              ? const Center(child: Text('لا توجد أحاديث مسجلة'))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _hadiths.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _hadiths.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final hadith = _hadiths[index];
                    final refId = '${widget.collectionId}:${hadith.id}';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Hadith number & actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'حديث رقم ${hadith.hadithNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.secondaryDark,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    FutureBuilder<bool>(
                                      future: db.isBookmarked('hadith', refId),
                                      builder: (context, snapshot) {
                                        final isBookmarked = snapshot.data ?? false;
                                        return IconButton(
                                          icon: Icon(
                                            isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                            size: 20,
                                            color: isBookmarked ? AppColors.secondary : null,
                                          ),
                                          tooltip: 'حفظ',
                                          onPressed: () => _toggleBookmark(hadith),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 20),
                                      tooltip: 'نسخ',
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                          text: '${hadith.arabic}\n\n[${widget.title} — حديث رقم ${hadith.hadithNumber}]',
                                        ));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('تم نسخ الحديث إلى الحافظة')),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share, size: 20),
                                      tooltip: 'مشاركة',
                                      onPressed: () {
                                        Share.share(
                                          '${hadith.arabic}\n\n[${widget.title} — حديث رقم ${hadith.hadithNumber}]\n\nعبر تطبيق حوة',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Hadith Matn
                            Text(
                              hadith.arabic,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                height: 1.9,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
