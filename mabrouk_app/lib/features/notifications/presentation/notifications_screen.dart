import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/notifications/presentation/notification_state.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationStateProvider);
    const maroon = AppTheme.primaryMaroon;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppStrings.notificationsTitle.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: maroon,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: AppStrings.markAllRead.tr,
            onPressed: () => ref.read(notificationStateProvider.notifier).markAsRead(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationStateProvider.notifier).refresh(),
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator(color: maroon)),
          error: (e, stack) => Center(child: Text('${AppStrings.loadNotificationsError.tr}: $e')),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(AppStrings.noNotifications.tr, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(ref, notification);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(WidgetRef ref, dynamic n) {
    final isUnread = !n.isRead;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: () => ref.read(notificationStateProvider.notifier).markAsRead(id: n.id),
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(n.type).withOpacity(0.1),
          child: Icon(_getTypeIcon(n.type), color: _getTypeColor(n.type), size: 20),
        ),
        title: Text(
          n.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            color: AppTheme.primaryMaroon,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(n.message, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy/MM/dd | hh:mm a').format(n.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: isUnread 
            ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle))
            : null,
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'new_booking': return Icons.add_shopping_cart;
      case 'status_change': return Icons.event;
      default: return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'new_booking': return Colors.green;
      case 'status_change': return Colors.orange;
      default: return AppTheme.accentGold;
    }
  }
}
