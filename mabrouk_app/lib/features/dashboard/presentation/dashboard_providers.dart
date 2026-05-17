import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/features/dashboard/data/dashboard_repository.dart';

final statsProvider = AsyncNotifierProvider<StatsNotifier, Map<String, dynamic>>(() {
  return StatsNotifier();
});

class StatsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    return ref.watch(dashboardRepoProvider).getStats();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(dashboardRepoProvider).getStats());
  }
}

final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(dashboardRepoProvider).getStats();
});
