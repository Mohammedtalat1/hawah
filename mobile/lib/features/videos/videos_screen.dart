import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';

class VideosScreen extends ConsumerStatefulWidget {
  const VideosScreen({super.key});

  @override
  ConsumerState<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends ConsumerState<VideosScreen> {
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
          const SnackBar(content: Text('تعذر فتح رابط الفيديو')),
        );
      }
    }
  }

  void _toggleBookmark(CachedVideo video) async {
    final db = ref.read(databaseProvider);
    final isBookmarked = await db.isBookmarked('video', video.remoteId);

    if (isBookmarked) {
      await db.removeBookmark('video', video.remoteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إزالة الفيديو من المحفوظات')),
        );
      }
    } else {
      await db.addBookmark(
        BookmarksCompanion(
          type: const drift.Value('video'),
          referenceId: drift.Value(video.remoteId),
          title: drift.Value(video.title),
          subtitle: drift.Value(video.publisher ?? ''),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الفيديو في المحفوظات')),
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
        title: const Text('الفيديوهات والدروس المرئية'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث في الفيديوهات والدروس...',
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
            child: FutureBuilder<List<CachedVideo>>(
              future: _searchQuery.isNotEmpty
                  ? db.searchCachedVideos(_searchQuery)
                  : db.getCachedVideos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final videos = snapshot.data ?? [];
                if (videos.isEmpty) {
                  return const Center(
                    child: Text('لا توجد فيديوهات متوفرة حالياً'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];

                    return Card(
                      child: InkWell(
                        onTap: () => _launchUrl(video.videoUrl),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail Preview with Play Overlay
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: video.thumbnailUrl!,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) => Container(
                                              color: AppColors.primary.withAlpha(40),
                                              child: const Icon(Icons.videocam, size: 48, color: AppColors.primary),
                                            ),
                                          )
                                        : Container(
                                            color: AppColors.primary.withAlpha(40),
                                            child: const Icon(Icons.videocam, size: 48, color: AppColors.primary),
                                          ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(140),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                                ),
                              ],
                            ),
                            // Details
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (video.publisher != null)
                                          Text(
                                            video.publisher!,
                                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryDark),
                                          ),
                                      ],
                                    ),
                                  ),
                                  FutureBuilder<bool>(
                                    future: db.isBookmarked('video', video.remoteId),
                                    builder: (context, snapshot) {
                                      final isBookmarked = snapshot.data ?? false;
                                      return IconButton(
                                        icon: Icon(
                                          isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                          color: isBookmarked ? AppColors.secondary : null,
                                        ),
                                        onPressed: () => _toggleBookmark(video),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {
                                      Share.share('${video.title}\n${video.videoUrl}\n\nعبر تطبيق حوة');
                                    },
                                  ),
                                ],
                              ),
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
