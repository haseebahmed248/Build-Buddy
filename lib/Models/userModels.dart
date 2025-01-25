// lib/models/user_models.dart


enum UserRole {
  homeowner,
  contractor,
  architect,
  vendor,
  admin
}

enum UserStatus {
  active,
  pending,
  suspended,
  inactive
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

  // Convert UserData to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
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

  // Create UserData from JSON
  factory UserData.fromJson(String uid, UserRole role, Map<String, dynamic> json) {
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

  // Create a copy of UserData with updated fields
  UserData copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? lastLogin,
    bool? emailVerified,
    String? status,
  }) {
    return UserData(
      uid: uid,
      email: email,
      role: role,
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
    if (additionalInfo != null) data.addAll(additionalInfo!);
    return data;
  }
}
























//Runnable code


// lib/models/user_models.dart

/*
enum UserRole {
  homeowner,
  contractor,
  architect,
  vendor,
  admin
}

class UserCredentials {
  String email;
  String password;

  UserCredentials({
    required this.email,
    required this.password
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
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName ?? '',
      'photoURL': photoURL ?? '',
      'phoneNumber': phoneNumber ?? '',
      'emailVerified': emailVerified,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory UserData.fromJson(String uid, UserRole role, Map<String, dynamic> json) {
    return UserData(
      uid: uid,
      email: json['email'] ?? '',
      role: role,
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      phoneNumber: json['phoneNumber'],
      emailVerified: json['emailVerified'] ?? false,
      provider: json['provider'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: DateTime.parse(json['lastLogin'] ?? DateTime.now().toIso8601String()),
    );
  }

  get name => null;

  // Create a copy of UserData with updated fields
  UserData copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? lastLogin,
  }) {
    return UserData(
      uid: uid,
      email: email,
      role: role,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified,
      provider: provider,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class RegisterUserData {
  final String email;
  final String password;
  final UserRole role;
  final String? displayName;
  final String? phoneNumber;

  RegisterUserData({
    required this.email,
    required this.password,
    required this.role,
    this.displayName,
    this.phoneNumber,
  });
}

class UserLoginResponse {
  final bool success;
  final UserData? userData;
  final String message;
  final String? error;

  UserLoginResponse({
    required this.success,
    this.userData,
    required this.message,
    this.error,
  });

  factory UserLoginResponse.success(UserData userData, {required String message}) {
    return UserLoginResponse(
      success: true,
      userData: userData,
      message: 'Login successful',
    );
  }

  factory UserLoginResponse.error(String message, [String? error]) {
    return UserLoginResponse(
      success: false,
      message: message,
      error: error,
    );
  }
}
*/







