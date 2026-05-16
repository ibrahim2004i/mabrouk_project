import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/auth/presentation/auth_state.dart';
import 'package:mabrouk_app/features/admin/data/admin_repository.dart';
import 'package:mabrouk_app/features/admin/presentation/admin_manage_providers_screen.dart';
import 'package:mabrouk_app/features/admin/presentation/admin_complaints_screen.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/notification_badge.dart';

final adminPendingProvider = AsyncNotifierProvider.autoDispose<AdminPendingNotifier, List<dynamic>>(() {
  return AdminPendingNotifier();
});

final adminPendingProvidersProvider = AsyncNotifierProvider.autoDispose<AdminPendingProvidersNotifier, List<Map<String, dynamic>>>(() {
  return AdminPendingProvidersNotifier();
});

class AdminPendingNotifier extends AutoDisposeAsyncNotifier<List<dynamic>> {
  @override
  FutureOr<List<dynamic>> build() async {
    return ref.watch(adminRepoProvider).getPendingServices();
  }

  Future<void> approve(String type, int id) async {
    state = const AsyncLoading();
    try {
      await ref.read(adminRepoProvider).approveService(type, id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> reject(String type, int id) async {
    state = const AsyncLoading();
    try {
      await ref.read(adminRepoProvider).rejectService(type, id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class AdminPendingProvidersNotifier extends AutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    return ref.watch(adminRepoProvider).getPendingProviders();
  }

  Future<void> updateStatus(int id, String status) async {
    state = const AsyncLoading();
    try {
      await ref.read(adminRepoProvider).updateProviderStatus(id, status);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class AdminModerationScreen extends ConsumerWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const maroon = AppTheme.primaryMaroon;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.luxuryBeige,
        appBar: AppBar(
          title: Text(AppStrings.adminPanel.tr),
          backgroundColor: maroon,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: AppTheme.accentGold,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: const Icon(Icons.person_add_rounded), text: AppStrings.newUsers.tr),
              Tab(icon: const Icon(Icons.approval), text: AppStrings.activationRequests.tr),
              Tab(icon: const Icon(Icons.people_alt), text: AppStrings.providers.tr),
              Tab(icon: const Icon(Icons.report_problem), text: AppStrings.complaints.tr),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
              tooltip: AppStrings.logout.tr,
            ),
            const NotificationBadge(),
            const SizedBox(width: 8),
          ],
        ),
        body: const TabBarView(
          children: [
            _PendingProvidersTab(),
            _PendingServicesTab(),
            AdminManageProvidersScreen(),
            AdminComplaintsScreen(),
          ],
        ),
      ),
    );
  }
}

class _PendingServicesTab extends ConsumerWidget {
  const _PendingServicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(adminPendingProvider);
    const maroon = AppTheme.primaryMaroon;

    return pendingAsync.when(
      data: (services) => services.isEmpty
          ? Center(child: Text(AppStrings.noPendingServices.tr))
          : RefreshIndicator(
              onRefresh: () => ref.refresh(adminPendingProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: AppTheme.get3DShadows(),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      onTap: () async {
                        await context.push(
                          '/customer/services/${service['service_type']}/${service['id']}',
                          extra: {'showBookingPanel': false}, 
                        );
                        ref.refresh(adminPendingProvider.future);
                      },
                      leading: CircleAvatar(
                        backgroundColor: maroon.withOpacity(0.1),
                        child: const Icon(Icons.inventory, color: maroon),
                      ),
                      title: Text(
                        service['name'] ?? 
                        service['title'] ?? 
                        service['package_name'] ?? 
                        (service['brand'] != null ? "${service['brand']} ${service['model'] ?? ''}" : null) ?? 
                        AppStrings.service.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        '${AppStrings.category.tr}: ${service['service_type']?.toString().tr.toUpperCase()} | ${AppStrings.provider.tr}: ${service['brand_name']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                            onPressed: () => ref.read(adminPendingProvider.notifier).approve(service['service_type'], service['id']),
                            tooltip: AppStrings.approveAndActivate.tr,
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                            onPressed: () => ref.read(adminPendingProvider.notifier).reject(service['service_type'], service['id']),
                            tooltip: AppStrings.reject.tr,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator(color: maroon)),
      error: (err, stack) => Center(child: Text('${AppStrings.error.tr}: $err')),
    );
  }
}
class _PendingProvidersTab extends ConsumerWidget {
  const _PendingProvidersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(adminPendingProvidersProvider);
    const maroon = AppTheme.primaryMaroon;

    return pendingAsync.when(
      data: (providers) => providers.isEmpty
          ? Center(child: Text(AppStrings.noNewJoinRequests.tr))
          : RefreshIndicator(
              onRefresh: () => ref.refresh(adminPendingProvidersProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final p = providers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: AppTheme.get3DShadows(),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: maroon.withOpacity(0.1),
                        child: const Icon(Icons.person_add, color: maroon),
                      ),
                      title: Text(
                        p['brand_name'] ?? AppStrings.unnamed.tr, 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text('${AppStrings.phoneNumber.tr}: ${p['phone_number']}\n${AppStrings.date.tr}: ${p['created_at']}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                            onPressed: () => _confirmAction(context, ref, p['id'], 'approved', p['brand_name']),
                            tooltip: AppStrings.approveAndActivate.tr,
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
                            onPressed: () => _confirmAction(context, ref, p['id'], 'rejected', p['brand_name']),
                            tooltip: AppStrings.reject.tr,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator(color: maroon)),
      error: (err, stack) => Center(child: Text('${AppStrings.error.tr}: $err')),
    );
  }

  Future<void> _confirmAction(BuildContext context, WidgetRef ref, int id, String status, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(status == 'approved' ? AppStrings.activateAccount.tr : AppStrings.rejectRequest.tr),
        content: Text('${status == 'approved' ? AppStrings.confirmActivationOf.tr : AppStrings.confirmRejectionOf.tr} "$name"${Get.locale?.languageCode == 'ar' ? '؟' : '?'}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel.tr)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text(AppStrings.confirm.tr, style: TextStyle(color: status == 'approved' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(adminPendingProvidersProvider.notifier).updateStatus(id, status);
    }
  }
}
