class Professional {
  final String uid;
  final String? name;
  final String? location;
  final String? email;
  final String? phoneNumber;
  double rating;
  int reviewCount;
  final String role;

  Professional({
    required this.uid,
    this.name,
    this.location,
    this.email,
    this.phoneNumber,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.role,
  });

  factory Professional.fromMap(Map<String, dynamic> map) {
    return Professional(
      uid: map['uid'] ?? '',
      name: map['displayName'] ?? '',
      location: map['location'] as String?,
      email: map['email'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as int?) ?? 0,
      role: map['role'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': name,
      'location': location,
      'email': email,
      'phoneNumber': phoneNumber,
      'rating': rating,
      'reviewCount': reviewCount,
      'role': role,
    };
  }

  Professional copyWith({
    String? uid,
    String? name,
    String? location,
    String? email,
    String? phoneNumber,
    double? rating,
    int? reviewCount,
    String? role,
  }) {
    return Professional(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      location: location ?? this.location,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      role: role ?? this.role,
    );
  }
}