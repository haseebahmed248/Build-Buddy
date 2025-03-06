
//Runnable code
/*
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:buildbuddyfyp/Services/auth/authService.dart';
import 'package:buildbuddyfyp/Models/userModels.dart';
import 'package:flutter/foundation.dart';

class UserController {
  final AuthService _authService = AuthService();
  UserData? _currentUser;
  final _userStateController = StreamController<UserData?>.broadcast();

  // Expose user state as a stream
  Stream<UserData?> get userStream => _userStateController.stream;
  UserData? get currentUser => _currentUser;

  // Initialize controller and set up auth state listener
  void init() {
    // Listen to auth state changes
    _authService.userDataStream.listen((userData) {
      _currentUser = userData;
      _userStateController.add(userData);
    }, onError: (error) {
      if (kDebugMode) {
        print('Error in auth state stream: $error');
      }
      _userStateController.addError(error);
    });
  }

  // Login with email and password
  Future<UserLoginResponse> login(UserCredentials credentials) async {
    try {
      if (!_isValidEmail(credentials.email)) {
        return UserLoginResponse.error(
          'Invalid email format',
          'Please enter a valid email address',
        );
      }

      final response = await _authService.signInWithEmailAndPassword(credentials);
      if (response.success) {
        _currentUser = response.userData;
        _userStateController.add(_currentUser);
      }
      return response;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return UserLoginResponse.error(
        'Authentication Error',
        'An unexpected error occurred during login: ${e.toString()}',
      );
    }
  }

  // Register new user with validation
  Future<UserLoginResponse> register(RegisterUserData registerData) async {
    try {
      if (!_isValidEmail(registerData.email)) {
        return UserLoginResponse.error(
          'Invalid email format',
          'Please enter a valid email address',
        );
      }

      if (!_isValidPassword(registerData.password)) {
        return UserLoginResponse.error(
          'Invalid password',
          'Password must be at least 8 characters long and contain at least one number',
        );
      }

      final response = await _authService.registerUser(registerData);
      if (response.success) {
        _currentUser = response.userData;
        _userStateController.add(_currentUser);
      }
      return response;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return UserLoginResponse.error(
        'Registration Error',
        'An unexpected error occurred during registration: ${e.toString()}',
      );
    }
  }

  // Google Sign In with enhanced error handling
  Future<UserLoginResponse> signInWithGoogle(UserRole role) async {
    try {
      final response = await _authService.signInWithGoogle(role);
      if (response.success) {
        _currentUser = response.userData;
        _userStateController.add(_currentUser);
      }
      return response;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return UserLoginResponse.error(
        'Google Sign-In Error',
        'An unexpected error occurred during Google sign-in: ${e.toString()}',
      );
    }
  }

  // Sign out with cleanup
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _userStateController.add(null);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Enhanced password reset with validation
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Please enter a valid email address',
          'error': 'invalid-email-format'
        };
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent successfully'
      };
    } on FirebaseAuthException catch (e) {
      return _handlePasswordResetError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString()
      };
    }
  }

  // Load current user data with timeout
  Future<UserData?> loadCurrentUser({int timeoutSeconds = 10}) async {
    try {
      _currentUser = await _authService.getCurrentUserData()
          .timeout(Duration(seconds: timeoutSeconds));
      _userStateController.add(_currentUser);
      return _currentUser;
    } on TimeoutException {
      throw Exception('Failed to load user data: Request timed out');
    } catch (e) {
      throw Exception('Failed to load user data: ${e.toString()}');
    }
  }

  // Helper methods for validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 && RegExp(r'[0-9]').hasMatch(password);
  }

  // Firebase Auth error handler
  UserLoginResponse _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UserLoginResponse.error(
          'User Not Found',
          'No user found with this email address',
        );
      case 'wrong-password':
        return UserLoginResponse.error(
          'Invalid Password',
          'The password is invalid for this email',
        );
      case 'email-already-in-use':
        return UserLoginResponse.error(
          'Email In Use',
          'This email address is already registered',
        );
      case 'invalid-email':
        return UserLoginResponse.error(
          'Invalid Email',
          'Please enter a valid email address',
        );
      case 'weak-password':
        return UserLoginResponse.error(
          'Weak Password',
          'Please choose a stronger password',
        );
      case 'operation-not-allowed':
        return UserLoginResponse.error(
          'Operation Not Allowed',
          'This authentication method is not enabled',
        );
      default:
        return UserLoginResponse.error(
          'Authentication Error',
          'An error occurred: ${e.message}',
        );
    }
  }

  // Password reset error handler
  Map<String, dynamic> _handlePasswordResetError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-not-found':
        message = 'No user found with this email address.';
        break;
      case 'too-many-requests':
        message = 'Too many password reset attempts. Please try again later.';
        break;
      default:
        message = 'An error occurred while sending password reset email.';
    }
    return {
      'success': false,
      'message': message,
      'error': e.code
    };
  }

  // Cleanup resources
  void dispose() {
    _userStateController.close();
  }
}

// Role-based access control extension
extension UserRoleExtension on UserRole {
  bool get isHomeowner => this == UserRole.homeowner;
  bool get isContractor => this == UserRole.contractor;
  bool get isArchitect => this == UserRole.architect;
  bool get isVendor => this == UserRole.vendor;
  bool get isAdmin => this == UserRole.admin;

  // Helper method to check if role has access to specific feature
  bool hasAccess(List<UserRole> allowedRoles) => allowedRoles.contains(this);
}
*/













