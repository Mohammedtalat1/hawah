import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fontScale = ref.watch(fontSizeProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Theme Setting
          _buildHeader('المظهر والسمة'),
          ListTile(
            leading: const Icon(Icons.brightness_6, color: AppColors.primary),
            title: const Text('نمط المظهر'),
            subtitle: Text(
              themeMode == ThemeMode.light
                  ? 'الوضع الفاتح'
                  : themeMode == ThemeMode.dark
                      ? 'الوضع الداكن'
                      : 'تلقائي حسب النظام',
            ),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('تلقائي')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('فاتح')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('داكن')),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                }
              },
            ),
          ),

          const Divider(height: 1),

          // Font Scale
          _buildHeader('الخط والقراءة'),
          ListTile(
            leading: const Icon(Icons.format_size, color: AppColors.primary),
            title: const Text('حجم خط نصوص القرآن'),
            subtitle: Text('${(fontScale * 100).toInt()}%'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('أ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Slider(
                    value: fontScale,
                    min: 0.8,
                    max: 1.6,
                    divisions: 8,
                    label: '${(fontScale * 100).toInt()}%',
                    onChanged: (val) {
                      ref.read(fontSizeProvider.notifier).setFontSize(val);
                    },
                  ),
                ),
                const Text('أ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const Divider(height: 1),

          // Cache & Storage
          _buildHeader('التخزين والذاكرة المؤقتة'),
          ListTile(
            leading: const Icon(Icons.cleaning_services, color: AppColors.secondary),
            title: const Text('مسح الذاكرة المؤقتة للمحتوى'),
            subtitle: const Text('حذف النسخ المخزنة مؤقتاً من الأدعية والبودكاست والبيانات'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تأكيد مسح الذاكرة المؤقتة'),
                  content: const Text('هل أنت متأكد من مسح الذاكرة المؤقتة للمحتوى المتزامن؟ سيبقى القرآن والأحاديث دون تأثر.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('مسح')),
                  ],
                ),
              );

              if (confirmed == true) {
                await db.clearCache();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم مسح الذاكرة المؤقتة بنجاح')),
                  );
                }
              }
            },
          ),

          const Divider(height: 1),

          // About & Privacy
          _buildHeader('عن التطبيق'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('عن تطبيق حوة'),
            subtitle: const Text('تطبيق إسلامي شامل يعمل بدون إنترنت مع محتوى متجدد'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
                applicationLegalese: 'جميع الحقوق محفوظة © 2026 حوة\n\nنص القرآن موثق من Tanzil.net\nالأحاديث موثقة من Sunnah.com',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
            title: const Text('سياسة الخصوصية'),
            subtitle: const Text('بياناتك محلية على جهازك ولا نجمع بيانات شخصية'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('سياسة الخصوصية'),
                  content: const Text(
                    'تطبيق حوة مصمم على أساس الخصوصية أولاً.\n\n'
                    '• لا يقوم التطبيق بتتبع موقعك أو تخزينه في أي خوادم خارجية.\n'
                    '• يتم استخدام إذن الموقع محلياً على هاتفك فقط لحساب اتجاه القبلة.\n'
                    '• تظل جميع علاماتك وقراءاتك وسجلات التسبيح على جهازك الشخصي.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
}
