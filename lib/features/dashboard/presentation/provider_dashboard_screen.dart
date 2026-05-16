import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/dashboard/presentation/dashboard_providers.dart';
import 'package:mabrouk_app/shared/widgets/notification_badge.dart';
import 'package:mabrouk_app/shared/widgets/app_drawer.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    const maroon = AppTheme.primaryMaroon;
    const gold = AppTheme.accentGold;
    const beige = AppTheme.luxuryBeige;

    return Scaffold(
      backgroundColor: beige,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(AppStrings.dashboard.tr),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [
          NotificationBadge(),
          SizedBox(width: 8),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          final summary = stats['summary'] ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Welcome
                Text(
                  AppStrings.welcome.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: maroon),
                ),
                const SizedBox(height: 25),
                
                // Stat Grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: AppStrings.totalBookings.tr, 
                        value: summary['total']?.toString() ?? '0', 
                        icon: Icons.calendar_month,
                        color: maroon,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: AppStrings.totalRevenue.tr, 
                        value: '${summary['total_revenue'] ?? 0} ${AppStrings.currency.tr}', 
                        icon: Icons.monetization_on,
                        color: gold,
                        useGold: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatStatGridCard(
                        title: AppStrings.confirmedBookings.tr, 
                        value: summary['confirmed']?.toString() ?? '0', 
                        color: Colors.blueAccent,
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatStatGridCard(
                        title: AppStrings.completedBookings.tr, 
                        value: summary['completed']?.toString() ?? '0', 
                        color: Colors.teal,
                        icon: Icons.done_all,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatStatGridCard(
                        title: 'حجوزات قيد المراجعة', 
                        value: summary['pending']?.toString() ?? '0', 
                        color: Colors.orange,
                        icon: Icons.hourglass_empty,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatStatGridCard(
                        title: 'حجوزات ملغاة', 
                        value: summary['cancelled']?.toString() ?? '0', 
                        color: Colors.redAccent,
                        icon: Icons.cancel_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                

              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryMaroon)),
        error: (err, stack) => Center(child: Text('${AppStrings.error.tr}: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/provider/add-service'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(AppStrings.addService.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: maroon,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool useGold;

  const _StatCard({
    required this.title, 
    required this.value, 
    required this.icon,
    required this.color,
    this.useGold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.get3DShadows(isSelected: useGold),
        border: useGold ? Border.all(color: AppTheme.accentGold.withOpacity(0.5), width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 15),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _StatStatGridCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatStatGridCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.get3DShadows(),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(value, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
