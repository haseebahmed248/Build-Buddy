class Contractor {
  final String uid;
  final String name; // Maps to displayName in Firebase
  final String? location; // Optional, default to empty if not present
  final String? email; // Optional, maps to email in Firebase
  final String? phoneNumber; // Optional, maps to phoneNumber in Firebase
  final double rating; // Rating from reviews (default to 0.0 if not present)
  final int reviewCount; // Number of reviews (default to 0 if not present)
  final String role; // Contractor or Architect

  Contractor({
    required this.uid,
    required this.name,
    this.location,
    this.email,
    this.phoneNumber,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'location': location ?? '',
    'email': email,
    'phoneNumber': phoneNumber,
    'rating': rating,
    'reviewCount': reviewCount,
    'role': role,
  };

  factory Contractor.fromMap(Map<String, dynamic> map) {
    return Contractor(
      uid: map['uid'] ?? '',
      name: map['displayName'] ?? '', // Map displayName to name
      location: map['location'] as String?, // Optional
      email: map['email'] as String?, // Optional
      phoneNumber: map['phoneNumber'] as String?, // Optional
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0, // Default to 0.0
      reviewCount: (map['reviewCount'] as int?) ?? 0, // Default to 0
      role: map['role'] ?? 'Contractor', // Default to Contractor if not specified
    );
  }
}