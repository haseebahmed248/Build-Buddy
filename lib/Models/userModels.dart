import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Add this for path inference

enum UserRole {
  homeowner,
  contractor,
  architect,
  vendor,
  admin,
}

enum UserStatus {
  active,
  pending,
  suspended,
  inactive,
}

class UserCredentials {
  final String email;
  final String password;

  UserCredentials({
    required this.email,
    required this.password,
  });
}

class UserData {
  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool emailVerified;
  final String provider;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String status;

  UserData({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.emailVerified,
    required this.provider,
    required this.createdAt,
    required this.lastLogin,
    this.status = 'active',
  });

  // Convert UserData to JSON for Realtime Database
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role.name, // Convert enum to string for Firebase
      'displayName': displayName ?? '',
      'photoURL': photoURL ?? '',
      'phoneNumber': phoneNumber ?? '',
      'emailVerified': emailVerified,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'status': status,
    };
  }

  // Create UserData from JSON (Realtime Database snapshot) - Now asynchronous
  static Future<UserData> fromJson(Map<String, dynamic> json, String uid) async {
    // Log the JSON to debug role issues
    print('Parsing UserData from JSON for UID $uid: $json');
    final roleString = json['role'] as String?;
    UserRole role;
    if (roleString != null && roleString.isNotEmpty) {
      try {
        role = UserRole.values.firstWhere((r) => r.name == roleString);
      } catch (e) {
        print('Invalid role found in JSON for UID $uid: $roleString, inferring from path');
        role = (await _inferRoleFromPath(uid)) ?? UserRole.homeowner; // Use path if JSON role is invalid
      }
    } else {
      // Infer role from the path (e.g., if under user/contractor, assume contractor)
      role = (await _inferRoleFromPath(uid)) ?? UserRole.homeowner; // Default to homeowner if path inference fails
      print('No role field found in JSON for UID $uid, inferring from path: ${role.name}');
    }
    return UserData(
      uid: uid,
      email: json['email'] ?? '',
      role: role,
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      phoneNumber: json['phoneNumber'],
      emailVerified: json['emailVerified'] ?? false,
      provider: json['provider'] ?? 'password',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: DateTime.parse(json['lastLogin'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
    );
  }

  // Helper method to infer role from the path (based on Firebase structure)
  static Future<UserRole?> _inferRoleFromPath(String uid) async {
    // Use FirebaseDatabase to check the path asynchronously
    try {
      for (var role in UserRole.values) {
        final snapshot = await FirebaseDatabase.instance.ref('user/${role.name}/$uid').get();
        if (snapshot.exists) {
          return role;
        }
      }
    } catch (e) {
      print('Error inferring role from path for UID $uid: $e');
      return null; // Return null if inference fails
    }
    return null; // Return null if no role is found
  }

  // Create a copy of UserData with updated fields
  UserData copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? lastLogin,
    bool? emailVerified,
    String? status,
    UserRole? role,
  }) {
    return UserData(
      uid: uid,
      email: email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      provider: provider,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      status: status ?? this.status,
    );
  }

  // Helper methods
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isSuspended => status == 'suspended';
  bool get canAccessApp => isActive || isPending;
  String get name => displayName ?? email.split('@')[0];

  // Role-based permissions
  bool get isAdmin => role == UserRole.admin;
  bool get isHomeowner => role == UserRole.homeowner;
  bool get isContractor => role == UserRole.contractor;
  bool get isArchitect => role == UserRole.architect;
  bool get isVendor => role == UserRole.vendor;
  bool get requiresVerification =>
      [UserRole.contractor, UserRole.architect, UserRole.vendor].contains(role);
}

class RegisterUserData {
  final String email;
  final String password;
  final UserRole role;
  final String? displayName;
  final String? phoneNumber;
  final Map<String, dynamic>? additionalInfo;

  RegisterUserData({
    required this.email,
    required this.password,
    required this.role,
    this.displayName,
    this.phoneNumber,
    this.additionalInfo,
  });

  // Validate registration data
  bool isValid() {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= 8 &&
        (displayName?.isNotEmpty ?? false) &&
        (phoneNumber?.isNotEmpty ?? false);
  }
}

class UserLoginResponse {
  final bool success;
  final UserData? userData;
  final String message;
  final String? error;
  final Map<String, dynamic>? additionalData;

  const UserLoginResponse({
    required this.success,
    this.userData,
    required this.message,
    this.error,
    this.additionalData,
  });

  // Success factory constructor
  factory UserLoginResponse.success(
      UserData userData, {
        String message = 'Login successful',
        Map<String, dynamic>? additionalData,
      }) {
    return UserLoginResponse(
      success: true,
      userData: userData,
      message: message,
      additionalData: additionalData,
    );
  }

  // Error factory constructor
  factory UserLoginResponse.error(String message, [String? error]) {
    return UserLoginResponse(
      success: false,
      message: message,
      error: error,
    );
  }

  // Helper methods
  bool get isSuccess => success;
  bool get hasError => !success;
  bool get requiresVerification =>
      userData?.requiresVerification ?? false;
  bool get canProceed =>
      success && (!requiresVerification || (userData?.emailVerified ?? false));
}

// Profile update data class
class UserProfileUpdateData {
  final String? displayName;
  final String? phoneNumber;
  final Map<String, dynamic>? additionalInfo;

  UserProfileUpdateData({
    this.displayName,
    this.phoneNumber,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (additionalInfo != null) data['additionalInfo'] = additionalInfo;
    return data;
  }
}