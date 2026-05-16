import 'dart:convert';
import 'package:flutter/foundation.dart';

enum ServiceType { hall, chalet, dress, suit, car, cake, photographer }

enum OfferingType { booking, purchase }

enum PriceUnit { hour, day, event }

abstract class ServiceBase {
  final int id;
  final int providerId;
  final String title;
  final double price;
  final String? description;
  final String status;
  final String? brandName;
  final String? logoUrl;
  final String type;
  final double overallRating;
  final int reviewsCount;
  final OfferingType offeringType;
  final List<Specification> specifications;
  final PriceUnit priceUnit;
  final int cityId;
  final String? cityName;
  final String? locationAddress;
  final String? phoneNumber;
  final String? whatsappNumber;
  final double? rangeStart;
  final double? rangeEnd;
  final int stockCount;
  final List<String> mediaUrls;

  ServiceBase({
    required this.id,
    required this.providerId,
    required this.title,
    required this.price,
    this.description,
    required this.status,
    this.brandName,
    this.logoUrl,
    required this.type,
    this.overallRating = 0.0,
    this.reviewsCount = 0,
    this.offeringType = OfferingType.booking,
    this.priceUnit = PriceUnit.event,
    this.cityId = 1,
    this.cityName,
    this.locationAddress,
    this.phoneNumber,
    this.whatsappNumber,
    this.rangeStart,
    this.rangeEnd,
    this.stockCount = 1,
    this.specifications = const [],
    this.mediaUrls = const [],
  });

  static ServiceBase fromJson(Map<String, dynamic> json) {
    final type = json['service_type'] ?? 'hall';
    switch (type) {
      case 'hall': return WeddingHall.fromJson(json);
      case 'dress': return Dress.fromJson(json);
      case 'chalet': return Chalet.fromJson(json);
      case 'suit': return Suit.fromJson(json);
      case 'car': return Car.fromJson(json);
      case 'cake': return Cake.fromJson(json);
      case 'photographer': return Photographer.fromJson(json);
      case 'others': return OtherService.fromJson(json);
      default: return WeddingHall.fromJson(json);
    }
  }

  static OfferingType _parseOffering(String? val) {
    if (val == 'purchase') return OfferingType.purchase;
    return OfferingType.booking;
  }

  static PriceUnit _parseUnit(String? val) {
    if (val == 'hour') return PriceUnit.hour;
    if (val == 'day') return PriceUnit.day;
    return PriceUnit.event;
  }

