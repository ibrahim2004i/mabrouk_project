import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/auth_state.dart';
import '../../features/services/domain/service_models.dart';
import '../../features/services/presentation/favorites_notifier.dart';
import 'guest_notice_dialog.dart';

class ServiceCard extends StatelessWidget {
  final ServiceBase service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color maroon = Color(0xFF600000);
    const Color beige = AppTheme.luxuryBeige;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
        decoration: BoxDecoration(
          color: beige,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: maroon.withOpacity(0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.14),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    color: beige,
                    child: service.logoUrl != null && service.logoUrl!.isNotEmpty
                        ? Image.network(
                            service.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 45,
                                    color: maroon.withOpacity(0.35),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppStrings.imageNotAvailable.tr,
                                    style: TextStyle(
                                      color: maroon.withOpacity(0.45),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;

                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: maroon.withOpacity(0.35),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 45,
                              color: maroon.withOpacity(0.25),
                            ),
                          ),
                  ),

                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              maroon.withOpacity(0.05),
                              Colors.transparent,
                              maroon.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (service.offeringType == OfferingType.purchase)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _typeBadge(
                        icon: Icons.shopping_bag_outlined,
                        text: AppStrings.forSalePurchase.tr,
                      ),
                    ),

                  if (service.offeringType == OfferingType.booking)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _typeBadge(
                        icon: Icons.calendar_today_outlined,
                        text: AppStrings.availableForBooking.tr,
                      ),
                    ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final authState = ref.watch(authStateProvider);
                        final favorites = ref.watch(favoritesProvider);
                        final isFav =
                            favorites.contains("${service.type}_${service.id}");

                        return GestureDetector(
                          onTap: () {
                            if (authState is! AuthSuccess) {
                              GuestNoticeDialog.show(context);
                              return;
                            }

                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(
                                  service.type,
                                  service.id.toString(),
                                );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: beige.withOpacity(0.95),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: maroon.withOpacity(0.15),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: maroon.withOpacity(0.18),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              color: isFav ? maroon : maroon.withOpacity(0.45),
                              size: 21,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: beige,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            service.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: maroon,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: maroon.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: maroon.withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${service.price} ${AppStrings.currency.tr}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: maroon,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (service.offeringType == OfferingType.booking)
                                Text(
                                  service.priceUnit == PriceUnit.hour
                                      ? AppStrings.perHourShort.tr
                                      : (service.priceUnit == PriceUnit.day
                                          ? AppStrings.perDayShort.tr
                                          : AppStrings.perEventShort.tr),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: maroon.withOpacity(0.55),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: maroon.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 17,
                            color: maroon,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.overallRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: maroon,
                            ),
                          ),
                          Text(
                            ' (${service.reviewsCount})',
                            style: TextStyle(
                              color: maroon.withOpacity(0.55),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          if (service.cityName != null) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: maroon.withOpacity(0.65),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              service.cityName!,
                              style: TextStyle(
                                color: maroon.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],

                          const SizedBox(width: 10),
                          Icon(
                            Icons.verified_user_outlined,
                            size: 15,
                            color: maroon.withOpacity(0.6),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              service.brandName ??
                                  AppStrings.mabroukDistributor.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: maroon.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeBadge({
    required IconData icon,
    required String text,
  }) {
    const Color maroon = Color(0xFF600000);
    const Color beige = AppTheme.luxuryBeige;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: maroon.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: beige.withOpacity(0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: beige, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: beige,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}