import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المزيد'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // User / Admin Profile Header
          if (authState.isAuthenticated)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      authState.user?.name.isNotEmpty == true ? authState.user!.name[0] : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.name ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          authState.user?.email ?? '',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (authState.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'مدير',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Core Islamic Utilities
          _buildSectionHeader('الأدوات والخدمات'),
          _buildTile(
            icon: Icons.fingerprint,
            color: AppColors.secondary,
            title: 'المسبحة الإلكترونية',
            onTap: () => context.push('/tasbih'),
          ),
          _buildTile(
            icon: Icons.explore,
            color: AppColors.secondaryDark,
            title: 'اتجاه القبلة الشريفة',
            onTap: () => context.push('/qibla'),
          ),
          _buildTile(
            icon: Icons.bookmark,
            color: AppColors.primary,
            title: 'المحفوظات والعلامات المرجعية',
            onTap: () => context.push('/bookmarks'),
          ),

          const SizedBox(height: 16),

          // Admin Section (Only if Admin or Login button)
          _buildSectionHeader('لوحة الإدارة والمحتوى'),
          if (authState.isAdmin)
            _buildTile(
              icon: Icons.admin_panel_settings,
              color: Colors.deepOrange,
              title: 'لوحة تحكم المدير',
              subtitle: 'إدارة الأدعية والبودكاست والفيديوهات والكتب والتصنيفات',
              onTap: () => context.push('/admin'),
            )
          else
            _buildTile(
              icon: Icons.lock_outline,
              color: Colors.blueGrey,
              title: 'تسجيل دخول الإدارة',
              subtitle: 'لإدارة المحتوى ونشر المواد الجديدة',
              onTap: () => context.push('/login'),
            ),

          const SizedBox(height: 16),

          // Settings & System
          _buildSectionHeader('التطبيق والنظام'),
          _buildTile(
            icon: Icons.settings,
            color: Colors.grey,
            title: 'الإعدادات والمظهر',
            onTap: () => context.push('/settings'),
          ),

          if (authState.isAuthenticated)
            _buildTile(
              icon: Icons.logout,
              color: AppColors.error,
              title: 'تسجيل الخروج',
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تسجيل الخروج')),
                  );
                }
              },
            ),

          const SizedBox(height: 24),

          // Attribution
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'تطبيق ${AppConstants.appName} الإصدار ${AppConstants.appVersion}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                const Text(
                  'نص القرآن الكريم موثق من Tanzil.net\nالأحاديث النبوية موثقة من Sunnah.com',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryDark,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