  static List<Specification> _parseSpecs(dynamic specs) {
    if (specs == null) return [];
    if (specs is String && specs.isNotEmpty) {
      try {
        final decoded = jsonDecode(specs);
        if (decoded is List) {
          return decoded.map((s) => Specification.fromJson(s as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Error parsing specs string: $e');
      }
    }
    if (specs is List) {
      return specs.map((s) => Specification.fromJson(s as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static List<String> _parseMedia(dynamic media) {
    if (media is List) {
      return media.map((m) => m['file_url']?.toString() ?? '').where((url) => url.isNotEmpty).toList();
    }
    return [];
  }
}

class WeddingHall extends ServiceBase {
  final int maxCapacity;
  final String hallType;

  WeddingHall({
    required super.id,
    required super.providerId,
    required super.title,
    required super.price,
    super.description,
    required super.status,
    super.brandName,
    super.logoUrl,
    super.overallRating,
    super.reviewsCount,
    super.offeringType,
    super.priceUnit,
    super.cityId,
    super.cityName,
    super.locationAddress,
    super.phoneNumber,
    super.whatsappNumber,
    super.rangeStart,
    super.rangeEnd,
    super.stockCount,
    super.specifications,
    super.mediaUrls,
    required this.maxCapacity,
    required this.hallType,
  }) : super(type: 'hall');

  factory WeddingHall.fromJson(Map<String, dynamic> json) {
    return WeddingHall(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Wedding Hall',
      price: double.tryParse(json['base_price']?.toString() ?? '') ?? 0.0,
      description: json['description'],
      status: json['status']?.toString() ?? 'approved',
      brandName: json['brand_name'],
      logoUrl: json['logo_url'],
      overallRating: double.tryParse(json['overall_rating']?.toString() ?? '') ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      offeringType: ServiceBase._parseOffering(json['offering_type']),
      priceUnit: ServiceBase._parseUnit(json['price_unit']),
      cityId: json['city_id'] ?? 1,
      cityName: json['city_name'],
      locationAddress: json['location_address'],
      rangeStart: double.tryParse(json['range_start']?.toString() ?? ''),
      rangeEnd: double.tryParse(json['range_end']?.toString() ?? ''),
      phoneNumber: json['office_phone'],
      whatsappNumber: json['whatsapp_number'],
      stockCount: int.tryParse(json['stock_count']?.toString() ?? '') ?? 1,
      specifications: ServiceBase._parseSpecs(json['specifications']),
      mediaUrls: ServiceBase._parseMedia(json['media']),
      maxCapacity: int.tryParse(json['max_capacity']?.toString() ?? '') ?? 0,
      hallType: json['hall_type'] ?? 'indoor',
    );
  }
}

class Dress extends ServiceBase {
  final String sizes;
  final String businessMode;

  Dress({
    required super.id,
    required super.providerId,
    required super.title,
    required super.price,
    super.description,
    required super.status,
    super.brandName,
    super.logoUrl,
    super.overallRating,
    super.reviewsCount,
    super.offeringType,
    super.priceUnit,
    super.cityId,
    super.cityName,
    super.locationAddress,
    super.phoneNumber,
    super.whatsappNumber,
    super.rangeStart,
    super.rangeEnd,
    super.stockCount,
    super.specifications,
    super.mediaUrls,
    required this.sizes,
    required this.businessMode,
  }) : super(type: 'dress');

  factory Dress.fromJson(Map<String, dynamic> json) {
    return Dress(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Dress',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      description: json['description'],
      status: json['status']?.toString() ?? 'approved',
      brandName: json['brand_name'],
      logoUrl: json['logo_url'],
      overallRating: double.tryParse(json['overall_rating']?.toString() ?? '') ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      offeringType: ServiceBase._parseOffering(json['offering_type']),
      priceUnit: ServiceBase._parseUnit(json['price_unit']),
      cityId: json['city_id'] ?? 1,
      cityName: json['city_name'],
      locationAddress: json['location_address'],
      rangeStart: double.tryParse(json['range_start']?.toString() ?? ''),
      rangeEnd: double.tryParse(json['range_end']?.toString() ?? ''),
      phoneNumber: json['office_phone'],
      whatsappNumber: json['whatsapp_number'],
      stockCount: int.tryParse(json['stock_count']?.toString() ?? '') ?? 1,
      specifications: ServiceBase._parseSpecs(json['specifications']),
      mediaUrls: ServiceBase._parseMedia(json['media']),
      sizes: json['sizes_available'] ?? '',
      businessMode: json['business_mode'] ?? 'rent',
    );
  }
}

class Chalet extends ServiceBase {
  final int roomsCount;
  final bool hasPool;

  Chalet({
    required super.id,
    required super.providerId,
    required super.title,
    required super.price,
    super.description,
    required super.status,
    super.brandName,
    super.logoUrl,
    super.overallRating,
    super.reviewsCount,
    super.offeringType,
    super.priceUnit,
    super.cityId,
    super.cityName,
    super.locationAddress,
    super.phoneNumber,
    super.whatsappNumber,
    super.rangeStart,
    super.rangeEnd,
    super.stockCount,
    super.specifications,
    super.mediaUrls,
    required this.roomsCount,
    required this.hasPool,
  }) : super(type: 'chalet');

  factory Chalet.fromJson(Map<String, dynamic> json) {
    return Chalet(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Chalet',
      price: double.tryParse(json['price_per_night']?.toString() ?? '') ?? 0.0,
      description: json['description'],
      status: json['status']?.toString() ?? 'approved',
      brandName: json['brand_name'],
      logoUrl: json['logo_url'],
      overallRating: double.tryParse(json['overall_rating']?.toString() ?? '') ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      offeringType: ServiceBase._parseOffering(json['offering_type']),
      priceUnit: ServiceBase._parseUnit(json['price_unit']),
      cityId: json['city_id'] ?? 1,
      cityName: json['city_name'],
      locationAddress: json['location_address'],
      rangeStart: double.tryParse(json['range_start']?.toString() ?? ''),
      rangeEnd: double.tryParse(json['range_end']?.toString() ?? ''),
      phoneNumber: json['office_phone'],
      whatsappNumber: json['whatsapp_number'],
      stockCount: int.tryParse(json['stock_count']?.toString() ?? '') ?? 1,
      specifications: ServiceBase._parseSpecs(json['specifications']),
      mediaUrls: ServiceBase._parseMedia(json['media']),
      roomsCount: int.tryParse(json['rooms_count']?.toString() ?? '') ?? 1,
      hasPool: json['has_pool'] == 1 || json['has_pool'] == true || json['has_pool'] == '1',
    );
  }
}

class Car extends ServiceBase {
  final String brand;
  final String model;
  final int? year;
  final bool withDriver;

  Car({
    required super.id,
    required super.providerId,
    required super.title,
    required super.price,
    super.description,
    required super.status,
    super.brandName,
    super.logoUrl,
    super.overallRating,
    super.reviewsCount,
    super.offeringType,
    super.priceUnit,
    super.cityId,
    super.cityName,
    super.locationAddress,
    super.phoneNumber,
    super.whatsappNumber,
    super.rangeStart,
    super.rangeEnd,
    super.stockCount,
    super.specifications,
    super.mediaUrls,
    required this.brand,
    required this.model,
    this.year,
    required this.withDriver,
  }) : super(type: 'car');

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      title: json['name']?.toString() ?? json['title']?.toString() ?? json['brand']?.toString() ?? 'Car',
      price: double.tryParse(json['price_per_day']?.toString() ?? '') ?? 0.0,
      description: json['description'],
      status: json['status']?.toString() ?? 'approved',
      brandName: json['brand_name'],
      logoUrl: json['logo_url'],
      overallRating: double.tryParse(json['overall_rating']?.toString() ?? '') ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      offeringType: ServiceBase._parseOffering(json['offering_type']),
      priceUnit: ServiceBase._parseUnit(json['price_unit']),
      cityId: json['city_id'] ?? 1,
      cityName: json['city_name'],
      locationAddress: json['location_address'],
      rangeStart: double.tryParse(json['range_start']?.toString() ?? ''),
      rangeEnd: double.tryParse(json['range_end']?.toString() ?? ''),
      phoneNumber: json['office_phone'],
      whatsappNumber: json['whatsapp_number'],
      stockCount: int.tryParse(json['stock_count']?.toString() ?? '') ?? 1,
      specifications: ServiceBase._parseSpecs(json['specifications']),
      mediaUrls: ServiceBase._parseMedia(json['media']),
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: int.tryParse(json['year']?.toString() ?? ''),
      withDriver: json['with_driver'] == 1 || json['with_driver'] == true || json['with_driver'] == '1',
    );
  }
}

class Suit extends ServiceBase {
  final String? sizes;

  Suit({
    required super.id,
    required super.providerId,
    required super.title,
    required super.price,
    super.description,
    required super.status,
    super.brandName,
    super.logoUrl,
    super.overallRating,
    super.reviewsCount,
    super.offeringType,
    super.priceUnit,
    super.cityId,
    super.cityName,
    super.locationAddress,
    super.phoneNumber,
    super.whatsappNumber,
    super.rangeStart,
    super.rangeEnd,
    super.stockCount,
    super.specifications,
    super.mediaUrls,
    this.sizes,
  }) : super(type: 'suit');

  factory Suit.fromJson(Map<String, dynamic> json) {
    return Suit(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Suit',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      description: json['description'],
      status: json['status']?.toString() ?? 'approved',
      brandName: json['brand_name'],
      logoUrl: json['logo_url'],
      overallRating: double.tryParse(json['overall_rating']?.toString() ?? '') ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      offeringType: ServiceBase._parseOffering(json['offering_type']),
      priceUnit: ServiceBase._parseUnit(json['price_unit']),
      cityId: json['city_id'] ?? 1,
      cityName: json['city_name'],
      locationAddress: json['location_address'],
      rangeStart: double.tryParse(json['range_start']?.toString() ?? ''),
      rangeEnd: double.tryParse(json['range_end']?.toString() ?? ''),
      phoneNumber: json['office_phone'],
      whatsappNumber: json['whatsapp_number'],
      stockCount: int.tryParse(json['stock_count']?.toString() ?? '') ?? 1,
      specifications: ServiceBase._parseSpecs(json['specifications']),
      mediaUrls: ServiceBase._parseMedia(json['media']),
      sizes: json['sizes_available'],
    );
  }
}

class Cake extends ServiceBase {
  final int preparationDays;

  Cake({
    required super.id,
    required super.providerId,
    required super.title,
    required super.price,
    super.description,
    required super.status,
    super.brandName,
    super.logoUrl,
    super.overallRating,
    super.reviewsCount,
    super.offeringType,
    super.priceUnit,
    super.cityId,
    super.cityName,
    super.locationAddress,
    super.phoneNumber,
    super.whatsappNumber,
    super.rangeStart,
    super.rangeEnd,
    super.stockCount,
    super.specifications,
    super.mediaUrls,
    required this.preparationDays,
  }) : super(type: 'cake');

  factory Cake.fromJson(Map<String, dynamic> json) {
    return Cake(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Cake',
      price: double.tryParse(json['base_price']?.toString() ?? '') ?? 0.0,
      description: json['description'],
      status: json['status']?.toString() ?? 'approved',
      brandName: json['brand_name'],
      logoUrl: json['logo_url'],
      overallRating: double.tryParse(json['overall_rating']?.toString() ?? '') ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      offeringType: ServiceBase._parseOffering(json['offering_type']),
      priceUnit: ServiceBase._parseUnit(json['price_unit']),
      cityId: json['city_id'] ?? 1,
      cityName: json['city_name'],
      locationAddress: json['location_address'],
      rangeStart: double.tryParse(json['range_start']?.toString() ?? ''),
      rangeEnd: double.tryParse(json['range_end']?.toString() ?? ''),
      phoneNumber: json['office_phone'],
      whatsappNumber: json['whatsapp_number'],
      stockCount: int.tryParse(json['stock_count']?.toString() ?? '') ?? 1,
      specifications: ServiceBase._parseSpecs(json['specifications']),
      mediaUrls: ServiceBase._parseMedia(json['media']),
      preparationDays: json['preparation_days'] ?? 3,
    );
  }
}

class Photographer extends ServiceBase {
  final String packageDetails;

  Photographer({
    required super.id,
    required super.providerId,
    required super.title,
    required super.price,
    super.description,
    required super.status,
    super.brandName,
    super.logoUrl,
    super.overallRating,
    super.reviewsCount,
    super.offeringType,
    super.priceUnit,
    super.cityId,
    super.cityName,
    super.locationAddress,
    super.phoneNumber,
    super.whatsappNumber,
    super.rangeStart,
    super.rangeEnd,
    super.stockCount,
    super.specifications,
    super.mediaUrls,
    required this.packageDetails,
  }) : super(type: 'photographer');

  factory Photographer.fromJson(Map<String, dynamic> json) {
    return Photographer(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      title: json['package_name']?.toString() ?? json['title']?.toString() ?? 'Photography Package',
      price: double.tryParse(json['base_price']?.toString() ?? '') ?? 0.0,
      description: json['description'] ?? json['package_details'],
      status: json['status']?.toString() ?? 'approved',
      brandName: json['brand_name'],
      logoUrl: json['logo_url'],
      overallRating: double.tryParse(json['overall_rating']?.toString() ?? '') ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      offeringType: ServiceBase._parseOffering(json['offering_type']),
      priceUnit: ServiceBase._parseUnit(json['price_unit']),
      cityId: json['city_id'] ?? 1,
      cityName: json['city_name'],
      locationAddress: json['location_address'],
      rangeStart: double.tryParse(json['range_start']?.toString() ?? ''),
      rangeEnd: double.tryParse(json['range_end']?.toString() ?? ''),
      phoneNumber: json['office_phone'],
      whatsappNumber: json['whatsapp_number'],
      stockCount: int.tryParse(json['stock_count']?.toString() ?? '') ?? 1,
      specifications: ServiceBase._parseSpecs(json['specifications']),
      mediaUrls: ServiceBase._parseMedia(json['media']),
      packageDetails: json['package_details'] ?? '',
    );
  }
}

class OtherService extends ServiceBase {
  final String typeName;

  OtherService({
    required super.id,
    required super.providerId,
    required super.title,
    required super.price,
    super.description,
    required super.status,
    super.brandName,
    super.logoUrl,
    super.overallRating,
    super.reviewsCount,
    super.offeringType,
    super.priceUnit,
    super.cityId,
    super.cityName,
    super.locationAddress,
    super.phoneNumber,
    super.whatsappNumber,
    super.rangeStart,
    super.rangeEnd,
    super.stockCount,
    super.specifications,
    super.mediaUrls,
    required this.typeName,
  }) : super(type: 'others');

  factory OtherService.fromJson(Map<String, dynamic> json) {
    return OtherService(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Other Service',
      price: double.tryParse(json['base_price']?.toString() ?? '') ?? 0.0,
      description: json['description'],
      status: json['status']?.toString() ?? 'approved',
      brandName: json['brand_name'],
      logoUrl: json['logo_url'],
      overallRating: double.tryParse(json['overall_rating']?.toString() ?? '') ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      offeringType: ServiceBase._parseOffering(json['offering_type']),
      priceUnit: ServiceBase._parseUnit(json['price_unit']),
      cityId: json['city_id'] ?? 1,
      cityName: json['city_name'],
      locationAddress: json['location_address'],
      rangeStart: double.tryParse(json['range_start']?.toString() ?? ''),
      rangeEnd: double.tryParse(json['range_end']?.toString() ?? ''),
      phoneNumber: json['office_phone'],
      whatsappNumber: json['whatsapp_number'],
      stockCount: int.tryParse(json['stock_count']?.toString() ?? '') ?? 1,
      specifications: ServiceBase._parseSpecs(json['specifications']),
      mediaUrls: ServiceBase._parseMedia(json['media']),
      typeName: json['type_name'] ?? 'Other',
    );
  }
}

class Specification {
  final String label;
  final String value;

  Specification({required this.label, required this.value});

  factory Specification.fromJson(Map<String, dynamic> json) {
    return Specification(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
  };
}
