import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/services/presentation/provider_services_provider.dart';
import 'package:mabrouk_app/shared/widgets/app_drawer.dart';

import '../domain/service_models.dart';

class ProviderServicesScreen extends ConsumerWidget {
  final int? targetProviderId;
  final String? targetProviderName;

  const ProviderServicesScreen({
    super.key,
    this.targetProviderId,
    this.targetProviderName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(myServicesProvider(targetProviderId));
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Scaffold(
      backgroundColor: beige,
      drawer: targetProviderId == null ? const AppDrawer() : null,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: maroon,
        foregroundColor: beige,
        title: Text(
          targetProviderName ?? AppStrings.myServices.tr,
          style: const TextStyle(
            color: beige,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        leading: targetProviderId != null
            ? IconButton(
                icon: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: beige.withOpacity(0.18)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: beige,
                  ),
                ),
                onPressed: () => context.pop(),
              )
            : null,
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myServicesProvider(targetProviderId).future),
        color: maroon,
        child: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return _EmptyServicesState();
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              itemCount: services.length,
              separatorBuilder: (context, index) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final service = services[index];
                final type = service['service_type'] ?? 'hall';
                final status = service['status'] ?? 'pending';
                final title = service['name'] ??
                    service['title'] ??
                    service['package_name'] ??
                    service['brand'] ??
                    AppStrings.unnamed.tr;

                final price = service['base_price'] ??
                    service['price'] ??
                    service['price_per_night'] ??
                    service['price_per_day'] ??
                    0;

                return InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () async {
                    await context.push('/customer/services/$type/${service['id']}');
                    ref.refresh(myServicesProvider(targetProviderId).future);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.58),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: maroon.withOpacity(0.10)),
                      boxShadow: [
                        BoxShadow(
                          color: maroon.withOpacity(0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: maroon.withOpacity(0.09),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: maroon.withOpacity(0.10)),
                              ),
                              child: Icon(
                                _getIconForType(type),
                                color: maroon,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: maroon,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$price ${AppStrings.currency.tr}',
                                    style: TextStyle(
                                      color: maroon.withOpacity(0.75),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StatusBadge(status: status),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Divider(
                          height: 1,
                          color: maroon.withOpacity(0.12),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ServiceStat(
                              label: AppStrings.pending.tr,
                              count: service['pending_count'] ?? 0,
                              icon: Icons.hourglass_empty_rounded,
                            ),
                            _ServiceStat(
                              label: AppStrings.confirmed.tr,
                              count: service['confirmed_count'] ?? 0,
                              icon: Icons.check_circle_outline_rounded,
                            ),
                            _ServiceStat(
                              label: AppStrings.completed.tr,
                              count: service['completed_count'] ?? 0,
                              icon: Icons.done_all_rounded,
                            ),
                            _ServiceStat(
                              label: AppStrings.cancelled.tr,
                              count: service['cancelled_count'] ?? 0,
                              icon: Icons.cancel_outlined,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          
                          children: [
                           if (targetProviderId == null)

  GestureDetector(
    onTap: () async {
      final serviceModel = ServiceBase.fromJson(service);

      await context.push(
        '/provider/add-service',
        extra: serviceModel,
      );

      ref.refresh(
        myServicesProvider(targetProviderId).future,
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.edit_note_rounded,
            color: AppTheme.luxuryBeige,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            AppStrings.edit.tr,
            style: const TextStyle(
              color: AppTheme.luxuryBeige,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  ),

const SizedBox(width: 10),

                            Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  ),
  decoration: BoxDecoration(
    color: maroon.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: maroon.withOpacity(0.12),
    ),
  ),
  child: Text(
    AppStrings.view.tr,
    style: const TextStyle(
      color: maroon,
      fontWeight: FontWeight.w900,
      fontSize: 13,
    ),
  ),
),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: maroon),
          ),
          error: (err, stack) => Center(
            child: Text(
              '${AppStrings.error.tr}: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: maroon),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'hall':
        return Icons.home_work;
      case 'dress':
        return Icons.checkroom;
      case 'suit':
        return Icons.accessibility_new;
      case 'car':
        return Icons.directions_car;
      case 'cake':
        return Icons.cake;
      case 'photographer':
        return Icons.camera_alt;
      case 'chalet':
        return Icons.pool;
      default:
        return Icons.category;
    }
  }
}

class _ServiceStat extends StatelessWidget {
  final String label;
  final dynamic count;
  final IconData icon;

  const _ServiceStat({
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: maroon.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: maroon.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 17, color: maroon),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: maroon,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: maroon.withOpacity(0.55),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    String text;

    switch (status) {
      case 'approved':
        text = AppStrings.approved.tr;
        break;
      case 'rejected':
        text = AppStrings.rejected.tr;
        break;
      case 'pending':
      default:
        text = AppStrings.pendingReview.tr;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: beige,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyServicesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.58),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: maroon.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 70,
              color: maroon.withOpacity(0.45),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.noServicesAvailableForProvider.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: maroon.withOpacity(0.70),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}