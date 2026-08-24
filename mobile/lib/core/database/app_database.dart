import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';

// Tables
part 'app_database.g.dart';

// ─── Quran Tables ───────────────────────────────────────────

class Surahs extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get transliteration => text().withDefault(const Constant(''))();
  TextColumn get translation => text().withDefault(const Constant(''))();
  TextColumn get type => text().withDefault(const Constant('meccan'))();
  IntColumn get totalVerses => integer().withDefault(const Constant(0))();
  IntColumn get revelationOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Ayahs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahId => integer().references(Surahs, #id)();
  IntColumn get verseNumber => integer()();
  TextColumn get text => text()();
  IntColumn get juz => integer().withDefault(const Constant(1))();
  IntColumn get page => integer().withDefault(const Constant(1))();
}

// ─── Hadith Tables ──────────────────────────────────────────

class HadithCollections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameAr => text()();
  IntColumn get totalHadiths => integer().withDefault(const Constant(0))();
}

class HadithBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get collectionId => integer().references(HadithCollections, #id)();
  IntColumn get bookNumber => integer()();
  TextColumn get nameAr => text().withDefault(const Constant(''))();
  TextColumn get nameEn => text().withDefault(const Constant(''))();
}

class Hadiths extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get collectionId => integer().references(HadithCollections, #id)();
  IntColumn get bookId => integer().nullable()();
  IntColumn get hadithNumber => integer().withDefault(const Constant(0))();
  TextColumn get arabic => text()();
  TextColumn get narratorEn => text().withDefault(const Constant(''))();
  TextColumn get textEn => text().withDefault(const Constant(''))();
  IntColumn get chapterId => integer().withDefault(const Constant(0))();
}

// ─── Bookmarks & Favorites ──────────────────────────────────

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // quran, hadith, dua, podcast, video, pdf
  TextColumn get referenceId => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get referenceId => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Tasbih ─────────────────────────────────────────────────

class TasbihPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dhikrText => text()();
  IntColumn get target => integer().withDefault(const Constant(33))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

class TasbihRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dhikrText => text()();
  IntColumn get count => integer()();
  IntColumn get target => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Reading Position ───────────────────────────────────────