/////////
/*

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart'; // Corrected import for GetX
import 'package:buildbuddy/Services/auth/authService.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'package:flutter/material.dart';
import '../Views/DashBoard/Admin.dart';
import '../Views/DashBoard/Architect.dart';
import '../Views/DashBoard/Constructor.dart';
import '../Views/DashBoard/HomeOwner.dart';
import '../Views/DashBoard/Vendor.dart';
import 'package:provider/provider.dart'; // Import for ProjectController
import 'projectController.dart'; // Adjust import path

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable values
  final Rx<UserData?> currentUser = Rx<UserData?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _authService.userDataStream.listen((userData) {
      currentUser.value = userData;
      if (userData != null) {
        _updateProjectController(userData.uid, userData.role);
        _navigateBasedOnRole(userData.role);
      }
    });
  }

  Future<UserData?> getCurrentUserData() async {
    return await _authService.getCurrentUserData();
  }

  // Updated email verification status method to match AuthService
  Future<void> updateEmailVerificationStatus() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null && currentUser.value?.role != null) {
        await user.reload();
        await _authService.updateEmailVerificationStatus(
          user.uid,
          user.emailVerified,
          currentUser.value?.role,
        );

        if (currentUser.value != null) {
          currentUser.value = currentUser.value!.copyWith(
            emailVerified: user.emailVerified,
          );
        }

        if (user.emailVerified) {
          Get.snackbar(
            'Email Verified',
            'Your email has been verified',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to update email verification status';
      Get.snackbar(
        'Error',
        'Failed to update email verification status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Registration
  Future<bool> registerUser({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final registerData = RegisterUserData(
        email: email,
        password: password,
        role: role,
      );

      final response = await _authService.registerUser(registerData);
      print('Registration response: $response');

      if (response.success) {
        currentUser.value = response.userData;
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        if (currentUser.value != null) {
          _updateProjectController(currentUser.value!.uid, currentUser.value!.role);
          _navigateBasedOnRole(currentUser.value!.role);
        }
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Registration failed';
      print('Registration error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  */
