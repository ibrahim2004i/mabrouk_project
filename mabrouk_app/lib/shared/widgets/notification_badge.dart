import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/notifications/presentation/notification_state.dart';

class NotificationBadge extends ConsumerWidget {
  final Color color;

  const NotificationBadge({
    super.key,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // rebuild when notifications change
    ref.watch(notificationStateProvider);

    final count =
        ref.read(notificationStateProvider.notifier).unreadCount;

    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Stack(
      clipBehavior: Clip.none,
      children: [

        // ================= BUTTON =================
        Container(
          width: 38, 
          height: 38, 
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.10),
            border: Border.all(
              color: Colors.white.withOpacity(0.14),
              width: 1,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            splashRadius: 18,
            onPressed: () => context.pushNamed('notifications'),
            icon: Icon(
              Icons.notifications_none_rounded,
              color: color,
              size: 23, 
            ),
          ),
        ),

        // ================= BADGE =================
        if (count > 0)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              decoration: BoxDecoration(
                color: maroon,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: beige,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}