import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/data_import_service.dart';
import '../../core/services/sync_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _statusText = 'جاري تحضير التطبيق...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final db = ref.read(databaseProvider);
    final importService = DataImportService(db);

    try {
      final isImported = await importService.isDataImported();
      if (!isImported) {
        setState(() {
          _statusText = 'جاري تهيئة قاعدة البيانات لأول مرة...';
        });

        await importService.importAll(
          onProgress: (status) {
            if (mounted) {
              setState(() {
                _statusText = status;
              });
            }
          },
        );
      }

      // Trigger background sync if online
      try {
        final apiClient = ref.read(apiClientProvider);
        final syncService = SyncService(apiClient: apiClient, db: db);
        syncService.syncAll().ignore();
      } catch (_) {}

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _statusText = 'تعذر تحميل البيانات المحلية الأولية. يمكنك المتابعة.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'حوة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'حوة — تطبيق إسلامي شامل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'القرآن • الأحاديث • الأذكار • القبلة • المحتوى الإسلامي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.secondaryLight,
                ),
              ),
              const SizedBox(height: 48),
              if (!_hasError) ...[
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusText,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  _statusText,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.black87,
                  ),
                  onPressed: () => context.go('/home'),
                  child: const Text('المتابعة إلى الرئيسية'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
