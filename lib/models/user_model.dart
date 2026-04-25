// lib/models/user_model.dart

class UserModel {
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String zip;

  const UserModel({
    required this.fullName,
    required this.email,
    this.phone = '',
    this.address = '',
    this.city = '',
    this.zip = '',
  });

  /// Initials from full name
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? zip,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email:    email    ?? this.email,
      phone:    phone    ?? this.phone,
      address:  address  ?? this.address,
      city:     city     ?? this.city,
      zip:      zip      ?? this.zip,
    );
  }
}