/// Error types for the application.
/// Maps to user-friendly Arabic error messages.
enum AppErrorType {
  network,
  server,
  auth,
  notFound,
  permission,
  database,
  fileNotFound,
  downloadFailed,
  sensorUnavailable,
  locationUnavailable,
  unknown,
}

class AppError {
  final AppErrorType type;
  final String message;
  final String? technicalDetails;

  const AppError({
    required this.type,
    required this.message,
    this.technicalDetails,
  });

  factory AppError.network([String? details]) => AppError(
    type: AppErrorType.network,
    message: 'لا يوجد اتصال بالإنترنت',
    technicalDetails: details,
  );

  factory AppError.server([String? details]) => AppError(
    type: AppErrorType.server,
    message: 'حدث خطأ في الخادم',
    technicalDetails: details,
  );

  factory AppError.auth([String? details]) => AppError(
    type: AppErrorType.auth,
    message: 'خطأ في المصادقة',
    technicalDetails: details,
  );

  factory AppError.notFound([String? details]) => AppError(
    type: AppErrorType.notFound,
    message: 'غير موجود',
    technicalDetails: details,
  );

  factory AppError.permission([String? details]) => AppError(
    type: AppErrorType.permission,
    message: 'الإذن مرفوض',
    technicalDetails: details,
  );

  factory AppError.database([String? details]) => AppError(
    type: AppErrorType.database,
    message: 'خطأ في قاعدة البيانات',
    technicalDetails: details,
  );

  factory AppError.downloadFailed([String? details]) => AppError(
    type: AppErrorType.downloadFailed,
    message: 'فشل التحميل',
    technicalDetails: details,
  );

  factory AppError.sensorUnavailable([String? details]) => AppError(
    type: AppErrorType.sensorUnavailable,
    message: 'مستشعر البوصلة غير متوفر في هذا الجهاز',
    technicalDetails: details,
  );

  factory AppError.locationUnavailable([String? details]) => AppError(
    type: AppErrorType.locationUnavailable,
    message: 'تعذر تحديد الموقع',
    technicalDetails: details,
  );

  factory AppError.unknown([String? details]) => AppError(
    type: AppErrorType.unknown,
    message: 'حدث خطأ غير متوقع',
    technicalDetails: details,
  );

  @override
  String toString() => message;
}
