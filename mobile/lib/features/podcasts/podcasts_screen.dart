import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';

class PodcastsScreen extends ConsumerStatefulWidget {
  const PodcastsScreen({super.key});

  @override
  ConsumerState<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends ConsumerState<PodcastsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح رابط البودكاست')),
        );
      }
    }
  }

  void _toggleBookmark(CachedPodcast podcast) async {
    final db = ref.read(databaseProvider);
    final isBookmarked = await db.isBookmarked('podcast', podcast.remoteId);

    if (isBookmarked) {
      await db.removeBookmark('podcast', podcast.remoteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إزالة البودكاست من المحفوظات')),
        );
      }
    } else {
      await db.addBookmark(
        BookmarksCompanion(
          type: const drift.Value('podcast'),
          referenceId: drift.Value(podcast.remoteId),
          title: drift.Value(podcast.title),
          subtitle: drift.Value(podcast.publisher ?? ''),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ البودكاست في المحفوظات')),
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
        title: const Text('البودكاست الإسلامي'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث في حلقات البودكاست...',
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
            child: FutureBuilder<List<CachedPodcast>>(
              future: _searchQuery.isNotEmpty
                  ? db.searchCachedPodcasts(_searchQuery)
                  : db.getCachedPodcasts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final podcasts = snapshot.data ?? [];
                if (podcasts.isEmpty) {
                  return const Center(
                    child: Text('لا توجد حلقات بودكاست متوفرة حالياً'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: podcasts.length,
                  itemBuilder: (context, index) {
                    final podcast = podcasts[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: AppColors.primary.withAlpha(30),
                                child: podcast.thumbnailUrl != null && podcast.thumbnailUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: podcast.thumbnailUrl!,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => const Icon(Icons.podcasts, size: 36, color: AppColors.primary),
                                      )
                                    : const Icon(Icons.podcasts, size: 36, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    podcast.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (podcast.publisher != null)
                                    Text(
                                      podcast.publisher!,
                                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryDark),
                                    ),
                                  if (podcast.duration != null)
                                    Text(
                                      'المدة: ${podcast.duration}',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                            // Actions
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 36),
                                  tooltip: 'استماع',
                                  onPressed: () => _launchUrl(podcast.podcastUrl),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FutureBuilder<bool>(
                                      future: db.isBookmarked('podcast', podcast.remoteId),
                                      builder: (context, snapshot) {
                                        final isBookmarked = snapshot.data ?? false;
                                        return IconButton(
                                          icon: Icon(
                                            isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                            size: 18,
                                            color: isBookmarked ? AppColors.secondary : null,
                                          ),
                                          onPressed: () => _toggleBookmark(podcast),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share, size: 18),
                                      onPressed: () {
                                        Share.share('${podcast.title}\n${podcast.podcastUrl}\n\nعبر تطبيق حوة');
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
            ),
          ),
        ],
      ),
    );
  }
}
