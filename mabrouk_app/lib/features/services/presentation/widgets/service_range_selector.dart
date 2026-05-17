import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/bookings/presentation/booking_notifier.dart';
import 'package:mabrouk_app/features/auth/presentation/auth_state.dart';

import '../../domain/service_models.dart';

class ServiceRangeSelector extends ConsumerWidget {
  final ServiceBase service;

  const ServiceRangeSelector({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingNotifierProvider);
    final notifier = ref.read(bookingNotifierProvider.notifier);
    final authState = ref.watch(authStateProvider);

    final bool isCustomer =
        authState is AuthSuccess && authState.user.role == 'customer';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSelectionBox(
                context,
                AppStrings.fromDate.tr,
                bookingState.selectedDateRange?.start != null
                    ? DateFormat('yyyy-MM-dd')
                        .format(bookingState.selectedDateRange!.start)
                    : '--:--',
                Icons.calendar_today_rounded,
                isCustomer
                    ? () => _selectSingleDate(
                          context,
                          true,
                          notifier,
                          bookingState.selectedDateRange?.start,
                        )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectionBox(
                context,
                AppStrings.toDate.tr,
                bookingState.selectedDateRange?.end != null
                    ? DateFormat('yyyy-MM-dd')
                        .format(bookingState.selectedDateRange!.end)
                    : '--:--',
                Icons.event_rounded,
                isCustomer
                    ? () => _selectSingleDate(
                          context,
                          false,
                          notifier,
                          bookingState.selectedDateRange?.end,
                        )
                    : null,
              ),
            ),
          ],
        ),
        if (service.offeringType == OfferingType.booking) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSelectionBox(
                  context,
                  AppStrings.fromTime.tr,
                  bookingState.startTime?.format(context) ?? '--:--',
                  Icons.access_time_filled_rounded,
                  isCustomer
                      ? () => _selectTime(context, true, notifier, bookingState)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSelectionBox(
                  context,
                  AppStrings.toTime.tr,
                  bookingState.endTime?.format(context) ?? '--:--',
                  Icons.schedule_rounded,
                  isCustomer
                      ? () => _selectTime(context, false, notifier, bookingState)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionBox(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback? onTap,
  ) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    final bool isEnabled = onTap != null;
    final bool hasValue = value != '--:--';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: maroon.withOpacity(0.06),
        highlightColor: maroon.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white.withOpacity(isEnabled ? 0.95 : 0.55),
                beige.withOpacity(isEnabled ? 0.45 : 0.25),
              ],
            ),
            border: Border.all(
              color: hasValue
                  ? maroon.withOpacity(0.22)
                  : maroon.withOpacity(0.10),
              width: hasValue ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: maroon.withOpacity(isEnabled ? 0.10 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.75),
                blurRadius: 10,
                offset: const Offset(-3, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: hasValue
                        ? [
                            maroon,
                            maroon.withOpacity(0.82),
                          ]
                        : [
                            maroon.withOpacity(0.10),
                            maroon.withOpacity(0.04),
                          ],
                  ),
                  boxShadow: hasValue
                      ? [
                          BoxShadow(
                            color: maroon.withOpacity(0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  color: hasValue ? Colors.white : maroon,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        color: maroon.withOpacity(0.50),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: hasValue ? 14.5 : 14,
                        height: 1.15,
                        color: hasValue
                            ? maroon
                            : maroon.withOpacity(0.45),
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

  Future<void> _selectSingleDate(
    BuildContext context,
    bool isStart,
    BookingNotifier notifier,
    DateTime? current,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryMaroon,
              onPrimary: Colors.white,
              surface: AppTheme.luxuryBeige,
              onSurface: AppTheme.primaryMaroon,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        notifier.setStartDate(picked);
      } else {
        notifier.setEndDate(picked);
      }
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    bool isStart,
    BookingNotifier notifier,
    BookingState state,
  ) async {
    final TimeOfDay initialTime = isStart
        ? (state.startTime?.replacing(minute: 0) ??
            const TimeOfDay(hour: 12, minute: 0))
        : (state.endTime?.replacing(minute: 0) ??
            const TimeOfDay(hour: 12, minute: 0));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryMaroon,
              onPrimary: Colors.white,
              surface: AppTheme.luxuryBeige,
              onSurface: AppTheme.primaryMaroon,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay hourOnly = picked.replacing(minute: 0);

      if (isStart) {
        notifier.setStartTime(hourOnly);
      } else {
        notifier.setEndTime(hourOnly);
      }
    }
  }
}