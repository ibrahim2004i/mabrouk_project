import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/features/bookings/presentation/booking_providers.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.myBookings.tr)),
      body: bookingsAsync.when(
        data: (bookings) => bookings.isEmpty
            ? Center(child: Text(AppStrings.noBookingsFound.tr))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(myBookingsProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    booking.brandName ?? AppStrings.unnamed.tr,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF800000)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(booking.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _getStatusColor(booking.status)),
                                  ),
                                  child: Text(
                                    _getStatusArabic(booking.status),
                                    style: TextStyle(color: _getStatusColor(booking.status), fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            _buildInfoRow(Icons.calendar_month, '${AppStrings.from.tr}:', '${booking.bookingDate} | ${booking.bookingTime}'),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.event_repeat, '${AppStrings.to.tr}:', '${booking.endDate ?? booking.bookingDate} | ${booking.endTime ?? booking.bookingTime}'),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${booking.totalPrice} ${AppStrings.currency.tr}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFB8860B))),
                                TextButton(
                                  onPressed: () async {
                                    await context.push('/bookings/${booking.id}', extra: booking);
                                    ref.refresh(myBookingsProvider.future);
                                  },
                                  child: Text(AppStrings.bookingDetails.tr, style: const TextStyle(fontSize: 12)),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${AppStrings.error.tr}: $err')),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _getStatusArabic(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return AppStrings.pending.tr;
      case 'confirmed': return AppStrings.confirmed.tr;
      case 'cancelled': return AppStrings.cancelled.tr;
      case 'completed': return AppStrings.completed.tr;
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
