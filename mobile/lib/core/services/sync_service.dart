import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';
import '../constants/app_constants.dart';

/// Background and foreground synchronization service.
/// Fetches latest online content updates incrementally and updates Drift/SQLite.
class SyncService {
  final ApiClient apiClient;
  final AppDatabase db;

  SyncService({required this.apiClient, required this.db});

  /// Perform incremental sync for all online content categories and items.
  Future<void> syncAll() async {
    try {
      final syncMeta = await db.getSyncMetadata('all');
      String? updatedSince;
      if (syncMeta != null) {
        updatedSince = syncMeta.lastSyncAt.toIso8601String();
      }

      final response = await apiClient.dio.get(
        '/sync/all',
        queryParameters: updatedSince != null ? {'updated_since': updatedSince} : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        final syncTimestampStr = response.data['sync_timestamp'] as String?;
        final syncTimestamp = syncTimestampStr != null
            ? DateTime.tryParse(syncTimestampStr) ?? DateTime.now()
            : DateTime.now();

        // 1. Sync Categories
        if (data['categories'] is List) {
          for (final cat in data['categories']) {
            await db.upsertCachedCategory(
              CachedCategoriesCompanion(
                remoteId: Value(cat['id'] as String),
                name: Value(cat['name'] as String? ?? ''),
                nameAr: Value(cat['name_ar'] as String? ?? ''),
                type: Value(cat['type'] as String? ?? 'dua'),
                sortOrder: Value(cat['sort_order'] as int? ?? 0),
                updatedAt: Value(DateTime.tryParse(cat['updated_at'] ?? '') ?? DateTime.now()),
              ),
            );
          }
        }

        // 2. Sync Duas
        if (data['duas'] is List) {
          for (final item in data['duas']) {
            final category = item['category'] as Map<String, dynamic>?;
            await db.upsertCachedDua(
              CachedDuasCompanion(
                remoteId: Value(item['id'] as String),
                title: Value(item['title'] as String),
                arabicText: Value(item['arabic_text'] as String),
                translation: Value(item['translation'] as String?),
                transliteration: Value(item['transliteration'] as String?),
                source: Value(item['source'] as String?),
                categoryId: Value(item['category_id'] as String?),
                categoryName: Value(category?['name_ar'] as String?),
                sortOrder: Value(item['sort_order'] as int? ?? 0),
                createdAt: Value(DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now()),
                updatedAt: Value(DateTime.tryParse(item['updated_at'] ?? '') ?? DateTime.now()),
              ),
            );
          }
        }

        // 3. Sync Podcasts
        if (data['podcasts'] is List) {
          for (final item in data['podcasts']) {
            final category = item['category'] as Map<String, dynamic>?;
            await db.upsertCachedPodcast(
              CachedPodcastsCompanion(
                remoteId: Value(item['id'] as String),
                title: Value(item['title'] as String),
                description: Value(item['description'] as String?),
                thumbnailUrl: Value(item['thumbnail_url'] as String?),
                podcastUrl: Value(item['podcast_url'] as String),
                publisher: Value(item['publisher'] as String?),
                duration: Value(item['duration'] as String?),
                categoryId: Value(item['category_id'] as String?),
                categoryName: Value(category?['name_ar'] as String?),
                publishedAt: Value(item['published_at'] != null
                    ? DateTime.tryParse(item['published_at'])
                    : null),
                createdAt: Value(DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now()),
                updatedAt: Value(DateTime.tryParse(item['updated_at'] ?? '') ?? DateTime.now()),
              ),
            );
          }
        }

        // 4. Sync Videos
        if (data['videos'] is List) {
          for (final item in data['videos']) {
            final category = item['category'] as Map<String, dynamic>?;
            await db.upsertCachedVideo(
              CachedVideosCompanion(
                remoteId: Value(item['id'] as String),
                title: Value(item['title'] as String),
                description: Value(item['description'] as String?),
                thumbnailUrl: Value(item['thumbnail_url'] as String?),
                videoUrl: Value(item['video_url'] as String),
                publisher: Value(item['publisher'] as String?),
                categoryId: Value(item['category_id'] as String?),
                categoryName: Value(category?['name_ar'] as String?),
                publishedAt: Value(item['published_at'] != null
                    ? DateTime.tryParse(item['published_at'])
                    : null),
                createdAt: Value(DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now()),
                updatedAt: Value(DateTime.tryParse(item['updated_at'] ?? '') ?? DateTime.now()),
              ),
            );
          }
        }

        // 5. Sync PDFs
        if (data['pdfs'] is List) {
          for (final item in data['pdfs']) {
            final category = item['category'] as Map<String, dynamic>?;
            await db.upsertCachedPdf(
              CachedPdfsCompanion(
                remoteId: Value(item['id'] as String),
                title: Value(item['title'] as String),
                description: Value(item['description'] as String?),
                coverUrl: Value(item['cover_url'] as String?),
                pdfUrl: Value(item['pdf_url'] as String),
                author: Value(item['author'] as String?),
                fileSize: Value(item['file_size'] as String?),
                pageCount: Value(item['page_count'] as int?),
                categoryId: Value(item['category_id'] as String?),
                categoryName: Value(category?['name_ar'] as String?),
                isDownloadable: Value(item['is_downloadable'] as bool? ?? true),
                publishedAt: Value(item['published_at'] != null
                    ? DateTime.tryParse(item['published_at'])
                    : null),
                createdAt: Value(DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now()),
                updatedAt: Value(DateTime.tryParse(item['updated_at'] ?? '') ?? DateTime.now()),
              ),
            );
          }
        }

        // Update sync timestamp
        await db.updateSyncMetadata('all', syncTimestamp);
      }
    } on DioException {
      // Offline or network error: gracefully ignore to allow offline usage
    } catch (_) {
      // Ignore unexpected sync failures to keep the app functional
    }
  }
}
