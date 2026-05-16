import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/auth_state.dart';
import '../../../bookings/presentation/booking_notifier.dart';
import '../../domain/service_models.dart';

class BookingFloatingPanel extends ConsumerWidget {
  final ServiceBase service;
  const BookingFloatingPanel({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingNotifierProvider);

    ref.listen(bookingNotifierProvider, (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        _showBookingSuccess(context);
        ref.read(bookingNotifierProvider.notifier).reset();
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        if (next.errorMessage == 'CONFLICT' && next.conflictData != null) {
          _showConflictDialog(context, next.conflictData!);
        } else if (next.errorMessage!.isNotEmpty) {
          _showLuxurySnackBar(
            context,
            next.errorMessage!,
            icon: Icons.error_outline_rounded,
          );
        }
      }
    });

    final total =
        ref.read(bookingNotifierProvider.notifier).calculateTotalPrice(service);

    final unitText = service.offeringType == OfferingType.purchase
        ? AppStrings.perPiece.tr
        : (service.priceUnit == PriceUnit.hour
            ? AppStrings.perHour.tr
            : (service.priceUnit == PriceUnit.day
                ? AppStrings.perDay.tr
                : AppStrings.perEvent.tr));

    final bool isOutOfStock =
        service.offeringType == OfferingType.purchase && service.stockCount <= 0;

    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      decoration: BoxDecoration(
        color: beige,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        border: Border.all(
          color: maroon.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: maroon.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: maroon.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      service.offeringType == OfferingType.purchase
                          ? Icons.shopping_bag_rounded
                          : Icons.event_available_rounded,
                      color: maroon,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${AppStrings.totalPrice.tr} ($unitText)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: maroon.withOpacity(0.55),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${total.toStringAsFixed(0)} ${AppStrings.currency.tr}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: maroon,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (service.offeringType == OfferingType.booking &&
                      service.priceUnit != PriceUnit.event) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: maroon.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: maroon.withOpacity(0.10),
                        ),
                      ),
                      child: Text(
                        '${service.price.toStringAsFixed(0)} ${AppStrings.perSingleUnit.tr}',
                        style: const TextStyle(
                          color: maroon,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (bookingState.isLoading || isOutOfStock)
                      ? null
                      : () => _handleBooking(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOutOfStock ? Colors.grey : maroon,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.65),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: bookingState.isLoading
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            color: beige,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isOutOfStock
                                  ? Icons.block_rounded
                                  : (service.offeringType ==
                                          OfferingType.purchase
                                      ? Icons.shopping_cart_checkout_rounded
                                      : Icons.check_circle_rounded),
                              color: beige,
                              size: 21,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isOutOfStock
                                  ? AppStrings.outOfStock.tr
                                  : (service.offeringType ==
                                          OfferingType.purchase
                                      ? AppStrings.completePurchaseNow.tr
                                      : AppStrings.confirmBookingRequest.tr),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: beige,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBooking(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    if (authState is! AuthSuccess) {
      _showAuthDialog(context);
      return;
    }

    ref.read(bookingNotifierProvider.notifier).submitBooking(service);
  }

  void _showLuxurySnackBar(
    BuildContext context,
    String message, {
    required IconData icon,
  }) {
    _showLuxuryWarningDialog(
      context,
      title: message,
      icon: icon,
    );
  }

  void _showLuxuryWarningDialog(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? subtitle,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: AppTheme.luxuryBeige,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppTheme.primaryMaroon.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryMaroon.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryMaroon,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.primaryMaroon,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  height: 1.5,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primaryMaroon.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppTheme.primaryMaroon.withOpacity(0.18),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.diamond_rounded,
                      size: 13,
                      color: AppTheme.primaryMaroon.withOpacity(0.22),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppTheme.primaryMaroon.withOpacity(0.18),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMaroon,
                    foregroundColor: AppTheme.luxuryBeige,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppStrings.ok.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAuthDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppTheme.luxuryBeige,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppTheme.primaryMaroon.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_outlined,
                size: 38,
                color: AppTheme.primaryMaroon,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.loginRequiredTitle.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: AppTheme.primaryMaroon,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.loginToBookMessage.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.primaryMaroon.withOpacity(0.62),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(c);
                context.push('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMaroon,
                foregroundColor: AppTheme.luxuryBeige,
                elevation: 0,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                AppStrings.loginNowButton.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.luxuryBeige,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: AppTheme.primaryMaroon.withOpacity(0.12),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppTheme.primaryMaroon.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTheme.primaryMaroon,
                size: 52,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              AppStrings.bookingSuccessTitle.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.primaryMaroon,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: 130,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(c);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryMaroon,
                  foregroundColor: AppTheme.luxuryBeige,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  AppStrings.ok.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConflictDialog(BuildContext context, Map<String, dynamic> conflict) {
    showDialog(
      context: context,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.luxuryBeige,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppTheme.primaryMaroon.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryMaroon.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_rounded,
                  color: AppTheme.primaryMaroon,
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppStrings.slotNotAvailable.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.primaryMaroon,
                  fontWeight: FontWeight.w900,
                  fontSize: 21,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.busyPeriodMessage.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppTheme.primaryMaroon.withOpacity(0.70),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppTheme.primaryMaroon.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  children: [
                    _conflictTimeRow(
                      icon: Icons.play_arrow_rounded,
                      label: AppStrings.from.tr,
                      date: '${conflict['start_date']}',
                      time: '${conflict['start_time']}',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        width: 2,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMaroon.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    _conflictTimeRow(
                      icon: Icons.flag_rounded,
                      label: AppStrings.to.tr,
                      date: '${conflict['end_date']}',
                      time: '${conflict['end_time']}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.chooseAnotherSlot.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primaryMaroon.withOpacity(0.48),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMaroon,
                    foregroundColor: AppTheme.luxuryBeige,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    AppStrings.ok.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conflictTimeRow({
    required IconData icon,
    required String label,
    required String date,
    required String time,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppTheme.primaryMaroon.withOpacity(0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$date | $time',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppTheme.primaryMaroon,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.primaryMaroon.withOpacity(0.08),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryMaroon,
            size: 22,
          ),
        ),
      ],
    );
  }
}