import 'package:flutter/material.dart';

/// Arabic localization strings for حوة.
/// All user-facing text is centralized here.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // Navigation
      'home': 'الرئيسية',
      'quran': 'القرآن',
      'hadith': 'الأحاديث',
      'content': 'المحتوى',
      'more': 'المزيد',

      // Features
      'tasbih': 'التسبيح',
      'qibla': 'القبلة',
      'duas': 'الأدعية',
      'podcasts': 'البودكاست',
      'videos': 'الفيديوهات',
      'books': 'الكتب',
      'bookmarks': 'المحفوظات',
      'favorites': 'المفضلة',
      'settings': 'الإعدادات',

      // Quran
      'quran_kareem': 'القرآن الكريم',
      'surah': 'سورة',
      'ayah': 'آية',
      'juz': 'جزء',
      'page': 'صفحة',
      'meccan': 'مكية',
      'medinan': 'مدنية',
      'verses': 'آيات',
      'continue_reading': 'متابعة القراءة',
      'search_quran': 'البحث في القرآن',
      'bookmark_added': 'تمت إضافة العلامة',
      'bookmark_removed': 'تمت إزالة العلامة',

      // Hadith
      'sahih_bukhari': 'صحيح البخاري',
      'sahih_muslim': 'صحيح مسلم',
      'hadith_number': 'حديث رقم',
      'chapter': 'باب',
      'search_hadith': 'البحث في الأحاديث',

      // Tasbih
      'tap_to_count': 'اضغط للتسبيح',
      'target': 'الهدف',
      'reset': 'إعادة',
      'save': 'حفظ',
      'history': 'السجل',
      'subhanallah': 'سبحان الله',
      'alhamdulillah': 'الحمد لله',
      'allahuakbar': 'الله أكبر',
      'la_ilaha_illallah': 'لا إله إلا الله',
      'astaghfirullah': 'أستغفر الله',
      'select_dhikr': 'اختر الذكر',
      'count_saved': 'تم حفظ العدد',

      // Qibla
      'qibla_direction': 'اتجاه القبلة',
      'calibrate_compass': 'قم بتحريك الجهاز لمعايرة البوصلة',
      'location_permission_required': 'يلزم إذن الموقع لتحديد اتجاه القبلة',
      'sensor_not_available': 'مستشعر البوصلة غير متوفر في هذا الجهاز',
      'grant_permission': 'منح الإذن',
      'open_settings': 'فتح الإعدادات',

      // Content
      'latest': 'الأحدث',
      'categories': 'التصنيفات',
      'all': 'الكل',
      'search': 'بحث',
      'no_results': 'لا توجد نتائج',
      'loading': 'جاري التحميل...',
      'retry': 'إعادة المحاولة',
      'share': 'مشاركة',
      'open': 'فتح',
      'download': 'تحميل',
      'downloading': 'جاري التحميل...',
      'downloaded': 'تم التحميل',
      'delete_download': 'حذف التحميل',
      'read': 'قراءة',

      // Auth
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'name': 'الاسم',
      'admin_dashboard': 'لوحة التحكم',

      // Admin
      'manage': 'إدارة',
      'add': 'إضافة',
      'edit': 'تعديل',
      'delete': 'حذف',
      'publish': 'نشر',
      'unpublish': 'إلغاء النشر',
      'published': 'منشور',
      'draft': 'مسودة',
      'confirm_delete': 'هل أنت متأكد من الحذف؟',
      'title': 'العنوان',
      'description': 'الوصف',
      'url': 'الرابط',
      'category': 'التصنيف',
      'save_changes': 'حفظ التغييرات',
      'created_successfully': 'تم الإنشاء بنجاح',
      'updated_successfully': 'تم التحديث بنجاح',
      'deleted_successfully': 'تم الحذف بنجاح',

      // Settings
      'language': 'اللغة',
      'theme': 'المظهر',
      'light_mode': 'فاتح',
      'dark_mode': 'داكن',
      'system_mode': 'تلقائي',
      'font_size': 'حجم الخط',
      'small': 'صغير',
      'medium': 'متوسط',
      'large': 'كبير',
      'downloaded_files': 'الملفات المحملة',
      'clear_cache': 'مسح التخزين المؤقت',
      'about': 'عن التطبيق',
      'privacy_policy': 'سياسة الخصوصية',

      // Errors
      'error_no_internet': 'لا يوجد اتصال بالإنترنت',
      'error_server': 'حدث خطأ في الخادم',
      'error_unknown': 'حدث خطأ غير متوقع',
      'error_auth': 'خطأ في المصادقة',
      'error_permission': 'الإذن مرفوض',
      'error_not_found': 'غير موجود',
      'error_invalid_credentials': 'بيانات الدخول غير صحيحة',
      'error_file_not_found': 'الملف غير موجود',
      'error_download_failed': 'فشل التحميل',

      // General
      'cancel': 'إلغاء',
      'ok': 'موافق',
      'yes': 'نعم',
      'no': 'لا',
      'close': 'إغلاق',
      'done': 'تم',
      'empty_list': 'لا توجد عناصر',

      // Data
      'importing_data': 'جاري تجهيز البيانات...',
      'importing_quran': 'جاري تحميل القرآن الكريم...',
      'importing_hadith': 'جاري تحميل الأحاديث...',
      'data_ready': 'البيانات جاهزة',

      // Attribution
      'quran_source': 'نص القرآن من Tanzil.net',
      'hadith_source': 'نصوص الأحاديث من Sunnah.com',
    },
    'en': {
      'home': 'Home',
      'quran': 'Quran',
      'hadith': 'Hadith',
      'content': 'Content',
      'more': 'More',
      'tasbih': 'Tasbih',
      'qibla': 'Qibla',
      'duas': 'Duas',
      'podcasts': 'Podcasts',
      'videos': 'Videos',
      'books': 'Books',
      'bookmarks': 'Bookmarks',
      'favorites': 'Favorites',
      'settings': 'Settings',
      'quran_kareem': 'Holy Quran',
      'loading': 'Loading...',
      'retry': 'Retry',
      'search': 'Search',
      'no_results': 'No results found',
      'error_no_internet': 'No internet connection',
      'error_server': 'Server error occurred',
      'error_unknown': 'An unexpected error occurred',
      'cancel': 'Cancel',
      'ok': 'OK',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['ar']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension for easy access in widgets
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).get(key);
}
