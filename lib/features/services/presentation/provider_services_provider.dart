import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/features/services/data/service_repository.dart';

final myServicesProvider = FutureProvider.autoDispose.family<List<dynamic>, int?>((ref, providerId) async {
  return ref.watch(serviceRepoProvider).getMyServices(providerId: providerId);
});
