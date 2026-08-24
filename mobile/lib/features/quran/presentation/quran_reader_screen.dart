import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/database/app_database.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  final int surahId;
  final int initialAyah;

  const QuranReaderScreen({
    super.key,
    required this.surahId,
    this.initialAyah = 1,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  late int _currentSurahId;
  final ScrollController _scrollController = ScrollController();
  int? _highlightedAyah;

  @override
  void initState() {
    super.initState();
    _currentSurahId = widget.surahId;
    _highlightedAyah = widget.initialAyah > 1 ? widget.initialAyah : null;
    _saveReadingPosition();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveReadingPosition([int ayahNumber = 1]) async {
    final db = ref.read(databaseProvider);
    await db.saveReadingPosition(
      ReadingPositionsCompanion(
        surahId: drift.Value(_currentSurahId),
        ayahId: drift.Value(ayahNumber),
        scrollPosition: drift.Value(_scrollController.hasClients ? _scrollController.offset : 0.0),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  void _showFontSizeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final fontScale = ref.watch(fontSizeProvider);
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حجم خط القرآن الكريم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('أ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Slider(
                          value: fontScale,
                          min: 0.8,
                          max: 1.6,
                          divisions: 8,
                          label: '${(fontScale * 100).toInt()}%',
                          onChanged: (val) {
                            ref.read(fontSizeProvider.notifier).setFontSize(val);
                          },
                        ),
                      ),
                      const Text('أ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onAyahTapped(Ayah ayah, Surah surah) {
    setState(() {
      _highlightedAyah = ayah.verseNumber;
    });
    _saveReadingPosition(ayah.verseNumber);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final db = ref.read(databaseProvider);

        return FutureBuilder<bool>(
          future: db.isBookmarked('quran', '${surah.id}:${ayah.verseNumber}'),
          builder: (context, snapshot) {
            final isBookmarked = snapshot.data ?? false;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'سورة ${surah.name} — آية ${ayah.verseNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ayah.text,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Bookmark
                        IconButton.filledTonal(
                          icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
                          tooltip: 'حفظ كعلامة',
                          onPressed: () async {
                            if (isBookmarked) {
                              await db.removeBookmark('quran', '${surah.id}:${ayah.verseNumber}');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تمت إزالة العلامة المرجعية')),
                                );
                              }
                            } else {
                              await db.addBookmark(
                                BookmarksCompanion(
                                  type: const drift.Value('quran'),
                                  referenceId: drift.Value('${surah.id}:${ayah.verseNumber}'),
                                  title: drift.Value('سورة ${surah.name} (آية ${ayah.verseNumber})'),
                                  subtitle: drift.Value(ayah.text.length > 60 ? '${ayah.text.substring(0, 60)}...' : ayah.text),
                                ),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تمت إضافة العلامة المرجعية')),
                                );
                              }
                            }
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                        // Copy
                        IconButton.filledTonal(
                          icon: const Icon(Icons.copy),
                          tooltip: 'نسخ الآية',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text: '﴿ ${ayah.text} ﴾ [${surah.name}: ${ayah.verseNumber}]',
                            ));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم نسخ الآية إلى الحافظة')),
                            );
                          },
                        ),
                        // Share
                        IconButton.filledTonal(
                          icon: const Icon(Icons.share),
                          tooltip: 'مشاركة',
                          onPressed: () {
                            Navigator.pop(context);
                            Share.share(
                              '﴿ ${ayah.text} ﴾ [سورة ${surah.name}: ${ayah.verseNumber}]\n\nعبر تطبيق حوة',
                            );
                          },
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
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final fontScale = ref.watch(fontSizeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Surah?>(
      future: db.getSurah(_currentSurahId),
      builder: (context, surahSnapshot) {
        final surah = surahSnapshot.data;

        return Scaffold(
          backgroundColor: isDark ? AppColors.quranBgDark : AppColors.quranBgLight,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            title: Text(
              surah != null ? 'سورة ${surah.name}' : 'القرآن الكريم',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.text_fields),
                tooltip: 'حجم الخط',
                onPressed: _showFontSizeSheet,
              ),
            ],
          ),
          bottomNavigationBar: surah == null
              ? null
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    border: Border(top: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Surah
                      if (_currentSurahId > 1)
                        TextButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('السورة السابقة'),
                          onPressed: () {
                            setState(() {
                              _currentSurahId--;
                              _highlightedAyah = null;
                            });
                            _saveReadingPosition();
                            _scrollController.jumpTo(0);
                          },
                        )
                      else
                        const SizedBox.shrink(),

                      // Next Surah
                      if (_currentSurahId < 114)
                        TextButton.icon(
                          label: const Text('السورة التالية'),
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            setState(() {
                              _currentSurahId++;
                              _highlightedAyah = null;
                            });
                            _saveReadingPosition();
                            _scrollController.jumpTo(0);
                          },
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
          body: surah == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<Ayah>>(
                  future: db.getAyahsBySurah(_currentSurahId),
                  builder: (context, ayahsSnapshot) {
                    if (ayahsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final ayahs = ayahsSnapshot.data ?? [];
                    if (ayahs.isEmpty) {
                      return const Center(child: Text('لا توجد آيات متوفرة'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: ayahs.length + 1, // +1 for Header / Bismillah
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Surah Banner & Bismillah
                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withAlpha(60)),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'سورة ${surah.name}',
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${surah.type == 'meccan' ? 'مكية' : 'مدنية'} • عدد آياتها ${surah.totalVerses}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              // Bismillah for all except Surah 1 (Al-Fatihah has it as verse 1) & Surah 9 (At-Tawbah has no Bismillah)
                              if (_currentSurahId != 1 && _currentSurahId != 9)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 24, top: 8),
                                  child: Text(
                                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          );
                        }

                        final ayah = ayahs[index - 1];
                        final isHighlighted = _highlightedAyah == ayah.verseNumber;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? AppColors.primary.withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _onAyahTapped(ayah, surah),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: ayah.text,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 22 * fontScale,
                                        height: 2.0,
                                        color: isDark ? AppColors.quranTextDark : AppColors.quranTextLight,
                                      ),
                                    ),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.secondary, width: 1.5),
                                        ),
                                        child: Text(
                                          '${ayah.verseNumber}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.secondaryDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
