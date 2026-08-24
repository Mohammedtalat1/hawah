import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حوة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'المحفوظات والمفضلة',
            onPressed: () => context.push('/bookmarks'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'البحث في القرآن',
            onPressed: () => context.push('/quran/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh trigger
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // 1. Header Banner
            _buildWelcomeCard(context, isDark),
            const SizedBox(height: 16),

            // 2. Last Reading Card
            _buildContinueReadingCard(context, db),
            const SizedBox(height: 20),

            // 3. Quick Islamic Services Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'الخدمات الإسلامية',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            _buildServicesGrid(context),
            const SizedBox(height: 24),

            // 4. Featured Dua Card
            _buildFeaturedDuaCard(context, db),
            const SizedBox(height: 24),

            // 5. Latest Podcasts & Videos
            _buildLatestContentSection(context, db),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE، d MMMM y', 'ar');
    final dateString = formatter.format(now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateString,
                style: const TextStyle(
                  color: AppColors.secondaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.mosque,
                color: AppColors.secondaryLight,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'السلام عليكم ورحمة الله وبركاته',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '«أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Amiri',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueReadingCard(BuildContext context, AppDatabase db) {
    return FutureBuilder<ReadingPosition?>(
      future: db.getLastReadingPosition(),
      builder: (context, snapshot) {
        final position = snapshot.data;
        if (position == null) return const SizedBox.shrink();

        return FutureBuilder<Surah?>(
          future: db.getSurah(position.surahId),
          builder: (context, surahSnapshot) {
            final surah = surahSnapshot.data;
            if (surah == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () {
                  context.push('/quran/surah/${surah.id}?ayah=${position.ayahId}');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'متابعة القراءة',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'سورة ${surah.name} — آية ${position.ayahId}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondaryDark),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {'title': 'القرآن الكريم', 'icon': Icons.menu_book, 'color': const Color(0xFF0D7377), 'route': '/quran'},
      {'title': 'الأحاديث النبوية', 'icon': Icons.auto_stories, 'color': const Color(0xFF14A3A8), 'route': '/hadith'},
      {'title': 'التسبيح الرقمي', 'icon': Icons.fingerprint, 'color': const Color(0xFFC9963B), 'route': '/tasbih'},
      {'title': 'اتجاه القبلة', 'icon': Icons.explore, 'color': const Color(0xFF9E7328), 'route': '/qibla'},
      {'title': 'الأدعية والأذكار', 'icon': Icons.favorite_border, 'color': const Color(0xFF2E7D32), 'route': '/duas'},
      {'title': 'البودكاست', 'icon': Icons.podcasts, 'color': const Color(0xFF6A1B9A), 'route': '/podcasts'},
      {'title': 'الفيديوهات', 'icon': Icons.play_circle_outline, 'color': const Color(0xFFC2185B), 'route': '/videos'},
      {'title': 'مكتبة الكتب', 'icon': Icons.picture_as_pdf, 'color': const Color(0xFF1565C0), 'route': '/pdfs'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.82,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final item = services[index];
          final color = item['color'] as Color;

          return InkWell(
            onTap: () => context.push(item['route'] as String),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withAlpha(40), width: 1),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedDuaCard(BuildContext context, AppDatabase db) {
    return FutureBuilder<List<CachedDua>>(
      future: db.getCachedDuas(),
      builder: (context, snapshot) {
        final duas = snapshot.data ?? [];
        final hasDua = duas.isNotEmpty;
        final duaTitle = hasDua ? duas.first.title : 'دعاء اليوم';
        final duaText = hasDua
            ? duas.first.arabicText
            : 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dividerLight.withAlpha(100)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        duaTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/duas'),
                    child: const Text('المزيد'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                duaText,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 17,
                  height: 1.8,
                  color: AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLatestContentSection(BuildContext context, AppDatabase db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المحتوى المتجدد', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => context.go('/content'),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<CachedPodcast>>(
          future: db.getCachedPodcasts(),
          builder: (context, snapshot) {
            final podcasts = snapshot.data ?? [];
            if (podcasts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'يمكنك الاستماع إلى البودكاست وتصفح الفيديوهات والكتب في قسم المحتوى',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: podcasts.length,
                itemBuilder: (context, index) {
                  final podcast = podcasts[index];
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.podcasts, size: 18, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text('بودكاست', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              podcast.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Spacer(),
                            Text(
                              podcast.publisher ?? '',
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
