import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/providers/app_providers.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
  };
}

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(apiClient, storage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthNotifier(this._apiClient, this._storage) : super(const AuthState()) {
    checkSavedAuth();
  }

  Future<void> checkSavedAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _storage.getToken();
      final userDataStr = await _storage.getUserData();

      if (token != null && userDataStr != null) {
        final user = UserModel.fromJson(jsonDecode(userDataStr));
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, clearUser: true);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, clearUser: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['accessToken'] as String;
        final refreshToken = response.data['refreshToken'] as String;
        final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);

        await _storage.saveToken(accessToken);
        await _storage.saveRefreshToken(refreshToken);
        await _storage.saveUserData(jsonEncode(user.toJson()));

        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: 'بيانات الدخول غير صحيحة');
      return false;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] as String? ?? 'فشل الاتصال بالخادم';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'حدث خطأ غير متوقع');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.dio.post('/auth/register', data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      });

      if (response.statusCode == 201 && response.data != null) {
        final accessToken = response.data['accessToken'] as String;
        final refreshToken = response.data['refreshToken'] as String;
        final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);

        await _storage.saveToken(accessToken);
        await _storage.saveRefreshToken(refreshToken);
        await _storage.saveUserData(jsonEncode(user.toJson()));

        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: 'تعذر إنشاء الحساب');
      return false;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] as String? ?? 'فشل إنشاء الحساب';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'حدث خطأ غير متوقع');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAuth();
    state = const AuthState();
  }
}
