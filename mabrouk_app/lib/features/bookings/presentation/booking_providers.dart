import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/features/bookings/domain/booking_model.dart';
import 'package:mabrouk_app/features/bookings/data/booking_repository.dart';

final myBookingsProvider = AsyncNotifierProvider.autoDispose<MyBookingsNotifier, List<Booking>>(() {
  return MyBookingsNotifier();
});

class MyBookingsNotifier extends AutoDisposeAsyncNotifier<List<Booking>> {
  @override
  FutureOr<List<Booking>> build() async {
    return ref.watch(bookingRepoProvider).getMyBookings();
  }

  Future<void> create(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await ref.read(bookingRepoProvider).createBooking(data);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