/*Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credentials = UserCredentials(
        email: email,
        password: password,
      );

      final response = await _authService.signInWithEmailAndPassword(credentials);
      print('Sign-in response: $response');

      if (response.success) {
        currentUser.value = response.userData;
        if (currentUser.value == null) {
          errorMessage.value = 'User profile not found. Please sign up or contact support.';
          Get.snackbar(
            'Error',
            'User profile not found. Please sign up or contact support.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          await _auth.signOut();
          return false;
        }
        _updateProjectController(currentUser.value!.uid, currentUser.value!.role);
        _navigateBasedOnRole(currentUser.value!.role);
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('Sign-in error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }*//*

// In AuthController.dart, update signInWithEmail
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('Attempting sign-in with email: $email, password: [hidden]');

      final credentials = UserCredentials(
        email: email,
        password: password,
      );

      final response = await _authService.signInWithEmailAndPassword(credentials);
      print('Sign-in response: $response');

      if (response.success) {
        currentUser.value = response.userData;
        if (currentUser.value == null) {
          errorMessage.value = 'User profile not found. Please sign up or contact support.';
          Get.snackbar(
            'Error',
            'User profile not found. Please sign up or contact support.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          await _auth.signOut();
          return false;
        }
        print('User signed in: email=${currentUser.value?.email}, role=${currentUser.value?.role}, emailVerified=${currentUser.value?.emailVerified}');
        _updateProjectController(currentUser.value!.uid, currentUser.value!.role);
        _navigateBasedOnRole(currentUser.value!.role);
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('Sign-in error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  Future<bool> signInWithGoogle(UserRole role) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.signInWithGoogle(role);

      if (response.success) {
        currentUser.value = response.userData;
        if (currentUser.value != null) {
          _updateProjectController(currentUser.value!.uid, currentUser.value!.role);
          _navigateBasedOnRole(currentUser.value!.role);
        }
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Google sign in failed';
      print('Google sign-in error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _updateProjectController(String userId, UserRole role) {
    print('Updating ProjectController for userId: $userId, role: ${role.name}');
    final projectController = Provider.of<ProjectController>(Get.context!, listen: false);
    projectController.updateUserType(role.name); // Use role.name as userType
    projectController.loadProjects(); // Reload projects with the new role
  }

  void _navigateBasedOnRole(UserRole? role) {
    if (role == null) {
      Get.snackbar(
        'Error',
        'Role is null. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Widget? dashboard;
    try {
      print('Navigating to dashboard for role: ${role.name}');
      switch (role) {
        case UserRole.homeowner:
          dashboard = const HomeOwnerDashboard();
          break;
        case UserRole.contractor:
          dashboard = ContractorDashboard();
          break;
        case UserRole.architect:
          dashboard = ArchitectDashboard();
          break;
        case UserRole.vendor:
          dashboard = VendorDashboard();
          break;
        case UserRole.admin:
          dashboard = AdminDashboard();
          break;
      }

      if (dashboard != null) {
        Get.offAll(
              () => dashboard!,
          transition: Transition.fade,
          duration: const Duration(milliseconds: 500),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Navigation Error',
        'Error navigating to dashboard. Please try again: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      currentUser.value = null;
      Get.offAllNamed('/stakeholder');
    } catch (e) {
      errorMessage.value = 'Sign out failed';
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkCurrentUser() async {
    try {
      isLoading.value = true;
      final userData = await _authService.getCurrentUserData();
      currentUser.value = userData;
      if (userData != null) {
        _updateProjectController(userData.uid, userData.role);
        _navigateBasedOnRole(userData.role);
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch user data';
    } finally {
      isLoading.value = false;
    }
  }

  bool get isAuthenticated => currentUser.value != null;
  bool get isEmailVerified => currentUser.value?.emailVerified ?? false;
  bool get requiresEmailVerification =>
      currentUser.value != null &&
          [UserRole.contractor, UserRole.architect, UserRole.vendor]
              .contains(currentUser.value!.role);

  void clearError() {
    errorMessage.value = '';
  }
}
*/

//////












