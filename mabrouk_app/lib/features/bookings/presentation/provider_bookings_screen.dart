import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/bookings/domain/booking_model.dart';
import 'package:mabrouk_app/features/bookings/data/booking_repository.dart';
import 'package:mabrouk_app/shared/widgets/app_drawer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mabrouk_app/features/services/presentation/provider_services_provider.dart';

final providerBookingsProvider =
    AsyncNotifierProvider.autoDispose<ProviderBookingsNotifier, List<Booking>>(
  () => ProviderBookingsNotifier(),
);

class ProviderBookingsNotifier extends AutoDisposeAsyncNotifier<List<Booking>> {
  @override
  FutureOr<List<Booking>> build() async {
    return ref.watch(bookingRepoProvider).getProviderBookings();
  }

  Future<void> updateStatus(int id, String status) async {
    state = const AsyncLoading();
    try {
      await ref.read(bookingRepoProvider).updateBookingStatus(id, status);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class ProviderBookingsScreen extends ConsumerStatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  ConsumerState<ProviderBookingsScreen> createState() =>
      _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState
    extends ConsumerState<ProviderBookingsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarView = true;

  static const Color _maroon = Color(0xFF600000);
  static const Color _beige = AppTheme.luxuryBeige;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Booking> _getBookingsForDay(List<Booking> allBookings, DateTime day) {
    return allBookings.where((b) {
      try {
        final bookingDate = DateTime.parse(b.bookingDate);
        return isSameDay(bookingDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(providerBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.manageBookings.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 19,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsetsDirectional.only(end: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: IconButton(
              icon: Icon(
                _isCalendarView
                    ? Icons.list_alt_rounded
                    : Icons.calendar_month_rounded,
              ),
              onPressed: () => setState(() => _isCalendarView = !_isCalendarView),
              tooltip:
                  _isCalendarView ? AppStrings.listView.tr : AppStrings.calendarView.tr,
            ),
          ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noBookingsFound.tr,
                style: const TextStyle(
                  color: _maroon,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }

          if (_isCalendarView) {
            final selectedDayBookings =
                _getBookingsForDay(bookings, _selectedDay!);

            return Column(
              children: [
                _buildCalendar(bookings),
                Divider(height: 1, color: _maroon.withOpacity(0.10)),
                Expanded(
                  child: selectedDayBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                size: 52,
                                color: _maroon.withOpacity(0.35),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppStrings.noBookingsToday.tr,
                                style: TextStyle(
                                  color: _maroon.withOpacity(0.55),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: selectedDayBookings.length,
                          itemBuilder: (context, index) => _BookingItem(
                            booking: selectedDayBookings[index],
                            onUpdateStatus: (status) => _updateStatus(
                              context,
                              selectedDayBookings[index].id,
                              status,
                            ),
                            onRefresh: () =>
                                ref.refresh(providerBookingsProvider.future),
                          ),
                        ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            color: _maroon,
            onRefresh: () => ref.refresh(providerBookingsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) => _BookingItem(
                booking: bookings[index],
                onUpdateStatus: (status) =>
                    _updateStatus(context, bookings[index].id, status),
                onRefresh: () => ref.refresh(providerBookingsProvider.future),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: _maroon),
        ),
        error: (err, stack) => Center(
          child: Text(
            '${AppStrings.error.tr}: $err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _maroon, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddManualBookingDialog(context),
        backgroundColor: _maroon,
        foregroundColor: _beige,
        elevation: 6,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text(
          'حجز يدوي',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildCalendar(List<Booking> bookings) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _maroon.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: _maroon.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        eventLoader: (day) => _getBookingsForDay(bookings, day),
        calendarStyle: CalendarStyle(
          selectedDecoration:
              const BoxDecoration(color: _maroon, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(
            color: _maroon.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppTheme.accentGold,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(color: _maroon),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          titleTextStyle: TextStyle(
            color: _maroon,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, int id, String status) async {
    try {
      await ref.read(providerBookingsProvider.notifier).updateStatus(id, status);
      if (!context.mounted) return;
      _showSnack(
        context,
        '${AppStrings.statusUpdatedTo.tr}: ${_getStatusArabic(status)}',
        success: true,
      );
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, '${AppStrings.updateFailed.tr}: $e');
    }
  }

  void _showSnack(BuildContext context, String message, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? Colors.green : _maroon,
          elevation: 0,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Text(
            message,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _beige,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
  }

  String _getStatusArabic(String status) {
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

  void _showAddManualBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddManualBookingDialog(),
    );
  }
}

class _AddManualBookingDialog extends ConsumerStatefulWidget {
  const _AddManualBookingDialog();

  @override
  ConsumerState<_AddManualBookingDialog> createState() =>
      _AddManualBookingDialogState();
}

class _AddManualBookingDialogState
    extends ConsumerState<_AddManualBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  dynamic _selectedService;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isSubmitting = false;

  static const Color _maroon = Color(0xFF600000);
  static const Color _beige = AppTheme.luxuryBeige;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _pickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: _maroon,
          onPrimary: Colors.white,
          surface: _beige,
          onSurface: _maroon,
        ),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(myServicesProvider(null));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        decoration: BoxDecoration(
          color: _beige,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _maroon.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: _maroon.withOpacity(0.16),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: _maroon.withOpacity(0.09),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_task_rounded,
                    color: _maroon,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'إضافة حجز يدوي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _maroon,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر الخدمة والموعد لإضافة حجز أو حظر وقت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _maroon.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                servicesAsync.when(
                  data: (services) => DropdownButtonFormField<dynamic>(
                    initialValue: _selectedService,
                    decoration: _inputDecoration('الخدمة'),
                    hint: const Text('اختر الخدمة'),
                    items: services.map((s) {
                      final name = s['name'] ??
                          s['title'] ??
                          s['package_name'] ??
                          (s['brand'] != null
                              ? "${s['brand']} ${s['model']}"
                              : null) ??
                          s['service_type'] ??
                          'خدمة';
                      return DropdownMenuItem<dynamic>(
                        value: s,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedService = v),
                    validator: (v) => v == null ? 'يرجى اختيار الخدمة' : null,
                  ),
                  loading: () =>
                      const CircularProgressIndicator(color: _maroon),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    'اسم الزبون (اختياري)',
                    hint: 'أو اكتب "محجوز" لحظر الوقت',
                  ),
                ),
                const SizedBox(height: 14),
                _dateTile(
                  title: 'تاريخ البدء',
                  value: DateFormat('yyyy-MM-dd').format(_startDate),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.utc(2030, 12, 31),
                      builder: _pickerTheme,
                    );
                    if (date != null) setState(() => _startDate = date);
                  },
                ),
                const SizedBox(height: 10),
                _dateTile(
                  title: 'تاريخ الانتهاء',
                  value: DateFormat('yyyy-MM-dd').format(_endDate),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.utc(2030, 12, 31),
                      builder: _pickerTheme,
                    );
                    if (date != null) setState(() => _endDate = date);
                  },
                ),
                const SizedBox(height: 10),
                _dateTile(
                  title: 'وقت البدء',
                  value: _startTime.format(context),
                  icon: Icons.access_time_rounded,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 12, minute: 0),
                      builder: _pickerTheme,
                    );
                    if (time != null) {
                      setState(() {
                        _startTime = TimeOfDay(hour: time.hour, minute: 0);
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                _dateTile(
                  title: 'وقت الانتهاء',
                  value: _endTime.format(context),
                  icon: Icons.access_time_filled_rounded,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 12, minute: 0),
                      builder: _pickerTheme,
                    );
                    if (time != null) {
                      setState(() {
                        _endTime = TimeOfDay(hour: time.hour, minute: 0);
                      });
                    }
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _maroon,
                          side: BorderSide(color: _maroon.withOpacity(0.35)),
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _maroon,
                          foregroundColor: _beige,
                          minimumSize: const Size(0, 52),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: _beige,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'حفظ',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: _maroon.withOpacity(0.65),
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.75),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _maroon.withOpacity(0.10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _maroon.withOpacity(0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _maroon, width: 1.2),
      ),
    );
  }

  Widget _dateTile({
    required String title,
    required String value,
    required VoidCallback onTap,
    IconData icon = Icons.calendar_today_rounded,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _maroon.withOpacity(0.10)),
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
                      color: _maroon.withOpacity(0.50),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _maroon,
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
                color: _maroon.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _maroon, size: 21),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedService == null) return;

    setState(() => _isSubmitting = true);

    try {
      final start = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final end = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      if (end.isBefore(start)) {
        Get.snackbar('خطأ', 'يجب أن يكون وقت النهاية بعد وقت البدء');
        setState(() => _isSubmitting = false);
        return;
      }

      final data = {
        "provider_id": _selectedService['provider_id'],
        "service_type": _selectedService['service_type'],
        "service_id": _selectedService['id'],
        "total_price": 0,
        "booking_date": DateFormat('yyyy-MM-dd').format(_startDate),
        "end_date": DateFormat('yyyy-MM-dd').format(_endDate),
        "booking_time":
            "${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00",
        "end_time":
            "${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}:00",
        "manual_customer_name":
            _nameController.text.isEmpty ? 'محجوز' : _nameController.text,
      };

      await ref.read(bookingRepoProvider).createBooking(data);

      if (mounted) {
        Navigator.pop(context);
        Get.snackbar('نجاح', 'تم إضافة الحجز بنجاح');
        ref.invalidate(providerBookingsProvider);
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _BookingItem extends ConsumerWidget {
  final Booking booking;
  final Function(String) onUpdateStatus;
  final VoidCallback onRefresh;

  const _BookingItem({
    required this.booking,
    required this.onUpdateStatus,
    required this.onRefresh,
  });

  static const Color _maroon = Color(0xFF600000);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white,
            AppTheme.luxuryBeige.withOpacity(0.46),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _maroon.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: _maroon.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          await context.push('/bookings/${booking.id}', extra: booking);
          onRefresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _StatusBadge(status: booking.status),
                        const Spacer(),
                        Expanded(
                          flex: 3,
                          child: Text(
                            booking.brandName ?? booking.serviceType.toUpperCase(),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: _maroon,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${AppStrings.customerLabel.tr}: ${booking.customerName ?? booking.manualCustomerName ?? AppStrings.unnamed.tr}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _maroon.withOpacity(0.62),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${AppStrings.selectTime.tr}: ${booking.bookingTime ?? "00:00"}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
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
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    String label = AppStrings.unknown.tr;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = AppStrings.pending.tr;
        break;
      case 'confirmed':
        color = Colors.green;
        label = AppStrings.confirmed.tr;
        break;
      case 'cancelled':
        color = Colors.red;
        label = AppStrings.cancelled.tr;
        break;
      case 'completed':
        color = Colors.blue;
        label = AppStrings.completed.tr;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}