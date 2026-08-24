import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

/// Configured Dio HTTP client for API communication.
class ApiClient {
  late final Dio dio;
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Auth interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try refresh token
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            // Retry the original request
            final token = await _storage.getToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
        }
        handler.next(error);
      },
    ));

    // Logging in debug
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (log) {
        // Only log in debug mode
        assert(() {
          // ignore: avoid_print
          print(log);
          return true;
        }());
      },
    ));
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
      )).post('/auth/refresh', data: {'refreshToken': refreshToken});

      if (response.statusCode == 200) {
        await _storage.saveToken(response.data['accessToken']);
        await _storage.saveRefreshToken(response.data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
