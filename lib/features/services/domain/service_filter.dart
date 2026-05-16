import 'package:mabrouk_app/features/services/domain/service_models.dart';

class ServiceFilter {
  final double? minPrice;
  final double? maxPrice;
  final int? cityId;
  final String? cityName;
  final OfferingType? offeringType; // 🆕
  
  // Category specific filters
  final int? minCapacity;
  final int? minRooms;
  final String? size;
  final bool? hasPool;

  const ServiceFilter({
    this.minPrice,
    this.maxPrice,
    this.cityId,
    this.cityName,
    this.offeringType,
    this.minCapacity,
    this.minRooms,
    this.size,
    this.hasPool,
  });

  ServiceFilter copyWith({
    double? minPrice,
    double? maxPrice,
    int? cityId,
    String? cityName,
    OfferingType? offeringType,
    int? minCapacity,
    int? minRooms,
    String? size,
    bool? hasPool,
    bool clearCity = false,
    bool clearOffering = false, 
  }) {
    return ServiceFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      cityId: clearCity ? null : (cityId ?? this.cityId),
      cityName: clearCity ? null : (cityName ?? this.cityName),
      offeringType: clearOffering ? null : (offeringType ?? this.offeringType),
      minCapacity: minCapacity ?? this.minCapacity,
      minRooms: minRooms ?? this.minRooms,
      size: size ?? this.size,
      hasPool: hasPool ?? this.hasPool,
    );
  }

  bool get isActive => 
      minPrice != null || 
      maxPrice != null || 
      cityId != null || 
      offeringType != null || 
      minCapacity != null || 
      minRooms != null || 
      size != null || 
      hasPool != null;
}
