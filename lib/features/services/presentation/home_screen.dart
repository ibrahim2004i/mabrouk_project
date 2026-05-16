import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/features/services/presentation/service_providers.dart';
import 'package:mabrouk_app/features/services/presentation/widgets/filter_bottom_sheet.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/notification_badge.dart';
import '../../../shared/widgets/service_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final currentCategory = ref.watch(currentCategoryProvider);
    final filter = ref.watch(serviceFilterProvider);

    const primaryMaroon = Color(0xFF600000);
    const luxuryBeige = AppTheme.luxuryBeige;
    const lightBeige = Color(0xFFF5F5DC);

    final categories = [
      {'id': 'hall', 'name': AppStrings.halls.tr, 'icon': Icons.business},
      {'id': 'chalet', 'name': AppStrings.chalets.tr, 'icon': Icons.holiday_village},
      {'id': 'dress', 'name': AppStrings.dresses.tr, 'icon': Icons.checkroom},
      {'id': 'suit', 'name': AppStrings.suits.tr, 'icon': Icons.accessibility_new},
      {'id': 'photographer', 'name': AppStrings.photographers.tr, 'icon': Icons.camera_alt},
      {'id': 'cake', 'name': AppStrings.cakes.tr, 'icon': Icons.cake},
      {'id': 'car', 'name': AppStrings.cars.tr, 'icon': Icons.directions_car},
    ];

    return Scaffold(
      backgroundColor: luxuryBeige,
      drawer: const AppDrawer(),

      floatingActionButton: Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF600000),
        Color(0xFF7A0A0A),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: primaryMaroon.withOpacity(0.35),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: FloatingActionButton(
    heroTag: 'reels_btn',
    backgroundColor: Colors.transparent,
    elevation: 0,
    onPressed: () {
      context.push('/reels');
    },
    child: const Icon(
      Icons.video_collection_rounded,
      color: luxuryBeige,
      size: 30,
    ),
  ),
),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 105,
            pinned: true,
            backgroundColor: primaryMaroon,
            elevation: 0,
            leadingWidth: 58,
            leading: Builder(
              builder: (context) => IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 46,
                  minHeight: 46,
                ),
                icon: Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: lightBeige.withOpacity(0.20),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.menu_rounded,
                      color: lightBeige,
                      size: 24,
                    ),
                  ),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 46,
                  minHeight: 46,
                ),
                onPressed: () => _showFilterOptions(context, currentCategory),
                icon: Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: lightBeige.withOpacity(0.20),
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: filter.isActive ? luxuryBeige : lightBeige,
                          size: 22,
                        ),
                        if (filter.isActive)
                          Positioned(
                            right: -3,
                            top: -3,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: luxuryBeige,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryMaroon,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              NotificationBadge(color: lightBeige),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 9),
             title: Text(
  AppStrings.appName.tr,
  style: Get.locale?.languageCode == 'ar'
      ? GoogleFonts.reemKufiFun(
          color: lightBeige,
          fontSize: 33,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          shadows: [
            Shadow(
              offset: const Offset(0, 3),
              blurRadius: 10,
              color: Colors.black.withOpacity(0.28),
            ),
          ],
        )
      : GoogleFonts.elMessiri(
          color: lightBeige,
          fontSize: 33,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(
              offset: const Offset(0, 3),
              blurRadius: 10,
              color: Colors.black.withOpacity(0.28),
            ),
          ],
        ),
),
             background: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF600000),
                ),
                ),
            ),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 88,
              maxHeight: 88,
              child: Container(
                decoration: BoxDecoration(
                  color: innerBoxIsScrolled ? luxuryBeige : primaryMaroon,
                  boxShadow: innerBoxIsScrolled
                      ? [
                          BoxShadow(
                            color: primaryMaroon.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = currentCategory == cat['id'];

                    return GestureDetector(
                      onTap: () => ref
                          .read(servicesProvider.notifier)
                          .setCategory(cat['id'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 12, bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: innerBoxIsScrolled
                                      ? [
                                          primaryMaroon,
                                          const Color(0xFF7A0A0A),
                                        ]
                                      : [
                                          lightBeige,
                                          luxuryBeige,
                                        ],
                                )
                              : null,
                          color: isSelected
                              ? null
                              : Colors.white.withOpacity(
                                  innerBoxIsScrolled ? 0.55 : 0.13,
                                ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? lightBeige.withOpacity(0.28)
                                : lightBeige.withOpacity(0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryMaroon.withOpacity(
                                isSelected ? 0.18 : 0.05,
                              ),
                              blurRadius: isSelected ? 12 : 7,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 21,
                              color: isSelected
                                  ? (innerBoxIsScrolled
                                      ? Colors.white
                                      : primaryMaroon)
                                  : (innerBoxIsScrolled
                                      ? primaryMaroon
                                      : lightBeige),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? (innerBoxIsScrolled
                                        ? Colors.white
                                        : primaryMaroon)
                                    : (innerBoxIsScrolled
                                        ? primaryMaroon
                                        : lightBeige),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          color: primaryMaroon,
          onRefresh: () => ref.read(servicesProvider.notifier).refreshCurrent(),
          child: servicesAsync.when(
            data: (services) => services.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.searchHint.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryMaroon.withOpacity(0.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ServiceCard(
                          service: service,
                          onTap: () async {
                            await context.push(
                              '/customer/services/${service.type}/${service.id}',
                            );
                            ref.read(servicesProvider.notifier).refreshCurrent();
                          },
                        ),
                      );
                    },
                  ),
            loading: () => _buildShimmerLoader(),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppStrings.error.tr}: $err',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => ref.refresh(servicesProvider),
                    child: Text(AppStrings.retry.tr),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(category: category),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (c, i) => Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}