/*

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Models/userModels.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Add the new email verification status update method
  Future<void> updateEmailVerificationStatus(String userId, bool isVerified, UserRole? role)async{
   try{
     if(role == null){
       throw Exception('User role is required for updating email verification status');
      }
     await _database.child('user/${role.name}/$userId').update({
       'emailVerified': isVerified,
     });
     if (isVerified && _requiresEmailVerification(role)) {
       await _database
           .child('user/${role.name}/$userId')
           .update({'status': 'active'});
     }
    }catch(e){
     print('Error updating email verification status: $e');
     Fluttertoast.showToast(msg: 'Error updating email verification status');
     throw Exception('Failed to update email verification status');
    }
   }

  Future<UserLoginResponse> signInWithEmailAndPassword(UserCredentials credentials) async {
    try {
      // Input validation
      if (credentials.email.isEmpty || credentials.password.isEmpty) {
        print('Login failed: Empty email or password');
        return UserLoginResponse.error(
          'Please provide both email and password',
          'invalid-input',
        );
      }

      print('Attempting Firebase auth...');
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: credentials.email.trim(),
        password: credentials.password,
      );
      print('Firebase auth successful, getting user data...');

      // Get user data
      final userData = await _getUserData(userCredential.user!.uid)
          .timeout(const Duration(seconds: 10));

      if (userData == null) {
        print('Login failed: User profile not found');
        await _auth.signOut();
        return UserLoginResponse.error(
          'User profile not found. Please contact support.',
          'profile-not-found',
        );
      }

      // Email verification check
      if (_requiresEmailVerification(userData.role) && !userData.emailVerified) {
        print('Login failed: Email not verified for role ${userData.role}');
        return UserLoginResponse.error(
          'Please verify your email before logging in.',
          'email-not-verified',
        );
      }

     //Update status to active after email verification
    if (userData.emailVerified && userData.status == 'pending') {
    await updateEmailVerificationStatus(userData.uid, true, userData.role);
    }

    print('Login successful for role: ${userData.role}');
      return UserLoginResponse.success(userData, message: 'Login successful');

    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return _handleFirebaseAuthError(e);
    } on TimeoutException {
      print('Login failed: Timeout getting user data');
      return UserLoginResponse.error(
        'Connection timeout. Please try again.',
        'timeout',
      );
    } catch (e) {
      print('Unexpected error during login: ${e.toString()}');
      return UserLoginResponse.error(
        'An unexpected error occurred.',
        e.toString(),
      );
    }
  }
  // Enhanced registration with additional validation
  Future<UserLoginResponse> registerUser(RegisterUserData registerData) async {
    try {
      // Validate registration data
      if (!_isValidRegistrationData(registerData)) {
        return UserLoginResponse.error(
          'Please fill in all required fields correctly.',
          'invalid-registration-data',
        );
      }

      // Check if role is allowed for registration
      if (!_isRoleAllowedForRegistration(registerData.role)) {
        return UserLoginResponse.error(
          'This role requires admin approval.',
          'role-not-allowed',
        );
      }

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: registerData.email.trim(),
        password: registerData.password,
      );

      // Send email verification for sensitive roles
      if (_requiresEmailVerification(registerData.role)) {
        await userCredential.user!.sendEmailVerification();
      }



      // Inside AuthService.registerUser
      final userData = UserData(
        uid: userCredential.user!.uid,
        email: registerData.email.trim(),
        role: registerData.role, // Uses the passed role
        emailVerified: userCredential.user!.emailVerified,
        provider: 'password',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        status: _requiresEmailVerification(registerData.role) ? 'pending' : 'active',
      );

        // Check email verification status during registration
      if (_requiresEmailVerification(userData.role) && !userData.emailVerified) {
        return UserLoginResponse.error(
          'Please verify your email before logging in.',
          'email-not-verified',
        );
      }

      await _createUserInDatabase(userData);

      return UserLoginResponse.success(
        userData,
        message: _requiresEmailVerification(registerData.role)
            ? 'Please check your email to verify your account.'
            : 'Registration successful!',
      );

    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return UserLoginResponse.error(
        'Registration failed. Please try again.',
        e.toString(),
      );
    }
  }

  // Enhanced Google Sign In with role validation
  Future<UserLoginResponse> signInWithGoogle(UserRole role) async {
    try {
      // Check if role is allowed for Google Sign In
      if (!_isRoleAllowedForGoogleSignIn(role)) {
        return UserLoginResponse.error(
          'This role requires email registration.',
          'role-not-allowed-google',
        );
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return UserLoginResponse.error(
          'Google sign-in was cancelled',
          'sign-in-cancelled',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check existing user data
      UserData? userData = await _getUserData(userCredential.user!.uid);

      if (userData != null && userData.role != role) {
        // User exists but trying to sign in with different role
        await _auth.signOut();
        return UserLoginResponse.error(
          'Account exists with a different role. Please use email sign in.',
          'role-mismatch',
        );
      }

      if (userData == null) {
        // Create new user
        userData = UserData(
          uid: userCredential.user!.uid,
          email: googleUser.email,
          role: role,
          emailVerified: userCredential.user!.emailVerified,
          provider: 'google.com',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          status: 'active', // Google accounts are pre-verified
        );
        await _createUserInDatabase(userData);
      } else {
        await _updateUserLastLogin(userData);
      }

      return UserLoginResponse.success(userData, message: 'Sign in successful!');
    } catch (e) {
      return UserLoginResponse.error(
        'Failed to sign in with Google',
        e.toString(),
      );
    }
  }

  // Helper method to create user in database
  Future<void> _createUserInDatabase(UserData userData) async {
    await _database
        .child('user/${userData.role.name}/${userData.uid}')
        .set(userData.toJson());
  }

  // Helper method to update last login
  Future<void> _updateUserLastLogin(UserData userData) async {
    await _database
        .child('user/${userData.role.name}/${userData.uid}')
        .update({
      'lastLogin': DateTime.now().toIso8601String(),
    });
  }

  // Get user data from database with enhanced search
  Future<UserData?> _getUserData(String uid) async {
    for (UserRole role in UserRole.values) {
      final snapshot = await _database
          .child('user/${role.name}/$uid')
          .get();

      if (snapshot.exists) {
        return UserData.fromJson(
          uid,
          role,
          Map<String, dynamic>.from(snapshot.value as Map),
        );
      }
    }
    return null;
  }

  // Enhanced sign out with provider check
  Future<void> signOut() async {
    if (_auth.currentUser?.providerData
        .any((element) => element.providerId == 'google.com') ?? false) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  // Get current authenticated user data
  Future<UserData?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _getUserData(user.uid);
    }
    return null;
  }

  // Stream of auth state changes with user data
  Stream<UserData?> get userDataStream => _auth.authStateChanges().asyncMap(
          (User? user) async {
        if (user == null) return null;
        return await _getUserData(user.uid);
      }
  );

  // Validation helpers
  bool _isValidRegistrationData(RegisterUserData data) {
    return data.email.isNotEmpty &&
        data.password.isNotEmpty &&
        data.password.length >= 8;
  }

  bool _requiresEmailVerification(UserRole role) {
   // return [UserRole.contractor, UserRole.architect, UserRole.vendor]
     return []
        .contains(role);
  }

  bool _isRoleAllowedForRegistration(UserRole role) {
    return role != UserRole.admin; // Admin role requires special handling
  }

  bool _isRoleAllowedForGoogleSignIn(UserRole role) {
    return true;
  }
  // Enhanced Firebase Auth error handler
  UserLoginResponse _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UserLoginResponse.error(
          'No account found with this email.',
          e.code,
        );
      case 'wrong-password':
        return UserLoginResponse.error(
          'Invalid password. Please try again.',
          e.code,
        );
      case 'email-already-in-use':
        return UserLoginResponse.error(
          'This email is already registered.',
          e.code,
        );
      case 'invalid-email':
        return UserLoginResponse.error(
          'Please enter a valid email address.',
          e.code,
        );
      case 'network-request-failed':
        return UserLoginResponse.error(
          'Network issue. Please check your connection.',
          e.code,
        );
      default:
        return UserLoginResponse.error(
          'Authentication error: ${e.message}',
          e.code,
        );
    }
  }
}

*/
///////////////////////////////////
/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final DatabaseReference _database;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    DatabaseReference? database,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _database = database ?? FirebaseDatabase.instance.ref();

  // Add the new email verification status update method
  Future<void> updateEmailVerificationStatus(String userId, bool isVerified, UserRole? role) async {
    try {
      if (role == null) {
        throw Exception('User role is required for updating email verification status');
      }
      await _database.child('user/${role.name}/$userId').update({
        'emailVerified': isVerified,
      });
      if (isVerified && _requiresEmailVerification(role)) {
        await _database
            .child('user/${role.name}/$userId')
            .update({'status': 'active'});
      }
    } catch (e) {
      print('Error updating email verification status: $e');
      Fluttertoast.showToast(msg: 'Error updating email verification status');
      throw Exception('Failed to update email verification status');
    }
  }

  Future<UserLoginResponse> signInWithEmailAndPassword(UserCredentials credentials) async {
    try {
      if (credentials.email.isEmpty || credentials.password.isEmpty) {
        return UserLoginResponse.error(
          'Please provide both email and password',
          'invalid-input',
        );
      }

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: credentials.email.trim(),
        password: credentials.password,
      );

      final userData = await _getUserData(userCredential.user!.uid)
          .timeout(const Duration(seconds: 10));

      if (userData == null) {
        await _auth.signOut();
        return UserLoginResponse.error(
          'User profile not found. Please contact support.',
          'profile-not-found',
        );
      }

      if (_requiresEmailVerification(userData.role) && !userData.emailVerified) {
        return UserLoginResponse.error(
          'Please verify your email before logging in.',
          'email-not-verified',
        );
      }

      return UserLoginResponse.success(userData, message: 'Login successful');
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } on TimeoutException {
      return UserLoginResponse.error(
        'Connection timeout. Please try again.',
        'timeout',
      );
    } catch (e) {
      return UserLoginResponse.error(
        'An unexpected error occurred.',
        e.toString(),
      );
    }
  }

  // Enhanced registration with additional validation
  Future<UserLoginResponse> registerUser(RegisterUserData registerData) async {
    try {
      // Validate registration data
      if (!_isValidRegistrationData(registerData)) {
        return UserLoginResponse.error(
          'Please fill in all required fields correctly.',
          'invalid-registration-data',
        );
      }

      // Check if role is allowed for registration
      if (!_isRoleAllowedForRegistration(registerData.role)) {
        return UserLoginResponse.error(
          'This role requires admin approval.',
          'role-not-allowed',
        );
      }

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: registerData.email.trim(),
        password: registerData.password,
      );

      // Send email verification for sensitive roles
      if (_requiresEmailVerification(registerData.role)) {
        await userCredential.user!.sendEmailVerification();
      }

      final userData = UserData(
        uid: userCredential.user!.uid,
        email: registerData.email.trim(),
        role: registerData.role, // Uses the passed role
        emailVerified: userCredential.user!.emailVerified,
        provider: 'password',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        status: _requiresEmailVerification(registerData.role) ? 'pending' : 'active',
      );

      // Check email verification status during registration
      if (_requiresEmailVerification(userData.role) && !userData.emailVerified) {
        return UserLoginResponse.error(
          'Please verify your email before logging in.',
          'email-not-verified',
        );
      }

      await _createUserInDatabase(userData);

      return UserLoginResponse.success(
        userData,
        message: _requiresEmailVerification(registerData.role)
            ? 'Please check your email to verify your account.'
            : 'Registration successful!',
      );

    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return UserLoginResponse.error(
        'Registration failed. Please try again.',
        e.toString(),
      );
    }
  }

  // Enhanced Google Sign In with role validation
  Future<UserLoginResponse> signInWithGoogle(UserRole role) async {
    try {
      // Check if role is allowed for Google Sign In
      if (!_isRoleAllowedForGoogleSignIn(role)) {
        return UserLoginResponse.error(
          'This role requires email registration.',
          'role-not-allowed-google',
        );
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return UserLoginResponse.error(
          'Google sign-in was cancelled',
          'sign-in-cancelled',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check existing user data
      UserData? userData = await _getUserData(userCredential.user!.uid);

      if (userData != null && userData.role != role) {
        // User exists but trying to sign in with different role
        await _auth.signOut();
        return UserLoginResponse.error(
          'Account exists with a different role. Please use email sign in.',
          'role-mismatch',
        );
      }

      if (userData == null) {
        // Create new user
        userData = UserData(
          uid: userCredential.user!.uid,
          email: googleUser.email,
          role: role,
          emailVerified: userCredential.user!.emailVerified,
          provider: 'google.com',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          status: 'active', // Google accounts are pre-verified
        );
        await _createUserInDatabase(userData);
      } else {
        await _updateUserLastLogin(userData);
      }

      return UserLoginResponse.success(userData, message: 'Sign in successful!');
    } catch (e) {
      return UserLoginResponse.error(
        'Failed to sign in with Google',
        e.toString(),
      );
    }
  }

  // Helper method to create user in database
  Future<void> _createUserInDatabase(UserData userData) async {
    await _database
        .child('user/${userData.role.name}/${userData.uid}')
        .set(userData.toJson());
  }

  // Helper method to update last login
  Future<void> _updateUserLastLogin(UserData userData) async {
    await _database
        .child('user/${userData.role.name}/${userData.uid}')
        .update({
      'lastLogin': DateTime.now().toIso8601String(),
    });
  }

  // Get user data from database with enhanced search
  Future<UserData?> _getUserData(String uid) async {
    for (UserRole role in UserRole.values) {
      final snapshot = await _database
          .child('user/${role.name}/$uid')
          .get();

      if (snapshot.exists) {
        final json = Map<String, dynamic>.from(snapshot.value as Map);
        return UserData.fromJson(json, uid);
      }
    }
    return null;
  }

  // Enhanced sign out with provider check
  Future<void> signOut() async {
    if (_auth.currentUser?.providerData
        .any((element) => element.providerId == 'google.com') ?? false) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  // Get current authenticated user data
  Future<UserData?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _getUserData(user.uid);
    }
    return null;
  }

  // Stream of auth state changes with user data
  Stream<UserData?> get userDataStream => _auth.authStateChanges().asyncMap(
          (User? user) async {
        if (user == null) return null;
        return await _getUserData(user.uid);
      }
  );

  // Validation helpers
  bool _isValidRegistrationData(RegisterUserData data) {
    return data.email.isNotEmpty &&
        data.password.isNotEmpty &&
        data.password.length >= 8;
  }

  bool _requiresEmailVerification(UserRole role) {
    return [UserRole.contractor, UserRole.architect, UserRole.vendor]
        .contains(role);
  }

  bool _isRoleAllowedForRegistration(UserRole role) {
    return role != UserRole.admin; // Admin role requires special handling
  }

  bool _isRoleAllowedForGoogleSignIn(UserRole role) {
    return true;
  }

  // Enhanced Firebase Auth error handler
  UserLoginResponse _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UserLoginResponse.error(
          'No account found with this email.',
          e.code,
        );
      case 'wrong-password':
        return UserLoginResponse.error(
          'Invalid password. Please try again.',
          e.code,
        );
      case 'email-already-in-use':
        return UserLoginResponse.error(
          'This email is already registered.',
          e.code,
        );
      case 'invalid-email':
        return UserLoginResponse.error(
          'Please enter a valid email address.',
          e.code,
        );
      case 'network-request-failed':
        return UserLoginResponse.error(
          'Network issue. Please check your connection.',
          e.code,
        );
      default:
        return UserLoginResponse.error(
          'Authentication error: ${e.message}',
          e.code,
        );
    }
  }
}

