import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';

class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBookmark(CachedDua dua) async {
    final db = ref.read(databaseProvider);
    final refId = dua.remoteId;
    final isBookmarked = await db.isBookmarked('dua', refId);

    if (isBookmarked) {
      await db.removeBookmark('dua', refId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إزالة الدعاء من المحفوظات')),
        );
      }
    } else {
      await db.addBookmark(
        BookmarksCompanion(
          type: const drift.Value('dua'),
          referenceId: drift.Value(refId),
          title: drift.Value(dua.title),
          subtitle: drift.Value(dua.arabicText.length > 80 ? '${dua.arabicText.substring(0, 80)}...' : dua.arabicText),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الدعاء في المحفوظات')),
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
        title: const Text('الأدعية والأذكار'),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث في الأدعية والأذكار...',
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

          // Categories Filter Chips
          FutureBuilder<List<CachedCategory>>(
            future: db.getCachedCategoriesByType('dua'),
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('الكل'),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) {
                          setState(() => _selectedCategoryId = null);
                        },
                      ),
                    ),
                    ...categories.map((cat) {
                      final isSelected = _selectedCategoryId == cat.remoteId;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(cat.nameAr),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = selected ? cat.remoteId : null;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),

          // Duas List
          Expanded(
            child: FutureBuilder<List<CachedDua>>(
              future: _searchQuery.isNotEmpty
                  ? db.searchCachedDuas(_searchQuery)
                  : _selectedCategoryId != null
                      ? db.getCachedDuasByCategory(_selectedCategoryId!)
                      : db.getCachedDuas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final duas = snapshot.data ?? [];
                if (duas.isEmpty) {
                  return const Center(
                    child: Text('لا توجد أدعية متوفرة حالياً'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: duas.length,
                  itemBuilder: (context, index) {
                    final dua = duas[index];
                    final refId = dua.remoteId;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    dua.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    FutureBuilder<bool>(
                                      future: db.isBookmarked('dua', refId),
                                      builder: (context, snapshot) {
                                        final isBookmarked = snapshot.data ?? false;
                                        return IconButton(
                                          icon: Icon(
                                            isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                            size: 20,
                                            color: isBookmarked ? AppColors.secondary : null,
                                          ),
                                          onPressed: () => _toggleBookmark(dua),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 20),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                          text: '${dua.title}\n\n${dua.arabicText}\n\n${dua.source ?? ""}',
                                        ));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('تم نسخ الدعاء إلى الحافظة')),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share, size: 20),
                                      onPressed: () {
                                        Share.share(
                                          '${dua.title}\n\n${dua.arabicText}\n\n${dua.source ?? ""}\n\nعبر تطبيق حوة',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              dua.arabicText,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                height: 1.9,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            if (dua.translation != null && dua.translation!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                dua.translation!,
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                            if (dua.source != null && dua.source!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'المصدر: ${dua.source}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryDark),
                                ),
                              ),
                            ],
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
