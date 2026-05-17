import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/features/services/domain/service_models.dart';
import 'package:mabrouk_app/features/bookings/presentation/booking_providers.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';

class BookingCreateScreen extends ConsumerStatefulWidget {
  final ServiceBase service;
  final String serviceType;

  const BookingCreateScreen({
    super.key,
    required this.service,
    required this.serviceType,
  });

  @override
  ConsumerState<BookingCreateScreen> createState() =>
      _BookingCreateScreenState();
}

class _BookingCreateScreenState
    extends ConsumerState<BookingCreateScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final _notesController = TextEditingController();

  bool get _isHourly =>
      widget.service.priceUnit == PriceUnit.hour;

  int? get _durationHours {
    if (_startTime == null || _endTime == null) return null;

    final start = _startTime!.hour;
    final end = _endTime!.hour;

    if (end <= start) return null;

    return end - start;
  }

  double get _totalPrice {
    if (_isHourly) {
      return widget.service.price * (_durationHours ?? 1);
    }

    return widget.service.price;
  }

  bool get _isValid {
    if (_selectedDate == null) return false;

    if (_isHourly) {
      return _durationHours != null &&
          _durationHours! > 0;
    }

    return true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 365)),
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    bool isStart,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? const TimeOfDay(hour: 12, minute: 0)
          : const TimeOfDay(hour: 12, minute: 0),
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
      final normalized = TimeOfDay(
        hour: picked.hour,
        minute: 0,
      );

      setState(() {
        if (isStart) {
          _startTime = normalized;
        } else {
          _endTime = normalized;
        }
      });
    }
  }

  void _submitBooking() async {
    if (!_isValid) return;

    final data = {
      'provider_id': widget.service.providerId,
      'service_type': widget.serviceType,
      'service_id': widget.service.id,
      'total_price': _totalPrice,
      'booking_date':
          DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'customer_notes': _notesController.text,
    };

    if (_isHourly) {
      data['booking_time'] =
          '${_startTime!.hour.toString().padLeft(2, '0')}:00:00';

      data['end_time'] =
          '${_endTime!.hour.toString().padLeft(2, '0')}:00:00';
    }

    await ref
        .read(myBookingsProvider.notifier)
        .create(data);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: maroon,
        title: Text(
          AppStrings.newBooking.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [

            /// SERVICE CARD
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white,
                    beige.withOpacity(0.45),
                  ],
                ),
                border: Border.all(
                  color: maroon.withOpacity(0.08),
                ),
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
                  Text(
                    widget.service.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: maroon,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: maroon.withOpacity(0.06),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.service.price} ${AppStrings.currency.tr} / ${_isHourly ? AppStrings.perHourShort.tr : AppStrings.perEventShort.tr}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: maroon,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// DATE
            _buildSectionTitle(
              AppStrings.selectDate.tr,
            ),

            const SizedBox(height: 12),

            _buildPicker(
              onTap: () => _selectDate(context),
              icon: Icons.calendar_today_rounded,
              text: _selectedDate == null
                  ? AppStrings.selectDate.tr
                  : DateFormat('dd/MM/yyyy')
                      .format(_selectedDate!),
            ),

            if (_isHourly) ...[
              const SizedBox(height: 26),

              /// TIME
              _buildSectionTitle(
                AppStrings.selectTime.tr,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildPicker(
                      onTap: () =>
                          _selectTime(context, true),
                      icon: Icons.access_time_rounded,
                      text: _startTime == null
                          ? AppStrings.from.tr
                          : _startTime!.format(context),
                      small: true,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildPicker(
                      onTap: () =>
                          _selectTime(context, false),
                      icon:
                          Icons.access_time_filled_rounded,
                      text: _endTime == null
                          ? AppStrings.to.tr
                          : _endTime!.format(context),
                      small: true,
                    ),
                  ),
                ],
              ),

              if (_durationHours != null) ...[
                const SizedBox(height: 16),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(18),
                    color: maroon.withOpacity(0.06),
                    border: Border.all(
                      color:
                          maroon.withOpacity(0.08),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${AppStrings.duration.tr}: $_durationHours ${AppStrings.hours.tr}',
                      style: const TextStyle(
                        color: maroon,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 28),

            /// NOTES
            _buildSectionTitle(
              AppStrings.notes.tr,
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(24),
                color: Colors.white,
                border: Border.all(
                  color: maroon.withOpacity(0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: maroon.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText:
                      AppStrings.addSpecialRequestsHint
                          .tr,
                  hintStyle: TextStyle(
                    color: maroon.withOpacity(0.35),
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.all(18),
                ),
              ),
            ),

            const SizedBox(height: 34),

            /// TOTAL PRICE
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    maroon,
                    Color(0xFF5C0000),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: maroon.withOpacity(0.24),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    '${_totalPrice.toStringAsFixed(2)} ${AppStrings.currency.tr}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    AppStrings.totalPrice.tr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// BUTTON
            SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed:
                    _isValid ? _submitBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor:
                      maroon.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  AppStrings.confirmBooking.tr,
                  style: const TextStyle(
                    fontSize: 17,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: AppTheme.primaryMaroon,
      ),
    );
  }

  Widget _buildPicker({
    required VoidCallback onTap,
    required IconData icon,
    required String text,
    bool small = false,
  }) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: small ? 14 : 18,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white,
                beige.withOpacity(0.35),
              ],
            ),
            border: Border.all(
              color: maroon.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: maroon.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: maroon,
                size: small ? 20 : 22,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: small ? 13 : 15,
                    fontWeight: FontWeight.w700,
                    color: maroon,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}