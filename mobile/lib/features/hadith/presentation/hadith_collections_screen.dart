import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/database/app_database.dart';

class HadithCollectionsScreen extends ConsumerWidget {
  const HadithCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأحاديث النبوية الشريفة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'بحث في الأحاديث',
            onPressed: () => context.push('/hadith/search'),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'المحفوظات',
            onPressed: () => context.push('/bookmarks'),
          ),
        ],
      ),
      body: FutureBuilder<List<HadithCollection>>(
        future: db.getAllCollections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final collections = snapshot.data ?? [];
          if (collections.isEmpty) {
            return const Center(
              child: Text('جاري تحميل كتب الحديث...'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    context.push(
                      '/hadith/collection/${collection.id}?title=${Uri.encodeComponent(collection.nameAr)}',
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withAlpha(60)),
                          ),
                          child: const Icon(Icons.auto_stories, color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                collection.nameAr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${collection.totalHadiths > 0 ? collection.totalHadiths : "آلاف"} حديث شريف',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
