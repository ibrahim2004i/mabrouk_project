import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/features/bookings/data/booking_repository.dart';
import 'package:mabrouk_app/features/services/domain/service_models.dart';

// --- 📦 Booking State Model ---
class BookingState {
  final DateTimeRange? selectedDateRange;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? conflictData;
  final bool isSuccess;

  BookingState({
    this.selectedDateRange,
    this.startTime,
    this.endTime,
    this.isLoading = false,
    this.errorMessage,
    this.conflictData,
    this.isSuccess = false,
  });

  BookingState copyWith({
    DateTimeRange? selectedDateRange,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? conflictData,
    bool? isSuccess,
  }) {
    return BookingState(
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      conflictData: conflictData ?? this.conflictData,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// --- 🚀 Booking Notifier ---
class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _repository;

  BookingNotifier(this._repository) : super(BookingState());

  void setDateRange(DateTimeRange range) {
    state = state.copyWith(selectedDateRange: range, errorMessage: null, isSuccess: false);
  }

  void setStartDate(DateTime date) {
    final DateTime start = DateUtils.dateOnly(date);
    final currentEnd = state.selectedDateRange?.end ?? start;
    final DateTime end = start.isAfter(currentEnd) ? start : currentEnd;
    state = state.copyWith(
      selectedDateRange: DateTimeRange(start: start, end: end),
      errorMessage: null,
      isSuccess: false,
    );
  }

  void setEndDate(DateTime date) {
    final DateTime end = DateUtils.dateOnly(date);
    final currentStart = state.selectedDateRange?.start ?? end;
    final DateTime start = end.isBefore(currentStart) ? end : currentStart;
    state = state.copyWith(
      selectedDateRange: DateTimeRange(start: start, end: end),
      errorMessage: null,
      isSuccess: false,
    );
  }

  void setStartTime(TimeOfDay time) {
    final hourOnly = TimeOfDay(hour: time.hour, minute: 0);
    state = state.copyWith(startTime: hourOnly, errorMessage: null, isSuccess: false);
  }

  void setEndTime(TimeOfDay time) {
    final hourOnly = TimeOfDay(hour: time.hour, minute: 0);
    state = state.copyWith(endTime: hourOnly, errorMessage: null, isSuccess: false);
  }

  double calculateTotalPrice(ServiceBase service) {
    if (service.offeringType == OfferingType.purchase) {
      return service.price; // Base price for purchase
    }

    if (state.selectedDateRange == null) return service.price;

    if (service.priceUnit == PriceUnit.day) {
      final days = state.selectedDateRange!.duration.inDays + 1;
      return service.price * days;
    }

    if (service.priceUnit == PriceUnit.hour) {
      if (state.startTime == null || state.endTime == null) return service.price;
      
      final start = DateTime(2024, 1, 1, state.startTime!.hour, state.startTime!.minute);
      var end = DateTime(2024, 1, 1, state.endTime!.hour, state.endTime!.minute);
      
      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }
      
      final hours = end.difference(start).inMinutes / 60.0;
      final days = (state.selectedDateRange?.duration.inDays ?? 0) + 1;
      
      return service.price * hours * days;
    }

    return service.price; // Per Event / Fixed
  }

  Future<void> submitBooking(ServiceBase service) async {
    final isPurchase = service.offeringType == OfferingType.purchase;

    if (!isPurchase) {
      if (state.selectedDateRange == null) {
        state = state.copyWith(errorMessage: AppStrings.pleaseSelectDateFirst.tr);
        return;
      }
      if (service.priceUnit == PriceUnit.hour && (state.startTime == null || state.endTime == null)) {
        state = state.copyWith(errorMessage: AppStrings.pleaseSelectTimeFirst.tr);
        return;
      }
    }

    state = state.copyWith(isLoading: true, errorMessage: null, conflictData: null, isSuccess: false);

    try {
      final total = calculateTotalPrice(service);
      final now = DateTime.now();
      
      final bookingData = {
        "provider_id": service.providerId,
        "service_type": service.type,
        "service_id": service.id,
        "total_price": total,
        "booking_date": DateFormat('yyyy-MM-dd').format(isPurchase ? now : state.selectedDateRange!.start),
        "end_date": DateFormat('yyyy-MM-dd').format(isPurchase ? now : state.selectedDateRange!.end),
        "booking_time": (!isPurchase && state.startTime != null) 
            ? "${state.startTime!.hour.toString().padLeft(2, '0')}:${state.startTime!.minute.toString().padLeft(2, '0')}:00"
            : "00:00:00",
        "end_time": (!isPurchase && state.endTime != null) 
            ? "${state.endTime!.hour.toString().padLeft(2, '0')}:${state.endTime!.minute.toString().padLeft(2, '0')}:00"
            : "00:00:00",
      };

      await _repository.createBooking(bookingData);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {

      final errorStr = e.toString().replaceFirst('Exception: ', '');
      try {
        final Map<String, dynamic> body = jsonDecode(errorStr);
        if (body['data'] != null && body['data']['conflict'] != null) {
          state = state.copyWith(
            isLoading: false, 
            errorMessage: 'CONFLICT', 
            conflictData: body['data']['conflict']
          );
        } else {
          state = state.copyWith(isLoading: false, errorMessage: body['message']);
        }
      } catch (_) {
        state = state.copyWith(isLoading: false, errorMessage: errorStr);
      }
    }
  }

  void reset() {
    state = BookingState();
  }
}

// --- ⚓ Provider ---
final bookingNotifierProvider = StateNotifierProvider.autoDispose<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref.watch(bookingRepoProvider));
});
