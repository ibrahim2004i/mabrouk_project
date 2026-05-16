import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/services/presentation/favorites_notifier.dart';
import 'package:mabrouk_app/features/services/presentation/service_providers.dart';
import 'package:mabrouk_app/shared/widgets/service_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: maroon,
        foregroundColor: beige,
        title: Text(
          AppStrings.myFavorites.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: beige,
          ),
        ),
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: beige.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: beige,
            ),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: beige,
        ),
        child: favorites.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final compositeId = favorites.elementAt(index);
                  final parts = compositeId.split('_');
                  if (parts.length < 2) return const SizedBox.shrink();

                  final type = parts[0];
                  final id = parts[1];

                  return Consumer(
                    builder: (context, ref, child) {
                      final serviceAsync = ref.watch(
                        serviceDetailsProvider((type: type, id: id)),
                      );

                      return serviceAsync.when(
                        data: (service) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ServiceCard(
                            service: service,
                            onTap: () => context.push(
                              '/customer/services/${service.type}/${service.id}',
                            ),
                          ),
                        ),
                        loading: () => const CardLoadingPlaceholder(),
                        error: (err, stack) => const SizedBox.shrink(),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: maroon.withOpacity(0.10),
            ),
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
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: maroon.withOpacity(0.08),
                  border: Border.all(
                    color: maroon.withOpacity(0.14),
                  ),
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 48,
                  color: maroon.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                AppStrings.favoritesEmptyTitle.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: maroon,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.favoritesEmptySubtitle.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: maroon.withOpacity(0.65),
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardLoadingPlaceholder extends StatelessWidget {
  const CardLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Container(
      height: 250,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: maroon.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(color: maroon),
      ),
    );
  }
}