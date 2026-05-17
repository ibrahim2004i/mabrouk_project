class AuthUser {
  final int id;
  final String phoneNumber;
  final String role;
  
  // Customer specific
  final String? name; // full_name
  final String? gender;
  final int? preferredCityId;
  
  // Provider specific
  final String? brandName;
  final String? legalName;
  final String? officePhone;
  final int? cityId;
  final String? addressDetails;
  final String? bioDescription;
  final String? imageUrl; // Mapped from profile_image or logo_url

  AuthUser({
    required this.id,
    required this.phoneNumber,
    required this.role,
    this.name,
    this.gender,
    this.preferredCityId,
    this.brandName,
    this.legalName,
    this.officePhone,
    this.cityId,
    this.addressDetails,
    this.bioDescription,
    this.imageUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      phoneNumber: json['phone_number'],
      role: json['role'],
      name: json['full_name'],
      gender: json['gender'],
      preferredCityId: json['preferred_city_id'] != null ? int.tryParse(json['preferred_city_id'].toString()) : null,
      brandName: json['brand_name'],
      legalName: json['legal_name'],
      officePhone: json['office_phone'],
      cityId: json['city_id'] != null ? int.tryParse(json['city_id'].toString()) : null,
      addressDetails: json['address_details'],
      bioDescription: json['bio_description'],
      imageUrl: json['profile_image'] ?? json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'role': role,
      'full_name': name,
      'gender': gender,
      'preferred_city_id': preferredCityId,
      'brand_name': brandName,
      'legal_name': legalName,
      'office_phone': officePhone,
      'city_id': cityId,
      'address_details': addressDetails,
      'bio_description': bioDescription,
      if (role == 'provider') 'logo_url': imageUrl else 'profile_image': imageUrl,
    };
  }
}

class AuthResponse {
  final String token;
  final AuthUser user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: AuthUser.fromJson(json['user']),
    );
  }
}
