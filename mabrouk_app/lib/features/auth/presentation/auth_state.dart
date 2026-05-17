import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/storage/local_storage.dart';
import 'package:mabrouk_app/features/auth/data/auth_repository.dart';
import 'package:mabrouk_app/features/auth/domain/auth_models.dart';
import 'package:mabrouk_app/features/notifications/presentation/notification_state.dart';
import 'package:mabrouk_app/features/bookings/presentation/booking_providers.dart';
import 'package:mabrouk_app/features/bookings/presentation/provider_bookings_screen.dart';
import 'package:mabrouk_app/features/admin/presentation/admin_moderation_screen.dart';
import 'package:mabrouk_app/features/admin/presentation/admin_complaints_provider.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepoProvider);
  final storage = ref.watch(localStorageProvider);
  return AuthStateNotifier(repo, storage, ref);
});

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final AuthUser user;
  AuthSuccess(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final LocalStorageService _storage;
  final Ref _ref;

  AuthStateNotifier(this._repo, this._storage, this._ref) : super(AuthInitial()) {
    checkInitialAuth();
  }

  Future<void> checkInitialAuth() async {
    final token = _storage.getToken();
    final user = _storage.getUser();

    if (token != null && user != null) {
      state = AuthSuccess(user);
    }
  }

  Future<void> login(String phone, String password) async {
    state = AuthLoading();
    try {
      final response = await _repo.login(phone, password);
      
      await _storage.saveToken(response.token);
      await _storage.saveRole(response.user.role);
      await _storage.saveUser(response.user);
      
      state = AuthSuccess(response.user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    
    // 🔥 Clear/Invalidate all data-related providers on logout
    _ref.invalidate(notificationStateProvider);
    _ref.invalidate(myBookingsProvider);
    _ref.invalidate(providerBookingsProvider);
    _ref.invalidate(adminPendingProvider);
    _ref.invalidate(adminPendingProvidersProvider);
    _ref.invalidate(adminComplaintsProvider);
    
    state = AuthInitial();
  }

  Future<void> registerCustomer({
    required String phone,
    required String password,
    required String name,
  }) async {
    state = AuthLoading();
    try {
      await _repo.registerCustomer(phone, password, name);
      // Auto-login after customer registration
      await login(phone, password);
    } catch (e) {
      state = AuthError(e.toString());
      rethrow;
    }
  }

  Future<void> registerProvider({
    required String phone,
    required String password,
    required String brandName,
    required int cityId,
  }) async {
    state = AuthLoading();
    try {
      await _repo.registerProvider(
        phone: phone,
        password: password,
        brandName: brandName,
        cityId: cityId,
      );
      state = AuthInitial(); // Successful registration but not logged in yet
    } catch (e) {
      state = AuthError(e.toString());
      rethrow;
    }
  }

  Future<void> updateUserProfile(AuthUser newUser) async {
    await _storage.saveRole(newUser.role);
    await _storage.saveUser(newUser);
    state = AuthSuccess(newUser);
  }
}