class ReadingPositions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahId => integer()();
  IntColumn get ayahId => integer().withDefault(const Constant(1))();
  RealColumn get scrollPosition => real().withDefault(const Constant(0.0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Cached Online Content ──────────────────────────────────

class CachedDuas extends Table {
  TextColumn get remoteId => text()();
  TextColumn get title => text()();
  TextColumn get arabicText => text()();
  TextColumn get translation => text().nullable()();
  TextColumn get transliteration => text().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {remoteId};
}

class CachedPodcasts extends Table {
  TextColumn get remoteId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get podcastUrl => text()();
  TextColumn get publisher => text().nullable()();
  TextColumn get duration => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {remoteId};
}

class CachedVideos extends Table {
  TextColumn get remoteId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get videoUrl => text()();
  TextColumn get publisher => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {remoteId};
}

class CachedPdfs extends Table {
  TextColumn get remoteId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get pdfUrl => text()();
  TextColumn get author => text().nullable()();
  TextColumn get fileSize => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  BoolColumn get isDownloadable => boolean().withDefault(const Constant(true))();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {remoteId};
}

class CachedCategories extends Table {
  TextColumn get remoteId => text()();
  TextColumn get name => text()();
  TextColumn get nameAr => text()();
  TextColumn get type => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {remoteId};
}

// ─── Downloaded PDFs ────────────────────────────────────────

class DownloadedPdfs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pdfRemoteId => text()();
  TextColumn get localPath => text()();
  TextColumn get title => text()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Sync Metadata ──────────────────────────────────────────

class SyncMetadata extends Table {
  TextColumn get entityType => text()();
  DateTimeColumn get lastSyncAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {entityType};
}

// ─── Settings ───────────────────────────────────────────────

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ─── Database Definition ────────────────────────────────────

@DriftDatabase(tables: [
  Surahs,
  Ayahs,
  HadithCollections,
  HadithBooks,
  Hadiths,
  Bookmarks,
  Favorites,
  TasbihPresets,
  TasbihRecords,
  ReadingPositions,
  CachedDuas,
  CachedPodcasts,
  CachedVideos,
  CachedPdfs,
  CachedCategories,
  DownloadedPdfs,
  SyncMetadata,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Insert default tasbih presets
      await into(tasbihPresets).insert(TasbihPresetsCompanion.insert(
        dhikrText: 'سبحان الله',
        target: const Value(33),
        isDefault: const Value(true),
      ));
      await into(tasbihPresets).insert(TasbihPresetsCompanion.insert(
        dhikrText: 'الحمد لله',
        target: const Value(33),
      ));
      await into(tasbihPresets).insert(TasbihPresetsCompanion.insert(
        dhikrText: 'الله أكبر',
        target: const Value(34),
      ));
      await into(tasbihPresets).insert(TasbihPresetsCompanion.insert(
        dhikrText: 'لا إله إلا الله',
        target: const Value(100),
      ));
      await into(tasbihPresets).insert(TasbihPresetsCompanion.insert(
        dhikrText: 'أستغفر الله',
        target: const Value(100),
      ));
      await into(tasbihPresets).insert(TasbihPresetsCompanion.insert(
        dhikrText: 'سبحان الله وبحمده',
        target: const Value(100),
      ));
      await into(tasbihPresets).insert(TasbihPresetsCompanion.insert(
        dhikrText: 'لا حول ولا قوة إلا بالله',
        target: const Value(100),
      ));
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future migrations go here
    },
  );

  // ─── Quran DAOs ─────────────────────────────────────────

  Future<List<Surah>> getAllSurahs() => select(surahs).get();

  Future<Surah?> getSurah(int id) =>
      (select(surahs)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<List<Ayah>> getAyahsBySurah(int surahId) =>
      (select(ayahs)..where((a) => a.surahId.equals(surahId))
        ..orderBy([(a) => OrderingTerm.asc(a.verseNumber)])).get();

  Future<List<Ayah>> searchAyahs(String query) =>
      (select(ayahs)..where((a) => a.text.like('%$query%'))
        ..limit(100)).get();

  Future<void> insertSurah(SurahsCompanion surah) =>
      into(surahs).insertOnConflictUpdate(surah);

  Future<void> insertAyah(AyahsCompanion ayah) =>
      into(ayahs).insert(ayah, mode: InsertMode.insertOrReplace);

  // ─── Hadith DAOs ────────────────────────────────────────

  Future<List<HadithCollection>> getAllCollections() =>
      select(hadithCollections).get();

  Future<List<Hadith>> getHadithsByCollection(int collectionId) =>
      (select(hadiths)..where((h) => h.collectionId.equals(collectionId))
        ..orderBy([(h) => OrderingTerm.asc(h.hadithNumber)])
        ..limit(50)).get();

  Future<List<Hadith>> getHadithsByCollectionPaginated(
      int collectionId, int limit, int offset) =>
      (select(hadiths)
        ..where((h) => h.collectionId.equals(collectionId))
        ..orderBy([(h) => OrderingTerm.asc(h.hadithNumber)])
        ..limit(limit, offset: offset)).get();

  Future<int> getHadithCount(int collectionId) async {
    final count = countAll();
    final query = selectOnly(hadiths)
      ..where(hadiths.collectionId.equals(collectionId))
      ..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<List<Hadith>> searchHadiths(String query) =>
      (select(hadiths)..where((h) => h.arabic.like('%$query%'))
        ..limit(100)).get();

  Future<void> insertCollection(HadithCollectionsCompanion collection) =>
      into(hadithCollections).insertOnConflictUpdate(collection);

  Future<void> insertHadith(HadithsCompanion hadith) =>
      into(hadiths).insert(hadith, mode: InsertMode.insertOrReplace);

  // ─── Bookmark DAOs ──────────────────────────────────────

  Future<List<Bookmark>> getBookmarksByType(String type) =>
      (select(bookmarks)..where((b) => b.type.equals(type))
        ..orderBy([(b) => OrderingTerm.desc(b.createdAt)])).get();

  Future<List<Bookmark>> getAllBookmarks() =>
      (select(bookmarks)..orderBy([(b) => OrderingTerm.desc(b.createdAt)])).get();

  Future<bool> isBookmarked(String type, String referenceId) async {
    final query = select(bookmarks)
      ..where((b) => b.type.equals(type) & b.referenceId.equals(referenceId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  Future<void> addBookmark(BookmarksCompanion bookmark) =>
      into(bookmarks).insert(bookmark);

  Future<void> removeBookmark(String type, String referenceId) =>
      (delete(bookmarks)..where((b) =>
          b.type.equals(type) & b.referenceId.equals(referenceId))).go();

  // ─── Favorite DAOs ─────────────────────────────────────

  Future<List<Favorite>> getFavoritesByType(String type) =>
      (select(favorites)..where((f) => f.type.equals(type))
        ..orderBy([(f) => OrderingTerm.desc(f.createdAt)])).get();

  Future<List<Favorite>> getAllFavorites() =>
      (select(favorites)..orderBy([(f) => OrderingTerm.desc(f.createdAt)])).get();

  Future<bool> isFavorited(String type, String referenceId) async {
    final query = select(favorites)
      ..where((f) => f.type.equals(type) & f.referenceId.equals(referenceId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  Future<void> addFavorite(FavoritesCompanion favorite) =>
      into(favorites).insert(favorite);

  Future<void> removeFavorite(String type, String referenceId) =>
      (delete(favorites)..where((f) =>
          f.type.equals(type) & f.referenceId.equals(referenceId))).go();

  // ─── Tasbih DAOs ───────────────────────────────────────

  Future<List<TasbihPreset>> getTasbihPresets() =>
      select(tasbihPresets).get();

  Future<void> saveTasbihRecord(TasbihRecordsCompanion record) =>
      into(tasbihRecords).insert(record);

  Future<List<TasbihRecord>> getTasbihHistory() =>
      (select(tasbihRecords)
        ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
        ..limit(50)).get();

  // ─── Reading Position DAOs ─────────────────────────────

  Future<ReadingPosition?> getLastReadingPosition() =>
      (select(readingPositions)
        ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)])
        ..limit(1)).getSingleOrNull();

  Future<void> saveReadingPosition(ReadingPositionsCompanion position) async {
    // Upsert: delete old, insert new
    await (delete(readingPositions)..where((r) =>
        r.surahId.equals(position.surahId.value))).go();
    await into(readingPositions).insert(position);
  }

  // ─── Cached Content DAOs ──────────────────────────────

  Future<List<CachedDua>> getCachedDuas() =>
      (select(cachedDuas)..orderBy([(d) => OrderingTerm.asc(d.sortOrder)])).get();

  Future<List<CachedDua>> getCachedDuasByCategory(String categoryId) =>
      (select(cachedDuas)..where((d) => d.categoryId.equals(categoryId))
        ..orderBy([(d) => OrderingTerm.asc(d.sortOrder)])).get();

  Future<List<CachedDua>> searchCachedDuas(String query) =>
      (select(cachedDuas)..where((d) =>
          d.title.like('%$query%') | d.arabicText.like('%$query%'))
        ..limit(50)).get();

  Future<void> upsertCachedDua(CachedDuasCompanion dua) =>
      into(cachedDuas).insertOnConflictUpdate(dua);

  Future<List<CachedPodcast>> getCachedPodcasts() =>
      (select(cachedPodcasts)..orderBy([(p) => OrderingTerm.desc(p.publishedAt)])).get();

  Future<List<CachedPodcast>> searchCachedPodcasts(String query) =>
      (select(cachedPodcasts)..where((p) =>
          p.title.like('%$query%') | p.description.like('%$query%'))
        ..limit(50)).get();

  Future<void> upsertCachedPodcast(CachedPodcastsCompanion podcast) =>
      into(cachedPodcasts).insertOnConflictUpdate(podcast);

  Future<List<CachedVideo>> getCachedVideos() =>
      (select(cachedVideos)..orderBy([(v) => OrderingTerm.desc(v.publishedAt)])).get();

  Future<List<CachedVideo>> searchCachedVideos(String query) =>
      (select(cachedVideos)..where((v) =>
          v.title.like('%$query%') | v.description.like('%$query%'))
        ..limit(50)).get();

  Future<void> upsertCachedVideo(CachedVideosCompanion video) =>
      into(cachedVideos).insertOnConflictUpdate(video);

  Future<List<CachedPdf>> getCachedPdfs() =>
      (select(cachedPdfs)..orderBy([(p) => OrderingTerm.desc(p.publishedAt)])).get();

  Future<List<CachedPdf>> searchCachedPdfs(String query) =>
      (select(cachedPdfs)..where((p) =>
          p.title.like('%$query%') | p.description.like('%$query%'))
        ..limit(50)).get();

  Future<void> upsertCachedPdf(CachedPdfsCompanion pdf) =>
      into(cachedPdfs).insertOnConflictUpdate(pdf);

  Future<List<CachedCategory>> getCachedCategories() =>
      (select(cachedCategories)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();

  Future<List<CachedCategory>> getCachedCategoriesByType(String type) =>
      (select(cachedCategories)..where((c) => c.type.equals(type))
        ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();

  Future<void> upsertCachedCategory(CachedCategoriesCompanion category) =>
      into(cachedCategories).insertOnConflictUpdate(category);

  // ─── Downloaded PDFs ──────────────────────────────────

  Future<List<DownloadedPdf>> getDownloadedPdfs() =>
      (select(downloadedPdfs)..orderBy([(d) => OrderingTerm.desc(d.downloadedAt)])).get();

  Future<DownloadedPdf?> getDownloadedPdf(String pdfRemoteId) =>
      (select(downloadedPdfs)..where((d) => d.pdfRemoteId.equals(pdfRemoteId)))
          .getSingleOrNull();

  Future<void> addDownloadedPdf(DownloadedPdfsCompanion pdf) =>
      into(downloadedPdfs).insert(pdf);

  Future<void> removeDownloadedPdf(String pdfRemoteId) =>
      (delete(downloadedPdfs)..where((d) => d.pdfRemoteId.equals(pdfRemoteId))).go();

  // ─── Sync Metadata ───────────────────────────────────

  Future<SyncMetadataData?> getSyncMetadata(String entityType) =>
      (select(syncMetadata)..where((s) => s.entityType.equals(entityType)))
          .getSingleOrNull();

  Future<void> updateSyncMetadata(String entityType, DateTime lastSync) =>
      into(syncMetadata).insertOnConflictUpdate(
        SyncMetadataCompanion(
          entityType: Value(entityType),
          lastSyncAt: Value(lastSync),
        ),
      );

  // ─── Settings ────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final result = await (select(appSettings)
      ..where((s) => s.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion(
          key: Value(key),
          value: Value(value),
        ),
      );

  // ─── Utility ─────────────────────────────────────────

  Future<int> getSurahCount() async {
    final count = countAll();
    final query = selectOnly(surahs)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<void> clearCache() async {
    await delete(cachedDuas).go();
    await delete(cachedPodcasts).go();
    await delete(cachedVideos).go();
    await delete(cachedPdfs).go();
    await delete(cachedCategories).go();
    await delete(syncMetadata).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, AppConstants.dbName));
    return NativeDatabase.createInBackground(file);
  });
}
