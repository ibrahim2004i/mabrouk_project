import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/features/services/domain/review_model.dart';
import 'package:mabrouk_app/features/services/data/review_repository.dart';

final serviceReviewsProvider = FutureProvider.family<List<Review>, (String, int)>((ref, arg) {
  final type = arg.$1;
  final id = arg.$2;
  return ref.watch(reviewRepoProvider).getServiceReviews(type, id);
});
