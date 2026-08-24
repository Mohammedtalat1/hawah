import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/database/app_database.dart';

class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'بحث في آيات القرآن',
            onPressed: () => context.push('/quran/search'),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'العلامات المرجعية',
            onPressed: () => context.push('/bookmarks'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم السورة...',
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
            child: FutureBuilder<List<Surah>>(
              future: db.getAllSurahs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final surahs = snapshot.data ?? [];
                if (surahs.isEmpty) {
                  return const Center(
                    child: Text('جاري تحميل بيانات السور...'),
                  );
                }

                final filtered = _searchQuery.isEmpty
                    ? surahs
                    : surahs.where((s) {
                        return s.name.contains(_searchQuery) ||
                            s.transliteration.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            s.id.toString() == _searchQuery;
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('لا توجد نتائج مطابقة'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(indent: 72, height: 1),
                  itemBuilder: (context, index) {
                    final surah = filtered[index];
                    final isMeccan = surah.type.toLowerCase() == 'meccan';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withAlpha(20),
                          border: Border.all(color: AppColors.primary.withAlpha(60)),
                        ),
                        child: Center(
                          child: Text(
                            '${surah.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            surah.name,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isMeccan
                                  ? AppColors.secondary.withAlpha(25)
                                  : AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isMeccan ? 'مكية' : 'مدنية',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isMeccan ? AppColors.secondaryDark : AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            surah.transliteration,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${surah.totalVerses} آية',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: () {
                        context.push('/quran/surah/${surah.id}');
                      },
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
