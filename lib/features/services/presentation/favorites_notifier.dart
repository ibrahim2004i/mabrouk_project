import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/features/auth/presentation/auth_state.dart';
import 'package:mabrouk_app/features/services/data/favorite_repository.dart';

import '../../../core/storage/local_storage.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final storage = ref.watch(localStorageProvider);
  final repo = ref.watch(favoriteRepoProvider);
  final authState = ref.watch(authStateProvider);
  
  final notifier = FavoritesNotifier(storage, repo, authState);
  
  // Auto-sync when user logs in
  if (authState is AuthSuccess) {
    notifier.syncWithServer();
  }
  
  return notifier;
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final LocalStorageService _storage;
  final FavoriteRepository _repo;
  final AuthState _authState;

  FavoritesNotifier(this._storage, this._repo, this._authState) : super({}) {
    _loadLocalFavorites();
  }

  void _loadLocalFavorites() {
    final list = _storage.getFavorites();
    state = list.toSet();
  }

  /// 🔄 Sync local favorites with the server
  Future<void> syncWithServer() async {
    if (_authState is! AuthSuccess) return;

    try {
      // 1. Fetch from server
      final serverFavs = await _repo.getFavorites();
      
      // 2. Merge with local (Guest favorites migration)
      final merged = {...state, ...serverFavs};
      
      // 3. If there were local favorites not on server, sync them UP
      for (final fav in state) {
        if (!serverFavs.contains(fav)) {
          final parts = fav.split('_');
          if (parts.length == 2) {
            await _repo.toggleFavorite(parts[0], parts[1]);
          }
        }
      }

      state = merged;
      await _storage.saveFavorites(state.toList());
    } catch (_) {
      // Silently fail or handle error
    }
  }

  Future<void> toggleFavorite(String type, String id) async {
    final compositeId = "${type}_$id";
    final newState = {...state};
    
    // Optimistic UI Update
    if (newState.contains(compositeId)) {
      newState.remove(compositeId);
    } else {
      newState.add(compositeId);
    }
    state = newState;
    await _storage.saveFavorites(state.toList());

    // Sync with server if logged in
    if (_authState is AuthSuccess) {
      try {
        await _repo.toggleFavorite(type, id);
      } catch (e) {
        // Rollback on failure? Or just log.
      }
    }
  }

  bool isFavorite(String type, String id) {
    return state.contains("${type}_$id");
  }
}

