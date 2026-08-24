import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';

/// Service to import Quran and Hadith data from bundled JSON assets
/// into the local Drift/SQLite database on first launch.
///
/// Data sources:
/// - Quran: Tanzil.net (via risan/quran-json)
/// - Hadith: Sunnah.com (via AhmedBaset/hadith-json)
///
/// This service does NOT generate any religious content.
class DataImportService {
  final AppDatabase db;

  DataImportService(this.db);

  /// Check if data has already been imported.
  Future<bool> isDataImported() async {
    final count = await db.getSurahCount();
    return count >= 114;
  }

  /// Import all data. Should be called once on first launch.
  Future<void> importAll({
    void Function(String status)? onProgress,
  }) async {
    onProgress?.call('جاري تحميل القرآن الكريم...');
    await importQuranChapters();
    await importQuranText();

    onProgress?.call('جاري تحميل صحيح البخاري...');
    await importHadithCollection(
      assetPath: 'assets/data/bukhari.json',
      collectionName: 'Sahih al-Bukhari',
      collectionNameAr: 'صحيح البخاري',
      collectionId: 1,
    );

    onProgress?.call('جاري تحميل صحيح مسلم...');
    await importHadithCollection(
      assetPath: 'assets/data/muslim.json',
      collectionName: 'Sahih Muslim',
      collectionNameAr: 'صحيح مسلم',
      collectionId: 2,
    );

    onProgress?.call('البيانات جاهزة');
  }

  /// Import surah metadata from chapters.json
  Future<void> importQuranChapters() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/data/chapters.json');
      final List<dynamic> chapters = json.decode(jsonStr);

      for (final ch in chapters) {
        await db.insertSurah(SurahsCompanion(
          id: Value(ch['id'] as int),
          name: Value(ch['name'] as String),
          transliteration: Value(ch['transliteration'] as String? ?? ''),
          translation: Value(ch['translation'] as String? ?? ''),
          type: Value(ch['type'] as String? ?? 'meccan'),
          totalVerses: Value(ch['total_verses'] as int? ?? 0),
        ));
      }
    } catch (e) {
      throw Exception('Failed to import Quran chapters: $e');
    }
  }

  /// Import Quran text from quran.json
  /// Format: {"1": [{"chapter": 1, "verse": 1, "text": "..."}], "2": [...]}
  Future<void> importQuranText() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/data/quran.json');
      final Map<String, dynamic> quranData = json.decode(jsonStr);

      // Process in batches to avoid memory pressure
      for (final entry in quranData.entries) {
        final int surahId = int.parse(entry.key);
        final List<dynamic> verses = entry.value as List<dynamic>;

        for (final verse in verses) {
          await db.insertAyah(AyahsCompanion(
            surahId: Value(surahId),
            verseNumber: Value(verse['verse'] as int),
            text: Value(verse['text'] as String),
            juz: Value(_getJuz(surahId, verse['verse'] as int)),
            page: Value(_getPage(surahId, verse['verse'] as int)),
          ));
        }
      }
    } catch (e) {
      throw Exception('Failed to import Quran text: $e');
    }
  }

  /// Import a hadith collection from JSON asset.
  /// Format: {"metadata": {...}, "chapters": [{"id": N, "bookId": N, ...}], "hadiths": [...]}
  /// Or flat array format: [{"id": N, "chapterId": N, "bookId": N, "arabic": "...", "english": {...}}]
  Future<void> importHadithCollection({
    required String assetPath,
    required String collectionName,
    required String collectionNameAr,
    required int collectionId,
  }) async {
    try {
      final String jsonStr = await rootBundle.loadString(assetPath);
      final dynamic data = json.decode(jsonStr);

      // Insert collection
      await db.insertCollection(HadithCollectionsCompanion(
        id: Value(collectionId),
        name: Value(collectionName),
        nameAr: Value(collectionNameAr),
      ));

      // Handle both formats
      List<dynamic> hadithsList;
      if (data is List) {
        hadithsList = data;
      } else if (data is Map) {
        hadithsList = data['hadiths'] as List<dynamic>? ?? [];
      } else {
        return;
      }

      int count = 0;
      for (final h in hadithsList) {
        count++;
        final arabic = h['arabic'] as String? ?? '';
        if (arabic.isEmpty) continue;

        String narratorEn = '';
        String textEn = '';
        if (h['english'] is Map) {
          narratorEn = h['english']['narrator'] as String? ?? '';
          textEn = h['english']['text'] as String? ?? '';
        }

        await db.insertHadith(HadithsCompanion(
          collectionId: Value(collectionId),
          hadithNumber: Value(h['id'] as int? ?? count),
          arabic: Value(arabic),
          narratorEn: Value(narratorEn),
          textEn: Value(textEn),
          chapterId: Value(h['chapterId'] as int? ?? 0),
          bookId: Value(h['bookId'] as int?),
        ));
      }

      // Update total count
      await db.insertCollection(HadithCollectionsCompanion(
        id: Value(collectionId),
        name: Value(collectionName),
        nameAr: Value(collectionNameAr),
        totalHadiths: Value(count),
      ));
    } catch (e) {
      throw Exception('Failed to import hadith collection ($collectionNameAr): $e');
    }
  }

  /// Approximate Juz calculation based on surah and verse.
  /// This is a simplified mapping — a production app may use a full juz-to-verse table.
  int _getJuz(int surah, int verse) {
    // Simplified juz boundaries (first verse of each juz)
    const juzBoundaries = [
      [1, 1], [2, 142], [2, 253], [3, 93], [4, 24],
      [4, 148], [5, 83], [6, 111], [7, 88], [8, 41],
      [9, 93], [11, 6], [12, 53], [15, 1], [17, 1],
      [18, 75], [21, 1], [23, 1], [25, 21], [27, 56],
      [29, 46], [33, 31], [36, 28], [39, 32], [41, 47],
      [46, 1], [51, 31], [58, 1], [67, 1], [78, 1],
    ];

    int juz = 1;
    for (int i = juzBoundaries.length - 1; i >= 0; i--) {
      final boundary = juzBoundaries[i];
      if (surah > boundary[0] || (surah == boundary[0] && verse >= boundary[1])) {
        juz = i + 1;
        break;
      }
    }
    return juz;
  }

  /// Approximate page calculation.
  int _getPage(int surah, int verse) {
    // Simplified: estimate ~15 verses per page on average
    // A production app would use the Madani mushaf page data
    return ((surah - 1) * 5 + (verse - 1) ~/ 15) + 1;
  }
}
