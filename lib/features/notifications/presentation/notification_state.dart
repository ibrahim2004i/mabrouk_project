import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/features/notifications/domain/notification_model.dart';
import 'package:mabrouk_app/features/notifications/data/notification_repository.dart';

final notificationStateProvider = StateNotifierProvider.autoDispose<NotificationNotifier, AsyncValue<List<AppNotification>>>((ref) {
  return NotificationNotifier(ref.watch(notificationRepoProvider));
});

class NotificationNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationRepository _repo;

  NotificationNotifier(this._repo) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getNotifications());
  }

  Future<void> markAsRead({int? id}) async {
    try {
      await _repo.markAsRead(id: id);
      // 🔥 Quick local update
      if (state.hasValue) {
        final currentList = state.value!;
        final updatedList = currentList.map((n) {
          if (id == null || n.id == id) {
            return AppNotification(
              id: n.id,
              title: n.title,
              message: n.message,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (e) {
      // Fail silently or handle error
    }
  }

  int get unreadCount {
    if (!state.hasValue) return 0;
    return state.value!.where((n) => !n.isRead).length;
  }
}
