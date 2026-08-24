import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/main_navigation/main_navigation_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/quran/presentation/surah_list_screen.dart';
import '../../features/quran/presentation/quran_reader_screen.dart';
import '../../features/quran/presentation/quran_search_screen.dart';
import '../../features/hadith/presentation/hadith_collections_screen.dart';
import '../../features/hadith/presentation/hadith_list_screen.dart';
import '../../features/hadith/presentation/hadith_search_screen.dart';
import '../../features/content/content_hub_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/tasbih/tasbih_screen.dart';
import '../../features/qibla/qibla_screen.dart';
import '../../features/duas/duas_screen.dart';
import '../../features/podcasts/podcasts_screen.dart';
import '../../features/videos/videos_screen.dart';
import '../../features/pdfs/pdfs_screen.dart';
import '../../features/pdfs/pdf_viewer_screen.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_duas_screen.dart';
import '../../features/admin/presentation/admin_podcasts_screen.dart';
import '../../features/admin/presentation/admin_videos_screen.dart';
import '../../features/admin/presentation/admin_pdfs_screen.dart';
import '../../features/admin/presentation/admin_categories_screen.dart';
import '../../features/auth/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/quran',
            pageBuilder: (context, state) => const NoTransitionPage(child: SurahListScreen()),
          ),
          GoRoute(
            path: '/hadith',
            pageBuilder: (context, state) => const NoTransitionPage(child: HadithCollectionsScreen()),
          ),
          GoRoute(
            path: '/content',
            pageBuilder: (context, state) => const NoTransitionPage(child: ContentHubScreen()),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => const NoTransitionPage(child: MoreScreen()),
          ),
        ],
      ),
      // Quran subroutes
      GoRoute(
        path: '/quran/surah/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final surahId = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          final initialAyah = int.tryParse(state.uri.queryParameters['ayah'] ?? '1') ?? 1;
          return QuranReaderScreen(surahId: surahId, initialAyah: initialAyah);
        },
      ),
      GoRoute(
        path: '/quran/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QuranSearchScreen(),
      ),
      // Hadith subroutes
      GoRoute(
        path: '/hadith/collection/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final collectionId = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          final title = state.uri.queryParameters['title'] ?? 'الأحاديث';
          return HadithListScreen(collectionId: collectionId, title: title);
        },
      ),
      GoRoute(
        path: '/hadith/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HadithSearchScreen(),
      ),
      // Islamic features
      GoRoute(
        path: '/tasbih',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TasbihScreen(),
      ),
      GoRoute(
        path: '/qibla',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QiblaScreen(),
      ),
      GoRoute(
        path: '/duas',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DuasScreen(),
      ),
      GoRoute(
        path: '/podcasts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PodcastsScreen(),
      ),
      GoRoute(
        path: '/videos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VideosScreen(),
      ),
      GoRoute(
        path: '/pdfs',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PdfsScreen(),
      ),
      GoRoute(
        path: '/pdfs/viewer',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'] ?? '';
          final title = state.uri.queryParameters['title'] ?? 'عرض الكتاب';
          return PdfViewerScreen(filePath: filePath, title: title);
        },
      ),
      GoRoute(
        path: '/bookmarks',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      // Admin dashboard routes with route protection
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) {
          if (!authState.isAdmin) {
            return '/login';
          }
          return null;
        },
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'duas',
            builder: (context, state) => const AdminDuasScreen(),
          ),
          GoRoute(
            path: 'podcasts',
            builder: (context, state) => const AdminPodcastsScreen(),
          ),
          GoRoute(
            path: 'videos',
            builder: (context, state) => const AdminVideosScreen(),
          ),
          GoRoute(
            path: 'pdfs',
            builder: (context, state) => const AdminPdfsScreen(),
          ),
          GoRoute(
            path: 'categories',
            builder: (context, state) => const AdminCategoriesScreen(),
          ),
        ],
      ),
    ],
  );
});