*/


/////////////////////////////////////

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final DatabaseReference _database;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    DatabaseReference? database,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _database = database ?? FirebaseDatabase.instance.ref();

  // Add the new email verification status update method
  Future<void> updateEmailVerificationStatus(String userId, bool isVerified, UserRole? role) async {
    try {
      if (role == null) {
        throw Exception('User role is required for updating email verification status');
      }
      // Update under user/<role>/<uid>
      await _database.child('user/${role.name}/$userId').update({
        'emailVerified': isVerified,
      });
      if (isVerified && _requiresEmailVerification(role)) {
        await _database.child('user/${role.name}/$userId').update({'status': 'active'});
      }
    } catch (e) {
      print('Error updating email verification status: $e');
      Fluttertoast.showToast(msg: 'Error updating email verification status');
      throw Exception('Failed to update email verification status');
    }
  }
/*
  Future<UserLoginResponse> signInWithEmailAndPassword(UserCredentials credentials) async {
    try {
      if (credentials.email.isEmpty || credentials.password.isEmpty) {
        return UserLoginResponse.error(
          'Please provide both email and password',
          'invalid-input',
        );
      }

      int retryCount = 0;
      const maxRetries = 3;
      while (retryCount < maxRetries) {
        try {
          final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: credentials.email.trim(),
            password: credentials.password,
          ).timeout(const Duration(seconds: 15));

          final userData = await _getUserData(userCredential.user!.uid)
              .timeout(const Duration(seconds: 15));

          if (userData == null) {
            await _auth.signOut();
            return UserLoginResponse.error(
              'User profile not found. Please contact support or sign up.',
              'profile-not-found',
            );
          }

          if (_requiresEmailVerification(userData.role) && !userData.emailVerified) {
            return UserLoginResponse.error(
              'Please verify your email before logging in.',
              'email-not-verified',
            );
          }

          return UserLoginResponse.success(userData, message: 'Login successful');
        } on TimeoutException {
          retryCount++;
          if (retryCount == maxRetries) {
            return UserLoginResponse.error(
              'Connection timeout after retries. Please check your network.',
              'timeout',
            );
          }
          await Future.delayed(const Duration(seconds: 2));
        } on SocketException catch (e) {
          retryCount++;
          if (retryCount == maxRetries) {
            return UserLoginResponse.error(
              'Network error. Please check your connection.',
              'network-error',
            );
          }
          await Future.delayed(const Duration(seconds: 2));
        } on FirebaseAuthException catch (e) {
          return _handleFirebaseAuthError(e);
        }
      }
      return UserLoginResponse.error(
        'Unexpected error during login.',
        'unknown',
      );
    } catch (e) {
      return UserLoginResponse.error(
        'An unexpected error occurred: $e',
        e.toString(),
      );
    }
  }*/
  // In AuthService.dart, update signInWithEmailAndPassword
  /*Future<UserLoginResponse> signInWithEmailAndPassword(UserCredentials credentials) async {
    try {
      if (credentials.email.isEmpty || credentials.password.isEmpty) {
        return UserLoginResponse.error(
          'Please provide both email and password',
          'invalid-input',
        );
      }

      print('Attempting sign-in with email: ${credentials.email}, password: [hidden]');

      int retryCount = 0;
      const maxRetries = 3;
      while (retryCount < maxRetries) {
        try {
          final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: credentials.email.trim().toLowerCase(), // Ensure case-insensitive email
            password: credentials.password,
          ).timeout(const Duration(seconds: 15));

          final user = userCredential.user;
          if (user == null) {
            await _auth.signOut();
            return UserLoginResponse.error(
              'User not found or authentication failed.',
              'auth-failure',
            );
          }

          final userData = await _getUserData(user.uid).timeout(const Duration(seconds: 15));

          if (userData == null) {
            await _auth.signOut();
            return UserLoginResponse.error(
              'User profile not found. Please contact support or sign up.',
              'profile-not-found',
            );
          }

          print('User signed in successfully: email=${userData.email}, role=${userData.role}, emailVerified=${userData.emailVerified}, uid=${userData.uid}');

          // Skip email verification for admin role
          if (_requiresEmailVerification(userData.role) && userData.role != UserRole.admin && !userData.emailVerified) {
            return UserLoginResponse.error(
              'Please verify your email before logging in.',
              'email-not-verified',
            );
          }

          return UserLoginResponse.success(userData, message: 'Login successful');
        } on TimeoutException {
          retryCount++;
          if (retryCount == maxRetries) {
            return UserLoginResponse.error(
              'Connection timeout after retries. Please check your network.',
              'timeout',
            );
          }
          print('Retry attempt $retryCount for sign-in due to timeout');
          await Future.delayed(const Duration(seconds: 2));
        } on SocketException catch (e) {
          retryCount++;
          if (retryCount == maxRetries) {
            return UserLoginResponse.error(
              'Network error. Please check your connection.',
              'network-error',
            );
          }
          print('Retry attempt $retryCount for sign-in due to network error: $e');
          await Future.delayed(const Duration(seconds: 2));
        } on FirebaseAuthException catch (e) {
          print('FirebaseAuthException during sign-in: ${e.code}, ${e.message}');
          return _handleFirebaseAuthError(e);
        }
      }
      return UserLoginResponse.error(
        'Unexpected error during login.',
        'unknown',
      );
    } catch (e) {
      print('Unexpected error during sign-in: $e');
      return UserLoginResponse.error(
        'An unexpected error occurred: $e',
        e.toString(),
      );
    }
  }
*/


  // In AuthService.dart, update signInWithEmailAndPassword
  Future<UserLoginResponse> signInWithEmailAndPassword(UserCredentials credentials) async {
    try {
      if (credentials.email.isEmpty || credentials.password.isEmpty) {
        return UserLoginResponse.error(
          'Please provide both email and password',
          'invalid-input',
        );
      }

      print('Attempting sign-in with email: ${credentials.email}, password: [hidden]');

      int retryCount = 0;
      const maxRetries = 3;
      while (retryCount < maxRetries) {
        try {
          final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: credentials.email.trim().toLowerCase(), // Ensure case-insensitive email
            password: credentials.password,
          ).timeout(const Duration(seconds: 15));

          final user = userCredential.user;
          if (user == null) {
            await _auth.signOut();
            return UserLoginResponse.error(
              'User not found or authentication failed.',
              'auth-failure',
            );
          }

          final userData = await _getUserData(user.uid).timeout(const Duration(seconds: 15));

          if (userData == null) {
            await _auth.signOut();
            return UserLoginResponse.error(
              'User profile not found. Please contact support or sign up.',
              'profile-not-found',
            );
          }

          print('User signed in successfully: email=${userData.email}, role=${userData.role}, emailVerified=${userData.emailVerified}, uid=${userData.uid}');

          // Skip email verification for admin role
          if (_requiresEmailVerification(userData.role) && userData.role != UserRole.admin && !userData.emailVerified) {
            return UserLoginResponse.error(
              'Please verify your email before logging in.',
              'email-not-verified',
            );
          }

          return UserLoginResponse.success(userData, message: 'Login successful');
        } on TimeoutException {
          retryCount++;
          if (retryCount == maxRetries) {
            return UserLoginResponse.error(
              'Connection timeout after retries. Please check your network.',
              'timeout',
            );
          }
          print('Retry attempt $retryCount for sign-in due to timeout');
          await Future.delayed(const Duration(seconds: 2));
        } on SocketException catch (e) {
          retryCount++;
          if (retryCount == maxRetries) {
            return UserLoginResponse.error(
              'Network error. Please check your connection.',
              'network-error',
            );
          }
          print('Retry attempt $retryCount for sign-in due to network error: $e');
          await Future.delayed(const Duration(seconds: 2));
        } on FirebaseAuthException catch (e) {
          print('FirebaseAuthException during sign-in: ${e.code}, ${e.message}');
          if (e.code == 'wrong-password' || e.code == 'user-not-found') {
            return UserLoginResponse.error(
              'Invalid email or password.',
              e.code,
            );
          }
          return _handleFirebaseAuthError(e);
        }
      }
      return UserLoginResponse.error(
        'Unexpected error during login.',
        'unknown',
      );
    } catch (e) {
      print('Unexpected error during sign-in: $e');
      return UserLoginResponse.error(
        'An unexpected error occurred: $e',
        e.toString(),
      );
    }
  }
  // Enhanced registration with role-specific storage
  Future<UserLoginResponse> registerUser(RegisterUserData registerData) async {
    try {
      if (!_isValidRegistrationData(registerData)) {
        return UserLoginResponse.error(
          'Please fill in all required fields correctly.',
          'invalid-registration-data',
        );
      }

      if (registerData.role == UserRole.admin) {
        return UserLoginResponse.error(
          'Admin registration is restricted. Contact support.',
          'admin-registration-restricted',
        );
      }

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: registerData.email.trim(),
        password: registerData.password,
      );

      final user = userCredential.user;
      if (user == null) {
        return UserLoginResponse.error(
          'Registration failed. User creation error.',
          'registration-failure',
        );
      }

      if (_requiresEmailVerification(registerData.role)) {
        await user.sendEmailVerification();
      }

      final userData = UserData(
        uid: user.uid,
        email: registerData.email.trim(),
        role: registerData.role,
        displayName: registerData.displayName,
        phoneNumber: registerData.phoneNumber,
        emailVerified: user.emailVerified,
        provider: 'password',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        status: _requiresEmailVerification(registerData.role) ? 'pending' : 'active',
      );

      // Store under user/<role>/<uid>
      await _createUserInDatabase(userData);

      return UserLoginResponse.success(
        userData,
        message: _requiresEmailVerification(registerData.role)
            ? 'Please check your email to verify your account.'
            : 'Registration successful!',
      );

    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return UserLoginResponse.error(
        'Registration failed. Please try again.',
        e.toString(),
      );
    }
  }

  // Enhanced Google Sign In with role-specific storage
  Future<UserLoginResponse> signInWithGoogle(UserRole role) async {
    try {
      if (role == UserRole.admin) {
        return UserLoginResponse.error(
          'Admin login requires email and password.',
          'admin-google-restricted',
        );
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return UserLoginResponse.error(
          'Google sign-in was cancelled',
          'sign-in-cancelled',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check existing user data under user/<role>/<uid>
      UserData? userData = await _getUserData(userCredential.user!.uid);

      if (userData != null && userData.role != role) {
        await _auth.signOut();
        return UserLoginResponse.error(
          'Account exists with a different role. Please use email sign in.',
          'role-mismatch',
        );
      }

      if (userData == null) {
        // Create new user under user/<role>/<uid>
        userData = UserData(
          uid: userCredential.user!.uid,
          email: googleUser.email,
          role: role,
          displayName: googleUser.displayName,
          photoURL: googleUser.photoUrl,
          emailVerified: true, // Google accounts are typically verified
          provider: 'google.com',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          status: 'active',
        );
        await _createUserInDatabase(userData);
      } else {
        await _updateUserLastLogin(userData);
      }

      return UserLoginResponse.success(userData, message: 'Sign in successful!');
    } catch (e) {
      return UserLoginResponse.error(
        'Failed to sign in with Google',
        e.toString(),
      );
    }
  }

  // Helper method to create user in database under user/<role>/<uid>
  Future<void> _createUserInDatabase(UserData userData) async {
    print('Creating user profile for UID ${userData.uid} with role ${userData.role}: ${userData.toJson()}');
    await _database.child('user/${userData.role.name}/${userData.uid}').set(userData.toJson());
  }

  // Helper method to update last login under user/<role>/<uid>
  Future<void> _updateUserLastLogin(UserData userData) async {
    await _database.child('user/${userData.role.name}/${userData.uid}').update({
      'lastLogin': DateTime.now().toIso8601String(),
    });
  }

  // Get user data from database, searching under user/<role>/<uid> - Now asynchronous
  // In AuthService.dart, update _getUserData
  Future<UserData?> _getUserData(String uid) async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    // Explicitly check for admin role first for buildbuddyadmin@gmail.com
    if (firebaseUser.email == 'buildbuddyadmin@gmail.com') {
      final snapshot = await _database.child('user/admin/$uid').get();
      if (snapshot.exists) {
        final json = Map<String, dynamic>.from(snapshot.value as Map);
        print('Admin user data found for UID $uid: $json');
        return await UserData.fromJson(json, uid); // Await the async fromJson
      }
    }

    // Try to determine role from existing profile or default to homeowner
    UserRole? role;
    for (var r in UserRole.values) {
      final snapshot = await _database.child('user/${r.name}/$uid').get();
      if (snapshot.exists) {
        final json = Map<String, dynamic>.from(snapshot.value as Map);
        final roleString = json['role'] as String?;
        if (roleString != null && roleString.isNotEmpty) {
          try {
            role = UserRole.values.firstWhere((r) => r.name == roleString);
          } catch (e) {
            print('Invalid role found in JSON for UID $uid: $roleString, defaulting to ${r.name}');
            role = r; // Use the role from the path if JSON role is invalid
          }
        } else {
          print('No role field found for UID $uid under ${r.name}, using path role: ${r.name}');
          role = r; // Use the role from the path if no role field exists
        }
        break;
      }
    }

    if (role == null) {
      print('No role found for UID $uid in any role path, defaulting to homeowner');
      role = UserRole.homeowner; // Default role if not found
    }

    final snapshot = await _database.child('user/${role.name}/$uid').get();

    if (snapshot.exists) {
      final json = Map<String, dynamic>.from(snapshot.value as Map);
      print('User data found for UID $uid under ${role.name}: $json');
      return await UserData.fromJson(json, uid); // Await the async fromJson
    }
    print('No user data found for UID $uid under ${role.name}');
    return null;
  }
/*
  Future<UserData?> _getUserData(String uid) async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    // Try to determine role from existing profile or default to homeowner
    UserRole? role;
    for (var r in UserRole.values) {
      final snapshot = await _database.child('user/${r.name}/$uid').get();
      if (snapshot.exists) {
        final json = Map<String, dynamic>.from(snapshot.value as Map);
        final roleString = json['role'] as String?;
        if (roleString != null && roleString.isNotEmpty) {
          try {
            role = UserRole.values.firstWhere((r) => r.name == roleString);
          } catch (e) {
            print('Invalid role found in JSON for UID $uid: $roleString, defaulting to ${r.name}');
            role = r; // Use the role from the path if JSON role is invalid
          }
        } else {
          print('No role field found for UID $uid under ${r.name}, using path role: ${r.name}');
          role = r; // Use the role from the path if no role field exists
        }
        break;
      }
    }

    if (role == null) {
      print('No role found for UID $uid in any role path, defaulting to homeowner');
      role = UserRole.homeowner; // Default role if not found
    }

    final snapshot = await _database.child('user/${role.name}/$uid').get();

    if (snapshot.exists) {
      final json = Map<String, dynamic>.from(snapshot.value as Map);
      print('User data found for UID $uid under ${role.name}: $json');
      return await UserData.fromJson(json, uid); // Await the async fromJson
    }
    print('No user data found for UID $uid under ${role.name}');
    return null;
  }
*/

  // Enhanced sign out with provider check
  Future<void> signOut() async {
    if (_auth.currentUser?.providerData
        .any((element) => element.providerId == 'google.com') ?? false) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  // Get current authenticated user data
  Future<UserData?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _getUserData(user.uid);
    }
    return null;
  }

  // Stream of auth state changes with user data
  Stream<UserData?> get userDataStream => _auth.authStateChanges().asyncMap(
        (User? user) async {
      if (user == null) return null;
      return await _getUserData(user.uid);
    },
  );

  // Validation helpers
  bool _isValidRegistrationData(RegisterUserData data) {
    return data.email.isNotEmpty &&
        data.password.isNotEmpty &&
        data.password.length >= 8;
  }

  bool _requiresEmailVerification(UserRole role) {
    return [UserRole.contractor, UserRole.architect, UserRole.vendor]
        .contains(role);
  }

  bool _isRoleAllowedForRegistration(UserRole role) {
    return role != UserRole.admin; // Admin role requires special handling
  }

  bool _isRoleAllowedForGoogleSignIn(UserRole role) {
    return role != UserRole.admin; // Restrict admin to email/password
  }

  // Enhanced Firebase Auth error handler
  UserLoginResponse _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UserLoginResponse.error(
          'No account found with this email.',
          e.code,
        );
      case 'wrong-password':
        return UserLoginResponse.error(
          'Invalid password. Please try again.',
          e.code,
        );
      case 'email-already-in-use':
        return UserLoginResponse.error(
          'This email is already registered.',
          e.code,
        );
      case 'invalid-email':
        return UserLoginResponse.error(
          'Please enter a valid email address.',
          e.code,
        );
      case 'network-request-failed':
        return UserLoginResponse.error(
          'Network issue. Please check your connection.',
          e.code,
        );
      default:
        return UserLoginResponse.error(
          'Authentication error: ${e.message}',
          e.code,
        );
    }
  }
}











