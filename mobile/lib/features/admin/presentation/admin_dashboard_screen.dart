import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/home');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Admin Welcome Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFFFF9800)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً، ${authState.user?.name ?? "المدير"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'إدارة ونشر وتعديل المحتوى المتزامن لتطبيق حوة',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Management Sections
          _buildManagementCard(
            context: context,
            title: 'إدارة الأدعية والأذكار',
            subtitle: 'إضافة وتعديل وحذف ونشر الأدعية والأذكار',
            icon: Icons.favorite_border,
            color: const Color(0xFF2E7D32),
            route: '/admin/duas',
          ),
          const SizedBox(height: 12),
          _buildManagementCard(
            context: context,
            title: 'إدارة البودكاست الإسلامي',
            subtitle: 'إضافة وتعديل روابط الحلقات والناشرين والمدة',
            icon: Icons.podcasts,
            color: const Color(0xFF6A1B9A),
            route: '/admin/podcasts',
          ),
          const SizedBox(height: 12),
          _buildManagementCard(
            context: context,
            title: 'إدارة الفيديوهات والدروس',
            subtitle: 'إضافة وتعديل روابط الفيديوهات والصور المصغرة',
            icon: Icons.play_circle_outline,
            color: const Color(0xFFC2185B),
            route: '/admin/videos',
          ),
          const SizedBox(height: 12),
          _buildManagementCard(
            context: context,
            title: 'إدارة مكتبة الكتب (PDF)',
            subtitle: 'إضافة وتعديل بيانات الكتب وروابط التحميل',
            icon: Icons.picture_as_pdf,
            color: const Color(0xFF1565C0),
            route: '/admin/pdfs',
          ),
          const SizedBox(height: 12),
          _buildManagementCard(
            context: context,
            title: 'إدارة التصنيفات',
            subtitle: 'إضافة وتعديل التصنيفات لجميع أنواع المحتوى',
            icon: Icons.category_outlined,
            color: const Color(0xFF0D7377),
            route: '/admin/categories',
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
  }
}
