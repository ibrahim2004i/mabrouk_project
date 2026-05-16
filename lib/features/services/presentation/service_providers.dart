import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/features/services/domain/service_models.dart';
import 'package:mabrouk_app/features/services/domain/service_filter.dart';
import 'package:mabrouk_app/features/services/data/service_repository.dart';

// --- 🌐 Category State Provider ---
final currentCategoryProvider = StateProvider<String>((ref) => 'hall');

// --- 🔍 Filter State Provider ---
final serviceFilterProvider = StateProvider<ServiceFilter>((ref) => const ServiceFilter());

// --- 🚀 Optimized Services Notifier ---
class ServicesNotifier extends AsyncNotifier<List<ServiceBase>> {
  // Keep an internal persistent cache for categories
  static final Map<String, List<ServiceBase>> _globalCache = {};

  @override
  FutureOr<List<ServiceBase>> build() async {
    final type = ref.watch(currentCategoryProvider);
    final filter = ref.watch(serviceFilterProvider);
    
    List<ServiceBase> rawServices;

    // 1. Get from cache or API
    if (_globalCache.containsKey(type)) {
      rawServices = _globalCache[type]!;
    } else {
      rawServices = await _fetchFromApi(type);
    }

    // 2. Apply Filters (In-Memory for extreme speed)
    return _applyFilters(rawServices, filter);
  }

  List<ServiceBase> _applyFilters(List<ServiceBase> list, ServiceFilter filter) {
    if (!filter.isActive) return list;

    return list.where((s) {
      // Common: Price
      if (filter.minPrice != null && s.price < filter.minPrice!) return false;
      if (filter.maxPrice != null && s.price > filter.maxPrice!) return false;
      
      // Common: City
      if (filter.cityId != null && s.cityId != filter.cityId) return false;

      // Common: Offering Type (Booking vs Purchase)
      if (filter.offeringType != null && s.offeringType != filter.offeringType) return false;

      // Category Specifics
      if (s is WeddingHall) {
        if (filter.minCapacity != null && s.maxCapacity < filter.minCapacity!) return false;
      }
      if (s is Chalet) {
        if (filter.minRooms != null && s.roomsCount < filter.minRooms!) return false;
        if (filter.hasPool != null && s.hasPool != filter.hasPool) return false;
      }
      if (s is Dress || s is Suit) {
        // Size filtering (partial match)
        if (filter.size != null) {
           final sizes = (s is Dress) ? s.sizes : (s as Suit).sizes;
           if (sizes != null && !sizes.contains(filter.size!)) return false;
        }
      }

      return true;
    }).toList();
  }

  Future<List<ServiceBase>> _fetchFromApi(String type) async {
    final services = await ref.read(serviceRepoProvider).getServicesByType(type);
    _globalCache[type] = services;
    return services;
  }

  Future<void> refreshCurrent() async {
    final type = ref.read(currentCategoryProvider);
    _globalCache.remove(type); // 🔥 Clear cache for this category
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchFromApi(type));
  }

  void setCategory(String type) {
    // Reset filters when changing category to avoid weird behavior
    ref.read(serviceFilterProvider.notifier).state = const ServiceFilter();
    ref.read(currentCategoryProvider.notifier).state = type;
  }

  void setFilter(ServiceFilter filter) {
    ref.read(serviceFilterProvider.notifier).state = filter;
  }

  void clearFilters() {
    ref.read(serviceFilterProvider.notifier).state = const ServiceFilter();
  }
}

// --- ⚓ Unified Services Provider ---
final servicesProvider = AsyncNotifierProvider<ServicesNotifier, List<ServiceBase>>(() {
  return ServicesNotifier();
});

// --- 🎯 Specific Service Detail Provider ---
// Directly fetches a specific service by ID from the API to support all statuses (pending/approved/rejected).
final serviceDetailsProvider = FutureProvider.family<ServiceBase, ({String type, String id})>((ref, arg) async {
  return await ref.read(serviceRepoProvider).getServiceById(arg.type, arg.id);
});

