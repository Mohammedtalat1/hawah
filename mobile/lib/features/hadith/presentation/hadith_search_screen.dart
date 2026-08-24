import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/database/app_database.dart';

class HadithSearchScreen extends ConsumerStatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  ConsumerState<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends ConsumerState<HadithSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Hadith> _results = [];
  bool _isSearching = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || trimmed == _lastQuery) return;

    setState(() {
      _isSearching = true;
      _lastQuery = trimmed;
    });

    final db = ref.read(databaseProvider);
    final results = await db.searchHadiths(trimmed);

    if (mounted) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ابحث في نصوص الأحاديث النبوية...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
          onChanged: (val) {
            if (val.length >= 3) {
              _performSearch(val);
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _results = [];
                  _lastQuery = '';
                });
              },
            ),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _lastQuery.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'اكتب نصاً للبحث في الأحاديث النبوية',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : _results.isEmpty
                  ? const Center(child: Text('لم يتم العثور على أحاديث مطابقة للبحث'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _results.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final hadith = _results[index];
                        final bookName = hadith.collectionId == 1 ? 'صحيح البخاري' : 'صحيح مسلم';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            hadith.arabic,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 17,
                              height: 1.8,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '$bookName — حديث رقم ${hadith.hadithNumber}',
                              style: const TextStyle(
                                color: AppColors.secondaryDark,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.share, size: 18),
                            onPressed: () {
                              Share.share(
                                '${hadith.arabic}\n\n[$bookName — حديث رقم ${hadith.hadithNumber}]\n\nعبر تطبيق حوة',
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
