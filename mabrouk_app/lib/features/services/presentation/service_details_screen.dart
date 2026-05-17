import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/features/services/presentation/service_providers.dart';
import 'package:mabrouk_app/features/services/presentation/widgets/booking_floating_panel.dart';
import 'package:mabrouk_app/features/services/presentation/widgets/service_attribute_grid.dart';
import 'package:mabrouk_app/features/services/presentation/widgets/service_contact_card.dart';
import 'package:mabrouk_app/features/services/presentation/widgets/service_header_info.dart';
import 'package:mabrouk_app/features/services/presentation/widgets/service_range_selector.dart';
import 'package:mabrouk_app/features/services/presentation/widgets/service_reviews_section.dart';

import '../../../core/theme/app_theme.dart';
import '../../admin/data/admin_repository.dart';
import '../../admin/presentation/admin_moderation_screen.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/service_models.dart';
import 'favorites_notifier.dart';

class ServiceDetailsScreen extends ConsumerWidget {
  final String serviceType;
  final String serviceId;
  final bool showBookingPanel;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceType,
    required this.serviceId,
    this.showBookingPanel = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync =
        ref.watch(serviceDetailsProvider((type: serviceType, id: serviceId)));

    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Scaffold(
      backgroundColor: beige,
      body: serviceAsync.when(
        data: (service) {
          final images = service.mediaUrls.isNotEmpty
              ? service.mediaUrls
              : (service.logoUrl != null ? [service.logoUrl!] : <String>[]);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 430,
                pinned: true,
                elevation: 0,
                backgroundColor: maroon,
                leadingWidth: 78,
                leading: Padding(
                  padding: const EdgeInsets.only(
                    left: 18,
                    top: 14,
                  ),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 18,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: const [],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _AutoServiceGallery(images: images),
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                maroon.withOpacity(0.55),
                                Colors.transparent,
                                maroon.withOpacity(0.65),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: beige,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(38),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ServiceHeaderInfo(service: service),
                        const SizedBox(height: 24),

                        _ServiceReelsCard(
                          serviceType: serviceType,
                          serviceId: serviceId,
                          serviceName: service.title,
                        ),
                        const SizedBox(height: 28),

                        if (service.description != null &&
                            service.description!.isNotEmpty) ...[
                          _buildSectionTitle(AppStrings.descriptionDetails.tr),
                          _sectionBox(
                            child: Text(
                              service.description!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.7,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: Get.locale?.languageCode == 'ar'
                                  ? TextAlign.right
                                  : TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        _buildSectionTitle(AppStrings.locationContact.tr),
                        ServiceContactCard(service: service),
                        const SizedBox(height: 28),

                        if (service.offeringType == OfferingType.booking) ...[
                          _buildSectionTitle(
                            service.priceUnit == PriceUnit.hour
                                ? AppStrings.selectBookingTime.tr
                                : AppStrings.selectBookingRange.tr,
                          ),
                          ServiceRangeSelector(service: service),
                          const SizedBox(height: 28),
                        ],

                        _buildSectionTitle(AppStrings.serviceSpecifications.tr),
                        ServiceAttributeGrid(service: service),
                        const SizedBox(height: 32),

                        ServiceReviewsSection(service: service),
                        const SizedBox(height: 180),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: maroon),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: maroon),
                const SizedBox(height: 16),
                Text(
                  '${AppStrings.error.tr}: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: maroon,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: beige,
                  ),
                  onPressed: () => ref.refresh(
                    serviceDetailsProvider(
                      (type: serviceType, id: serviceId),
                    ),
                  ),
                  child: Text(AppStrings.retry.tr),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: serviceAsync.maybeWhen(
        data: (service) {
          final authState = ref.read(authStateProvider);
          if (authState is! AuthSuccess) return const SizedBox.shrink();

          final user = authState.user;

          if (user.role == 'admin' && service.status == 'pending') {
            return _AdminApprovalBar(
              serviceType: serviceType,
              serviceId: int.parse(serviceId),
            );
          }

          if (!showBookingPanel) return const SizedBox.shrink();

          if (user.role == 'admin' || user.role == 'provider') {
            return const SizedBox.shrink();
          }

          return BookingFloatingPanel(service: service);
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryMaroon,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 5,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryMaroon,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.58),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryMaroon.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryMaroon.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ServiceReelsCard extends StatelessWidget {
  final String serviceType;
  final String serviceId;
  final String serviceName;

  const _ServiceReelsCard({
    required this.serviceType,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return InkWell(
      onTap: () {
        context.push('/reels?serviceType=$serviceType&serviceId=$serviceId');
      },
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              maroon,
              const Color(0xFF7A0A0A),
              maroon.withOpacity(0.94),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: beige.withOpacity(0.24),
          ),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.20),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: -10,
              top: -16,
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 96,
                color: beige.withOpacity(0.08),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: beige.withOpacity(0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: beige.withOpacity(0.28),
                    ),
                  ),
                  child: const Icon(
                    Icons.video_collection_rounded,
                    color: beige,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: Get.locale?.languageCode == 'ar'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.reelsServiceReels.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: Get.locale?.languageCode == 'ar'
                            ? TextAlign.right
                            : TextAlign.left,
                        style: const TextStyle(
                          color: beige,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${AppStrings.reelsShortVideosFor.tr} $serviceName',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: Get.locale?.languageCode == 'ar'
                            ? TextAlign.right
                            : TextAlign.left,
                        style: TextStyle(
                          color: beige.withOpacity(0.78),
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: beige,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          AppStrings.reelsWatchServiceReels.tr,
                          style: const TextStyle(
                            color: maroon,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Get.locale?.languageCode == 'ar'
                      ? Icons.keyboard_arrow_left_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  color: beige,
                  size: 31,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoServiceGallery extends StatefulWidget {
  final List<String> images;

  const _AutoServiceGallery({required this.images});

  @override
  State<_AutoServiceGallery> createState() => _AutoServiceGalleryState();
}

class _AutoServiceGalleryState extends State<_AutoServiceGallery> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!_pageController.hasClients) return;

        final next = (_currentIndex + 1) % widget.images.length;

        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openImage(int index) {
    if (widget.images.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (_) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              PageView.builder(
                controller: PageController(initialPage: index),
                itemCount: widget.images.length,
                itemBuilder: (context, i) {
                  return InteractiveViewer(
                    child: Center(
                      child: Image.network(
                        widget.images[i],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 70,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 45,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    if (widget.images.isEmpty) {
      return Container(
        color: maroon,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 80,
            color: beige.withOpacity(0.65),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openImage(index),
              child: Image.network(
                widget.images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: maroon,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 70,
                      color: beige.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        if (widget.images.length > 1)
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? beige
                        : beige.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AdminApprovalBar extends ConsumerStatefulWidget {
  final String serviceType;
  final int serviceId;

  const _AdminApprovalBar({
    required this.serviceType,
    required this.serviceId,
  });

  @override
  ConsumerState<_AdminApprovalBar> createState() => _AdminApprovalBarState();
}

class _AdminApprovalBarState extends ConsumerState<_AdminApprovalBar> {
  bool _isLoading = false;

  Future<void> _handleAction(bool isApprove) async {
    setState(() => _isLoading = true);

    try {
      if (isApprove) {
        await ref
            .read(adminRepoProvider)
            .approveService(widget.serviceType, widget.serviceId);
      } else {
        await ref
            .read(adminRepoProvider)
            .rejectService(widget.serviceType, widget.serviceId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApprove
                  ? AppStrings.serviceApproved.tr
                  : AppStrings.serviceRejected.tr,
            ),
            backgroundColor: isApprove ? Colors.green : Colors.red,
          ),
        );
        ref.invalidate(adminPendingProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.error.tr}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: beige,
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _handleAction(true),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: beige,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  AppStrings.approveAndActivate.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: beige,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => _handleAction(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: maroon,
                  side: const BorderSide(color: maroon),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(AppStrings.reject.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}