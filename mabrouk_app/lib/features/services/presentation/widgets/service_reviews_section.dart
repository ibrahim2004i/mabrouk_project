import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/services/domain/service_models.dart';
import 'package:mabrouk_app/features/services/domain/review_model.dart';
import 'package:mabrouk_app/features/services/presentation/reviews_provider.dart';
import 'package:mabrouk_app/features/services/presentation/service_providers.dart';
import 'package:mabrouk_app/features/services/data/review_repository.dart';
import 'package:mabrouk_app/features/auth/presentation/auth_state.dart';
import 'package:mabrouk_app/shared/widgets/add_review_dialog.dart';
import 'package:mabrouk_app/shared/widgets/guest_notice_dialog.dart';

class ServiceReviewsSection extends ConsumerWidget {
  final ServiceBase service;
  const ServiceReviewsSection({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync =
        ref.watch(serviceReviewsProvider((service.type, service.id)));
    final authState = ref.watch(authStateProvider);
    final bool isCustomer =
        authState is AuthSuccess && authState.user.role == 'customer';

    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (isCustomer)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showAddReview(context, ref),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          maroon,
                          maroon.withOpacity(0.82),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: maroon.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.rate_review_rounded,
                          size: 16,
                          color: beige,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          AppStrings.addYourReview.tr,
                          style: const TextStyle(
                            color: beige,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const Spacer(),
            _buildSectionTitle(
              '${AppStrings.userReviews.tr} (${service.reviewsCount})',
            ),
          ],
        ),
        const SizedBox(height: 16),
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.white.withOpacity(0.92),
                      beige.withOpacity(0.45),
                    ],
                  ),
                  border: Border.all(color: maroon.withOpacity(0.10)),
                  boxShadow: [
                    BoxShadow(
                      color: maroon.withOpacity(0.07),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: maroon.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.reviews_outlined,
                        color: maroon.withOpacity(0.65),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.noReviewsYet.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: maroon.withOpacity(0.70),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (c, i) => const SizedBox(height: 13),
              itemBuilder: (c, i) {
                final review = reviews[i];
                return _ReviewTile(
                  review: review,
                  providerId: service.providerId,
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: maroon),
            ),
          ),
          error: (err, stack) => Center(
            child: Text(
              '${AppStrings.loadReviewsError.tr}: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: maroon),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryMaroon,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 5,
            height: 26,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryMaroon,
                  AppTheme.primaryMaroon.withOpacity(0.55),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      );

  void _showAddReview(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    if (authState is! AuthSuccess) {
      GuestNoticeDialog.show(context);
      return;
    }

    showDialog(
      context: context,
      builder: (c) => AddReviewDialog(
        providerId: service.providerId,
        serviceType: service.type,
        serviceId: service.id,
        serviceName: service.title,
        onReviewAdded: () {
          ref.invalidate(serviceReviewsProvider);
          ref.invalidate(servicesProvider);
        },
      ),
    );
  }
}

class _ReviewTile extends ConsumerWidget {
  final Review review;
  final int providerId;
  const _ReviewTile({required this.review, required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final bool isProvider = authState is AuthSuccess &&
        authState.user.role == 'provider' &&
        authState.user.id == providerId;
    final bool isAdmin =
        authState is AuthSuccess && authState.user.role == 'admin';

    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white.withOpacity(0.94),
            beige.withOpacity(0.38),
          ],
        ),
        border: Border.all(color: maroon.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.09),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.75),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              if (isProvider || isAdmin)
                InkWell(
                  onTap: () => _confirmDeleteReview(context, ref, review.id),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 19,
                    ),
                  ),
                ),
              const Spacer(),
              _buildStarsView(review.rating),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      review.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                        color: maroon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review.formattedDate,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        color: maroon.withOpacity(0.45),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      maroon.withOpacity(0.14),
                      beige.withOpacity(0.85),
                    ],
                  ),
                  border: Border.all(color: maroon.withOpacity(0.12)),
                ),
                child: Center(
                  child: Text(
                    review.customerName.isNotEmpty
                        ? review.customerName[0]
                        : 'U',
                    style: const TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.62),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: maroon.withOpacity(0.08)),
              ),
              child: Text(
                review.comment!,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarsView(int count) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            maroon.withOpacity(0.10),
            beige.withOpacity(0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: maroon.withOpacity(0.08)),
      ),
      child: Row(
        children: List.generate(
          5,
          (index) => Icon(
            index < count ? Icons.star_rounded : Icons.star_outline_rounded,
            color: maroon,
            size: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteReview(
    BuildContext context,
    WidgetRef ref,
    int reviewId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          AppStrings.deleteReviewTitle.tr,
          textAlign: TextAlign.right,
        ),
        content: Text(
          AppStrings.deleteReviewConfirm.tr,
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(AppStrings.cancel.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(
              AppStrings.delete.tr,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(reviewRepoProvider).deleteReview(reviewId);
        ref.invalidate(serviceReviewsProvider);
        ref.invalidate(servicesProvider);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.reviewDeletedSuccess.tr)),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.deleteFailed.tr}: $e')),
        );
      }
    }
  }
}