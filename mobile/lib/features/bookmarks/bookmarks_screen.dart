import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openBookmark(Bookmark item) {
    switch (item.type) {
      case 'quran':
        final parts = item.referenceId.split(':');
        final surahId = int.tryParse(parts[0]) ?? 1;
        final ayahNumber = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
        context.push('/quran/surah/$surahId?ayah=$ayahNumber');
        break;
      case 'hadith':
        final parts = item.referenceId.split(':');
        final collectionId = int.tryParse(parts[0]) ?? 1;
        context.push('/hadith/collection/$collectionId?title=${Uri.encodeComponent("الأحاديث")}');
        break;
      case 'dua':
        context.push('/duas');
        break;
      case 'podcast':
        context.push('/podcasts');
        break;
      case 'video':
        context.push('/videos');
        break;
      case 'pdf':
        context.push('/pdfs');
        break;
    }
  }

  Widget _buildBookmarkList(String type) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<Bookmark>>(
      future: type == 'media'
          ? db.getAllBookmarks().then((all) => all.where((b) => ['podcast', 'video', 'pdf'].contains(b.type)).toList())
          : db.getBookmarksByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(
            child: Text('لا توجد عناصر محفوظة في هذا القسم'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];

            return ListTile(
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: item.subtitle.isNotEmpty
                  ? Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () async {
                  await db.removeBookmark(item.type, item.referenceId);
                  setState(() {});
                },
              ),
              onTap: () => _openBookmark(item),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفوظات والعلامات'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          tabs: const [
            Tab(text: 'القرآن'),
            Tab(text: 'الأحاديث'),
            Tab(text: 'الأدعية'),
            Tab(text: 'الوسائط'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookmarkList('quran'),
          _buildBookmarkList('hadith'),
          _buildBookmarkList('dua'),
          _buildBookmarkList('media'),
        ],
      ),
    );
  }
}
