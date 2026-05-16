import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/bookings/domain/booking_model.dart';
import 'package:mabrouk_app/features/auth/presentation/auth_state.dart';
import 'package:mabrouk_app/features/bookings/data/booking_repository.dart';
import 'package:mabrouk_app/features/bookings/presentation/provider_bookings_screen.dart';
import 'package:mabrouk_app/features/services/presentation/service_providers.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  bool _isLoading = false;

  Future<void> _updateBookingStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(bookingRepoProvider)
          .updateBookingStatus(widget.booking.id, status);

      if (mounted) {
        _showLuxurySnackBar(
          '${AppStrings.statusUpdatedTo.tr}: ${_getStatusLabel(status)}',
          icon: status == 'confirmed'
              ? Icons.check_circle_outline_rounded
              : Icons.cancel_outlined,
          success: status == 'confirmed',
        );

        ref.invalidate(providerBookingsProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showLuxurySnackBar(
          '${AppStrings.updateFailed.tr}: $e',
          icon: Icons.error_outline_rounded,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _safeBookingDate() {
    return DateTime.tryParse(widget.booking.bookingDate) ?? DateTime.now();
  }

  TimeOfDay _safeTimeOfDay(String? value, {int fallbackHour = 12}) {
    final hour =
        int.tryParse(value?.split(':').first ?? '$fallbackHour') ??
            fallbackHour;

    return TimeOfDay(
      hour: hour.clamp(0, 23),
      minute: 0,
    );
  }

  Future<void> _reschedule() async {
    DateTime selectedDate = _safeBookingDate();

    TimeOfDay startTime = _safeTimeOfDay(
      widget.booking.bookingTime,
      fallbackHour: 12,
    );

    TimeOfDay endTime = _safeTimeOfDay(
      widget.booking.endTime,
      fallbackHour: startTime.hour + 1,
    );

    if (endTime.hour <= startTime.hour) {
      endTime = TimeOfDay(
        hour: (startTime.hour + 1).clamp(0, 23),
        minute: 0,
      );
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F4F1),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMaroon.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _reschedulePickerButton(
                      icon: Icons.calendar_month_rounded,
                      title: AppStrings.selectNewDate.tr,
                      value: DateFormat('yyyy-MM-dd').format(selectedDate),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate.isBefore(DateTime.now())
                              ? DateTime.now()
                              : selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          helpText: AppStrings.selectNewDate.tr,
                          builder: _pickerThemeBuilder,
                        );

                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    _reschedulePickerButton(
                      icon: Icons.access_time_filled_rounded,
                      title: AppStrings.selectTime.tr,
                      value:
                          '${startTime.format(context)} - ${endTime.format(context)}',
                      onTap: () async {
                        final pickedStart = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                          helpText: AppStrings.selectStartTime.tr,
                          builder: _pickerThemeBuilder,
                        );

                        if (pickedStart == null) return;

                        final newStart = TimeOfDay(
                          hour: pickedStart.hour,
                          minute: 0,
                        );

                        final safeEndInitial = endTime.hour <= newStart.hour
                            ? TimeOfDay(
                                hour: (newStart.hour + 1).clamp(0, 23),
                                minute: 0,
                              )
                            : endTime;

                        final pickedEnd = await showTimePicker(
                          context: context,
                          initialTime: safeEndInitial,
                          helpText: AppStrings.selectEndTime.tr,
                          builder: _pickerThemeBuilder,
                        );

                        if (pickedEnd == null) return;

                        final newEnd = TimeOfDay(
                          hour: pickedEnd.hour,
                          minute: 0,
                        );

                        if (newEnd.hour <= newStart.hour) {
                          _showLuxurySnackBar(
                            AppStrings.endTimeAfterStartTime.tr,
                            icon: Icons.access_time_filled_rounded,
                          );
                          return;
                        }

                        setSheetState(() {
                          startTime = newStart;
                          endTime = newEnd;
                        });
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                Navigator.pop(sheetContext);

                                setState(() => _isLoading = true);

                                try {
                                  final formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(selectedDate);

                                  final sTime =
                                      '${startTime.hour.toString().padLeft(2, '0')}:00:00';

                                  final eTime =
                                      '${endTime.hour.toString().padLeft(2, '0')}:00:00';

                                  await ref
                                      .read(bookingRepoProvider)
                                      .rescheduleBooking(
                                        widget.booking.id,
                                        formattedDate,
                                        sTime,
                                        formattedDate,
                                        eTime,
                                      );

                                  if (!mounted) return;

                                  _showLuxurySnackBar(
                                    AppStrings.rescheduleSuccess.tr,
                                    icon: Icons.check_rounded,
                                    success: true,
                                  );

                                  Navigator.pop(context);
                                } catch (e) {
                                  if (!mounted) return;

                                  _showLuxurySnackBar(
                                    '${AppStrings.error.tr}: $e',
                                    icon: Icons.error_outline_rounded,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.edit_calendar_rounded),
                        label: Text(
                          AppStrings.reschedule.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryMaroon,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _pickerThemeBuilder(BuildContext context, Widget? child) {
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
  }

  void _showLuxurySnackBar(
    String message, {
    required IconData icon,
    bool success = false,
  }) {
    final color = success ? Colors.green : AppTheme.primaryMaroon;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          elevation: 0,
          margin: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: success ? Colors.white : AppTheme.luxuryBeige,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: success ? Colors.white : AppTheme.luxuryBeige,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _reschedulePickerButton({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white,
            border: Border.all(
              color: AppTheme.primaryMaroon.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryMaroon.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppTheme.primaryMaroon.withOpacity(0.50),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppTheme.primaryMaroon,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryMaroon,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    final authState = ref.watch(authStateProvider);
    final isProvider =
        authState is AuthSuccess && authState.user.role == 'provider';

    final serviceAsync = ref.watch(
      serviceDetailsProvider(
        (
          type: widget.booking.serviceType,
          id: widget.booking.serviceId.toString(),
        ),
      ),
    );

    final serviceData = serviceAsync.valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.bookingDetails.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white,
                    beige.withOpacity(0.45),
                  ],
                ),
                border: Border.all(color: maroon.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: maroon.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _getStatusColor(widget.booking.status).withOpacity(0.10),
                    ),
                    child: Icon(
                      _getStatusIcon(widget.booking.status),
                      size: 46,
                      color: _getStatusColor(widget.booking.status),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _getStatusLabel(widget.booking.status),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _getStatusColor(widget.booking.status),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: maroon.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '${AppStrings.bookingId.tr}: #${widget.booking.id}',
                      style: const TextStyle(
                        color: maroon,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildLuxurySection(
              title: AppStrings.serviceInfo.tr,
              children: [
                _buildLuxuryTile(
                  Icons.info_outline_rounded,
                  AppStrings.serviceTitleLabel.tr,
                  serviceData?.title ??
                      widget.booking.brandName ??
                      AppStrings.unknown.tr,
                ),
                _buildLuxuryTile(
                  Icons.category_rounded,
                  AppStrings.mainServiceType.tr,
                  widget.booking.serviceType.toUpperCase(),
                ),
                _buildLuxuryTile(
                  Icons.payments_rounded,
                  AppStrings.totalPrice.tr,
                  '${widget.booking.totalPrice} ${AppStrings.currency.tr}',
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              context.push(
                                '/customer/services/${widget.booking.serviceType}/${widget.booking.serviceId}?showBookingPanel=false',
                              );
                            },
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        AppStrings.showFullServiceDetails.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: maroon,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLuxurySection(
              title: AppStrings.reservationPeriod.tr,
              children: [
                _buildLuxuryTile(
                  Icons.calendar_month_rounded,
                  AppStrings.fromDate.tr,
                  widget.booking.bookingDate,
                ),
                _buildLuxuryTile(
                  Icons.event_repeat_rounded,
                  AppStrings.toDate.tr,
                  widget.booking.endDate ?? widget.booking.bookingDate,
                ),
                _buildLuxuryTile(
                  Icons.access_time_filled_rounded,
                  AppStrings.time.tr,
                  '${widget.booking.bookingTime} - ${widget.booking.endTime}',
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isProvider &&
                (widget.booking.customerName != null ||
                    widget.booking.manualCustomerName != null)) ...[
              _buildLuxurySection(
                title: AppStrings.customerInfo.tr,
                children: [
                  _buildLuxuryTile(
                    Icons.person_outline_rounded,
                    AppStrings.fullName.tr,
                    widget.booking.customerName ??
                        widget.booking.manualCustomerName ??
                        AppStrings.manualCustomer.tr,
                  ),
                  if (widget.booking.customerPhone != null)
                    _buildLuxuryTile(
                      Icons.phone_rounded,
                      AppStrings.phoneNumber.tr,
                      widget.booking.customerPhone!,
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (serviceData != null) ...[
              if (serviceData.description != null &&
                  serviceData.description!.isNotEmpty) ...[
                _buildLuxurySection(
                  title: AppStrings.descriptionDetails.tr,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        serviceData.description!,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              if (serviceData.specifications.isNotEmpty) ...[
                _buildLuxurySection(
                  title: AppStrings.serviceSpecifications.tr,
                  children: serviceData.specifications
                      .map(
                        (spec) => _buildLuxuryTile(
                          Icons.label_important_outline_rounded,
                          spec.label,
                          spec.value,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
            ] else if (serviceAsync.isLoading) ...[
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: maroon,
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (isProvider && widget.booking.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading ? null : () => _updateBookingStatus('confirmed'),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(AppStrings.confirmBooking.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading ? null : () => _updateBookingStatus('cancelled'),
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(AppStrings.cancel.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (isProvider && widget.booking.status == 'confirmed') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _reschedule,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.edit_calendar_rounded),
                  label: Text(AppStrings.reschedule.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLuxurySection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 12),
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryMaroon,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white,
                AppTheme.luxuryBeige.withOpacity(0.38),
              ],
            ),
            border: Border.all(
              color: AppTheme.primaryMaroon.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryMaroon.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildLuxuryTile(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.primaryMaroon.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryMaroon.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryMaroon,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.primaryMaroon.withOpacity(0.08),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryMaroon,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppStrings.pending.tr;
      case 'confirmed':
        return AppStrings.confirmed.tr;
      case 'cancelled':
        return AppStrings.cancelled.tr;
      case 'completed':
        return AppStrings.completed.tr;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.verified;
      default:
        return Icons.help_outline;
    }
  }
}