/*

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:buildbuddyfyp/Services/auth/authService.dart';
import 'package:buildbuddyfyp/Models/userModels.dart';
import 'package:flutter/material.dart';

import '../Views/DashBoard/Admin.dart';
import '../Views/DashBoard/Architect.dart';
import '../Views/DashBoard/Constructor.dart';
import '../Views/DashBoard/HomeOwner.dart';
import '../Views/DashBoard/Vendor.dart';



class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable values
  final Rx<UserData?> currentUser = Rx<UserData?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _authService.userDataStream.listen((userData) {
      currentUser.value = userData;
    });
  }


// Add the new email verification status update method
Future<void> updateEmailVerificationStatus() async {
    try{
      isLoading.value = true;
      final user = _auth.currentUser;
      if(user != null){
        await user.reload();
       await _authService.updateEmailVerificationStatus(
         userId: user.uid,
         isEmailVerified:user.emailVerified,
         userRole: currentUser.value?.role,
       );
       if(currentUser.value != null){
         currentUser.value = currentUser.value!.copyWith(
           emailVerified: user.emailVerified,
         );
       }
       if(user.emailVerified){
         Get.snackbar(
           'Email Verified',
           'Your email has been verified',
           snackPosition: SnackPosition.BOTTOM,
           backgroundColor: Colors.green,
           colorText: Colors.white,
         );
       }
      }
    }catch(e) {
      errorMessage.value = 'Failed to update email verification status';
      Get.snackbar(
        'Error',
        'Failed to update email verification status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }finally{
      isLoading.value = false;
    }
}



// Registration
  Future<bool> registerUser({
    required String email,
    required String password,
    // required String displayName,
    //required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final registerData = RegisterUserData(
        email: email,
        password: password,
        //  displayName: displayName,
        //phoneNumber: phoneNumber,
        role: role,
      );

      final response = await _authService.registerUser(registerData);

      if (response.success) {
        currentUser.value = response.userData;
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _navigateBasedOnRole(response.userData?.role);

        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Registration failed';
      return false;
    } finally {
      isLoading.value = false;
    }
  }





  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credentials = UserCredentials(
        email: email,
        password: password,
      );

      final response = await _authService.signInWithEmailAndPassword(credentials);

      if (response.success) {
        currentUser.value = response.userData;
        _navigateBasedOnRole(response.userData?.role);

        return true;
      } else {
        errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      return false;
    } finally {
      isLoading.value = false;
    }
  }



  Future<bool> signInWithGoogle(UserRole role) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Trigger Google Sign-In
      final response = await _authService.signInWithGoogle(role);

      if (response.success) {
        currentUser.value = response.userData;

        // After successful sign-in, the user is redirected based on their role
        if (currentUser.value != null) {
          _navigateBasedOnRole(currentUser.value!.role);
        }

        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Google sign in failed';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

// Enhanced navigation function
  void _navigateBasedOnRole(UserRole? role) {
    print("======= Navigation Debug =======");
    print("Attempting navigation with role: $role");

    if (role == null) {
      print("Error: Role is null");
      Get.snackbar(
        'Error',
        'Role is null. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print("Role enum value: ${role.toString()}");
    print("Role name: ${role.name}");

    Widget? dashboard;
    try {
      // Navigate to the appropriate dashboard based on the user's role
      switch (role) {
        case UserRole.homeowner:
          print("Creating HomeOwner Dashboard");
          dashboard = const HomeOwnerDashboard();
          break;
        case UserRole.contractor:
          print("Creating Contractor Dashboard");
          dashboard = ContractorDashboard();
          break;
        case UserRole.architect:
          print("Creating Architect Dashboard");
          dashboard = ArchitectDashboard();
          break;
        case UserRole.vendor:
          print("Creating Vendor Dashboard");
          dashboard = VendorDashboard();
          break;
        case UserRole.admin:
          print("Creating Admin Dashboard");
          dashboard = const AdminDashboard();
          break;
        default:
          print("Warning: Using default HomeOwner Dashboard");
          dashboard = const HomeOwnerDashboard();
      }

      if (dashboard != null) {
        print("Navigating to dashboard using Get.offAll()");
        Get.offAll(
              () => dashboard!,
          transition: Transition.fade,
          duration: const Duration(milliseconds: 500),
        );
        print("Navigation command executed");
      } else {
        print("Error: Dashboard widget is null");
        throw Exception("Dashboard widget is null");
      }
    } catch (e) {
      print("Error during navigation: $e");
      Get.snackbar(
        'Navigation Error',
        'Error navigating to dashboard. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    print("======= End Navigation Debug =======");
  }

// Add this check in your AuthController
  void verifyUserRole() {
    final user = currentUser.value;
    print("Current user: $user");
    print("User role: ${user?.role}");
    if (user?.role != null) {
      print("Role type: ${user?.role.runtimeType}");
    }
  }


  // Sign Out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      currentUser.value = null;
      Get.offAllNamed('/stakeholder'); // Navigate to login screen
    } catch (e) {
      errorMessage.value = 'Sign out failed';
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check Current User
  Future<void> checkCurrentUser() async {
    try {
      isLoading.value = true;
      final userData = await _authService.getCurrentUserData();
      currentUser.value = userData;
    } catch (e) {
      errorMessage.value = 'Failed to fetch user data';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper Methods
  bool get isAuthenticated => currentUser.value != null;

  bool get isEmailVerified =>
      currentUser.value?.emailVerified ?? false;

  bool get requiresEmailVerification =>
      currentUser.value != null &&
          [UserRole.contractor, UserRole.architect, UserRole.vendor]
              .contains(currentUser.value!.role);

  // Navigation Methods
  void goToHome() {
    if (currentUser.value != null) {
      switch (currentUser.value!.role) {
        case UserRole.homeowner:
          Get.offAllNamed('/homeowner-dashboard');
          break;
        case UserRole.contractor:
          Get.offAllNamed('/contractor-dashboard');
          break;
        case UserRole.architect:
          Get.offAllNamed('/architect-dashboard');
          break;
        case UserRole.vendor:
          Get.offAllNamed('/vendor-dashboard');
          break;
        case UserRole.admin:
          Get.offAllNamed('/admin-dashboard');
          break;
        default:
          Get.offAllNamed('/login');
      }
    }
  }

  // Reset Error Message
  void clearError() {
    errorMessage.value = '';
  }
}

*/

