import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/features/bookings/data/booking_repository.dart';
import 'package:mabrouk_app/features/bookings/domain/booking_model.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';

final serviceBookingsProvider = FutureProvider.autoDispose.family<List<Booking>, ({String type, int id})>((ref, arg) async {
  return ref.watch(bookingRepoProvider).getServiceBookings(arg.type, arg.id);
});

class ServiceBookingsScreen extends ConsumerStatefulWidget {
  final String type;
  final int id;
  final String serviceTitle;

  const ServiceBookingsScreen({
    super.key, 
    required this.type, 
    required this.id,
    required this.serviceTitle,
  });

  @override
  ConsumerState<ServiceBookingsScreen> createState() => _ServiceBookingsScreenState();
}

class _ServiceBookingsScreenState extends ConsumerState<ServiceBookingsScreen> {
  bool _isUpdating = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return AppStrings.pending.tr;
      case 'confirmed': return AppStrings.confirmed.tr;
      case 'cancelled': return AppStrings.cancelled.tr;
      case 'completed': return AppStrings.completed.tr;
      default: return status;
    }
  }

  Future<void> _updateStatus(int bookingId, String status) async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(bookingRepoProvider).updateBookingStatus(bookingId, status);
      ref.invalidate(serviceBookingsProvider((type: widget.type, id: widget.id)));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.statusUpdatedTo.tr} ${_getStatusLabel(status)}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.error.tr}: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(serviceBookingsProvider((type: widget.type, id: widget.id)));

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.bookingDetails.tr}: ${widget.serviceTitle}'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(serviceBookingsProvider((type: widget.type, id: widget.id)).future),
        child: bookingsAsync.when(
          data: (bookings) {
            if (bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.noBookingsFound.tr),
                  ],
                ),
              );
            }
            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final isManual = booking.customerId == null;
                    final statusColor = _getStatusColor(booking.status);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isManual ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                              child: Icon(
                                isManual ? Icons.edit_note : Icons.person,
                                color: isManual ? Colors.orange : Colors.blue,
                              ),
                            ),
                            title: Text(
                              isManual 
                                ? (booking.manualCustomerName ?? AppStrings.manualBooking.tr) 
                                : (booking.customerName ?? AppStrings.customer.tr),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${AppStrings.from.tr}: ${booking.bookingDate} | ${booking.bookingTime ?? "00:00"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_filled, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${AppStrings.to.tr}: ${booking.endDate ?? booking.bookingDate} | ${booking.endTime ?? "23:59"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${booking.totalPrice} ${AppStrings.currency.tr}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(_getStatusLabel(booking.status), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          if (booking.status.toLowerCase() == 'pending') ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: _isUpdating ? null : () => _updateStatus(booking.id, 'cancelled'),
                                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                    label: Text(AppStrings.reject.tr, style: const TextStyle(color: Colors.red)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _isUpdating ? null : () => _updateStatus(booking.id, 'confirmed'),
                                    icon: const Icon(Icons.check, size: 18, color: Colors.white),
                                    label: Text(AppStrings.confirmBooking.tr, style: const TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                if (_isUpdating)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('${AppStrings.error.tr}: $err')),
        ),
      ),
    );
  }
}
