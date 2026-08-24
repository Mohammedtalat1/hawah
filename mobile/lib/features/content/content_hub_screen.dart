import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class ContentHubScreen extends StatelessWidget {
  const ContentHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحتوى الإسلامي'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHubCard(
            context: context,
            title: 'الأدعية والأذكار',
            subtitle: 'أذكار الصباح والمساء، أدعية القرآن، وأدعية الأنبياء',
            icon: Icons.favorite_border,
            color: const Color(0xFF2E7D32),
            route: '/duas',
          ),
          const SizedBox(height: 14),
          _buildHubCard(
            context: context,
            title: 'البودكاست الإسلامي',
            subtitle: 'برامج وحلقات إسلامية مسموعة من كبار العلماء والقراء',
            icon: Icons.podcasts,
            color: const Color(0xFF6A1B9A),
            route: '/podcasts',
          ),
          const SizedBox(height: 14),
          _buildHubCard(
            context: context,
            title: 'الفيديوهات والدروس المرئية',
            subtitle: 'سلاسل ودروس مرئية في التفسير والفقه والتربية',
            icon: Icons.play_circle_outline,
            color: const Color(0xFFC2185B),
            route: '/videos',
          ),
          const SizedBox(height: 14),
          _buildHubCard(
            context: context,
            title: 'مكتبة الكتب الإسلامية (PDF)',
            subtitle: 'كتب ومراجع إسلامية موثوقة مع إمكانية التحميل والقراءة دون إنترنت',
            icon: Icons.picture_as_pdf,
            color: const Color(0xFF1565C0),
            route: '/pdfs',
          ),
        ],
      ),
    );
  }

  Widget _buildHubCard({
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
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withAlpha(50)),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
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
