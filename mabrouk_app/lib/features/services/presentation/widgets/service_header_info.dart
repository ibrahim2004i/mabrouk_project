import 'package:flutter/material.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/submit_complaint_dialog.dart';
import '../../domain/service_models.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/features/auth/presentation/auth_state.dart';

class ServiceHeaderInfo extends ConsumerWidget {
  final ServiceBase service;
  const ServiceHeaderInfo({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final bool isCustomer =
        authState is AuthSuccess && authState.user.role == 'customer';

    const maroon = AppTheme.primaryMaroon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),

        Column(
  children: [
    Text(
      service.title,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w900,
        color: maroon,
        height: 1.25,
      ),
    ),

    const SizedBox(height: 10),

    Center(
      child: Container(
        height: 3,
        width: (service.title.length * 11).clamp(90, 260).toDouble(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              maroon.withOpacity(0.15),
              maroon,
              maroon.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    ),
  ],
),

const SizedBox(height: 16),

        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 10,
          children: [
            if (service.cityName != null)
              _infoBadge(
                icon: Icons.location_on_rounded,
                text: service.cityName!,
              ),

            _infoBadge(
              icon: Icons.star_rounded,
              text:
                  '${service.overallRating.toStringAsFixed(1)} (${service.reviewsCount})',
            ),

            if (isCustomer)
              _reportBadge(
                context: context,
                service: service,
              ),
          ],
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.58),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: maroon.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: maroon.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  service.offeringType == OfferingType.purchase
                      ? AppStrings.approvedSalePrice.tr
                      : AppStrings.priceFrom.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: maroon.withOpacity(0.55),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '${service.price} ${AppStrings.currency.tr}',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: maroon,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (service.offeringType == OfferingType.purchase) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: service.stockCount > 0
                    ? maroon.withOpacity(0.08)
                    : Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: service.stockCount > 0
                      ? maroon.withOpacity(0.12)
                      : Colors.red.withOpacity(0.20),
                ),
              ),
              child: Text(
                service.stockCount > 0
                    ? '${service.stockCount} ${AppStrings.availablePieces.tr}'
                    : AppStrings.outOfStock.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: service.stockCount > 0 ? maroon : Colors.red,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoBadge({
    required IconData icon,
    required String text,
  }) {
    const maroon = AppTheme.primaryMaroon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: maroon.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: maroon.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: maroon),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: maroon,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportBadge({
    required BuildContext context,
    required ServiceBase service,
  }) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (c) => SubmitComplaintDialog(
          providerId: service.providerId,
          providerName: service.brandName ?? AppStrings.reportProvider.tr,
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.report_problem_outlined,
              color: Colors.redAccent,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              AppStrings.reportProvider.tr,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}