////////













import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Services/auth/authService.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Views/DashBoard/Admin.dart';
import '../Views/DashBoard/Architect.dart';
import '../Views/DashBoard/Constructor.dart';
import '../Views/DashBoard/HomeOwner.dart';
import '../Views/DashBoard/Vendor.dart';
import 'projectController.dart'; // Adjust import path

/// Manages authentication, user-related functionality, and user list for the BuildBuddy app.
/// Aligns with SRS 3.2.3 (Security), 3.2.1 (Performance), 3.2.2 (Usability), and 3.2.4 (Reliability).
class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Observable values
  final Rx<UserData?> currentUser = Rx<UserData?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<UserData> _users = <UserData>[].obs; // Observable list of all users

  List<UserData> get users => _users; // Getter for all users

  StreamSubscription? _authStateSubscription;
  StreamSubscription? _usersSubscription;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _authStateSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
    _startUsersListener(); // Start listening for users
  }

  /// Handles authentication state changes, updating the current user and notifying listeners.
  void _onAuthStateChanged(User? firebaseUser) async {
    isLoading.value = true;
    try {
      if (firebaseUser != null) {
        final snapshot = await _database.child('user').get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            String? userRole;
            data.forEach((role, users) {
              if (users is Map && users.containsKey(firebaseUser.uid)) {
                userRole = role;
              }
            });
            if (userRole != null) {
              final userData = await UserData.fromJson(
                  Map<String, dynamic>.from(data[userRole][firebaseUser.uid] as Map), firebaseUser.uid);
              currentUser.value = userData;
              _updateProjectController(userData.uid, userData.role);
              _navigateBasedOnRole(userData.role);
            }
          }
        }
      } else {
        currentUser.value = null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user data: $e';
      Get.snackbar(
        'Error',
        'Failed to load user data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Starts real-time listener for users, scoped to the user's role unless they are an admin.
  /// Ensures performance (SRS 3.2.1) and usability (SRS 3.2.2).
  void _startUsersListener() {
    // Wait until currentUser is set to determine the role
    ever(currentUser, (UserData? user) {
      _usersSubscription?.cancel(); // Cancel any existing subscription

      if (user == null) {
        _users.clear();
        return;
      }

      // Determine the path based on the user's role
      String path = 'user';
      if (user.role != UserRole.admin) {
        path = 'user/${user.role.name}';
      }

      _usersSubscription = _database.child(path).onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _users.clear();
            if (path == 'user') {
              // Admin case: Iterate over all roles
              data.forEach((role, users) {
                if (users is Map) {
                  users.forEach((uid, userData) async {
                    if (userData is Map) {
                      try {
                        final userObj = await UserData.fromJson(
                            Map<String, dynamic>.from(userData), uid as String);
                        _users.add(userObj);
                      } catch (e) {
                        print('Error parsing user $uid: $e');
                      }
                    }
                  });
                }
              });
            } else {
              // Non-admin case: Data is already scoped to the role
              data.forEach((uid, userData) async {
                if (userData is Map) {
                  try {
                    final userObj = await UserData.fromJson(
                        Map<String, dynamic>.from(userData), uid as String);
                    _users.add(userObj);
                  } catch (e) {
                    print('Error parsing user $uid: $e');
                  }
                }
              });
            }
            _users.sort((a, b) => a.email.compareTo(b.email));
          }
        } else {
          _users.clear();
        }
      }, onError: (error) {
        errorMessage.value = 'Failed to load users: $error';
        Get.snackbar(
          'Error',
          'Failed to load users: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    });
  }

  /// Signs in a user with email and password, ensuring security (SRS 3.2.3).
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('Attempting sign-in with email: $email, password: [hidden]');

      final credentials = UserCredentials(
        email: email,
        password: password,
      );

      final response = await _authService.signInWithEmailAndPassword(credentials);
      print('Sign-in response: $response');

      if (response.success) {
        currentUser.value = response.userData;
        if (currentUser.value == null) {
          errorMessage.value = 'User profile not found. Please sign up or contact support.';
          Get.snackbar(
            'Error',
            'User profile not found. Please sign up or contact support.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          await _auth.signOut();
          return false;
        }
        print('User signed in: email=${currentUser.value?.email}, role=${currentUser.value?.role}, emailVerified=${currentUser.value?.emailVerified}');
        _updateProjectController(currentUser.value!.uid, currentUser.value!.role);
        _navigateBasedOnRole(currentUser.value!.role);
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('Sign-in error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Signs up a new user with email and password, ensuring security (SRS 3.2.3).
  Future<bool> registerUser({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final registerData = RegisterUserData(
        email: email,
        password: password,
        role: role,
      );

      final response = await _authService.registerUser(registerData);
      print('Registration response: $response');

      if (response.success) {
        currentUser.value = response.userData;
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        if (currentUser.value != null) {
          _updateProjectController(currentUser.value!.uid, currentUser.value!.role);
          _navigateBasedOnRole(currentUser.value!.role);
        }
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Registration failed';
      print('Registration error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Signs in with Google, ensuring security (SRS 3.2.3).
  Future<bool> signInWithGoogle(UserRole role) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.signInWithGoogle(role);

      if (response.success) {
        currentUser.value = response.userData;
        if (currentUser.value != null) {
          _updateProjectController(currentUser.value!.uid, currentUser.value!.role);
          _navigateBasedOnRole(currentUser.value!.role);
        }
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Google sign in failed';
      print('Google sign-in error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates the ProjectController with the user's role and ID, ensuring usability (SRS 3.2.2).
  void _updateProjectController(String userId, UserRole role) {
    print('Updating ProjectController for userId: $userId, role: ${role.name}');
    final projectController = Provider.of<ProjectController>(Get.context!, listen: false);
    projectController.updateUserType(role.name); // Use role.name as userType
    projectController.loadProjects(); // Reload projects with the new role
  }

  /// Navigates to the appropriate dashboard based on the user's role, ensuring usability (SRS 3.2.2).
  void _navigateBasedOnRole(UserRole? role) {
    if (role == null) {
      Get.snackbar(
        'Error',
        'Role is null. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Widget? dashboard;
    try {
      print('Navigating to dashboard for role: ${role.name}');
      switch (role) {
        case UserRole.homeowner:
          dashboard = const HomeOwnerDashboard();
          break;
        case UserRole.contractor:
          dashboard = ContractorDashboard();
          break;
        case UserRole.architect:
          dashboard = const ArchitectDashboard();
          break;
        case UserRole.vendor:
          dashboard = const VendorDashboard();
          break;
        case UserRole.admin:
          dashboard = const AdminDashboard();
          break;
      }

      if (dashboard != null) {
        Get.offAll(
              () => dashboard!,
          transition: Transition.fade,
          duration: const Duration(milliseconds: 500),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Navigation Error',
        'Error navigating to dashboard. Please try again: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Signs out the current user, ensuring security (SRS 3.2.3).
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      currentUser.value = null;
      Get.offAllNamed('/stakeholder');
    } catch (e) {
      errorMessage.value = 'Sign out failed';
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Checks the current user and navigates accordingly, ensuring usability (SRS 3.2.2).
  Future<void> checkCurrentUser() async {
    try {
      isLoading.value = true;
      final userData = await _authService.getCurrentUserData();
      currentUser.value = userData;
      if (userData != null) {
        _updateProjectController(userData.uid, userData.role);
        _navigateBasedOnRole(userData.role);
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch user data';
    } finally {
      isLoading.value = false;
    }
  }

  /// Checks if the user is authenticated, ensuring security (SRS 3.2.3).
  bool get isAuthenticated => currentUser.value != null;

  /// Checks if the user's email is verified, ensuring security (SRS 3.2.3).
  bool get isEmailVerified => currentUser.value?.emailVerified ?? false;

  /// Checks if email verification is required for the user's role, ensuring security (SRS 3.2.3).
  bool get requiresEmailVerification =>
      currentUser.value != null &&
          [UserRole.contractor, UserRole.architect, UserRole.vendor]
              .contains(currentUser.value!.role);

  /// Clears any error messages, ensuring usability (SRS 3.2.2).
  void clearError() {
    errorMessage.value = '';
  }

  /// Cleans up resources, ensuring reliability (SRS 3.2.4).
  @override
  void onClose() {
    _authStateSubscription?.cancel();
    _usersSubscription?.cancel();
    super.onClose();
  }
}












































