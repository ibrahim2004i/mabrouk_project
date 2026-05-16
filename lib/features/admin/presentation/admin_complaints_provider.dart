import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';

final adminComplaintsProvider = AsyncNotifierProvider.autoDispose<AdminComplaintsNotifier, List<Map<String, dynamic>>>(() {
  return AdminComplaintsNotifier();
});

class AdminComplaintsNotifier extends AutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    return ref.watch(adminRepoProvider).getComplaints();
  }

  Future<void> resolve(int id, String notes) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(adminRepoProvider).resolveComplaint(id, notes);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
