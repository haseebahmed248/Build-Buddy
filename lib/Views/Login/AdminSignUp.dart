import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/authControllers.dart';
import '../../Models/userModels.dart';
import '../Shared/widgets/custom_button.dart';
import '../Shared/widgets/input_field.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Shared/widgets/auth_success_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSignInScreen extends StatefulWidget {
  const AdminSignInScreen({super.key});

  @override
  State<AdminSignInScreen> createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<bool> _isAdminCodeValid(String enteredCode) async {
    try {
      print('Querying admin_code from Firebase with user: ${FirebaseAuth.instance.currentUser?.email}, enteredCode: "$enteredCode"');
      final snapshot = await FirebaseDatabase.instance.ref('admin_code').get();
      print('Raw admin_code snapshot value: ${snapshot.value}, type: ${snapshot.value.runtimeType}, exists: ${snapshot.exists}');
      if (!snapshot.exists) {
        print('Admin code node does not exist');
        return false;
      }
      final storedCode = snapshot.value.toString().trim();
      final isValid = storedCode.toLowerCase() == enteredCode.toLowerCase();
      print('Admin code comparison - Entered (trimmed): \'$enteredCode\', Stored (trimmed): \'$storedCode\'');
      print('Admin code validation result: $isValid (case-insensitive comparison)');
      return isValid;
    } catch (e) {
      print('Error validating admin code: $e');
      return false;
    }
  }

/*  Future<bool> _isAdminCodeValid(String enteredCode) async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('admin_code');
      final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'No user';
      print('Querying admin_code from Firebase with user: $userEmail, enteredCode: "$enteredCode"');
      final DataSnapshot snapshot = await ref.get().timeout(const Duration(seconds: 10));

      if (!snapshot.exists) {
        print("Admin code node does not exist in Firebase at path: /admin_code");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin code not configured in database. Contact support.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Log the raw snapshot value to debug formatting issues
      print('Raw admin_code snapshot value: ${snapshot.value}, type: ${snapshot.value.runtimeType}');

      final storedCode = snapshot.value?.toString().trim() ?? '';
      final trimmedEnteredCode = enteredCode.trim();

      print("Admin code comparison - Entered (trimmed): '$trimmedEnteredCode', Stored (trimmed): '$storedCode'");

      if (storedCode.isEmpty) {
        print("Stored admin code is empty after trimming");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin code is not set in Firebase.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Case-insensitive comparison
      final isValid = storedCode.toLowerCase() == trimmedEnteredCode.toLowerCase();
      print("Admin code validation result: $isValid (case-insensitive comparison)");

      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid admin code. Please check and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return isValid;
    } catch (error) {
      print("Admin code validation error: $error");
      if (error is FirebaseException && error.code == 'permission-denied') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied accessing admin code. Check Firebase rules.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (error is TimeoutException) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request timed out while fetching admin code. Check your network.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating admin code: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }*/
  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Attempting admin sign-in with email: ${_emailController.text}, password: [hidden], adminCode: ${_adminCodeController.text}');

      // Ensure the user is authenticated before querying admin_code
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No current user, attempting pre-authentication with email and password');
        await _authController.signInWithEmail(_emailController.text.trim().toLowerCase(), _passwordController.text);
        user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Authentication failed');
        }
      }

      // Validate admin code
      int retryCount = 0;
      const maxRetries = 3;
      bool isAdminCodeValid = false;

      while (retryCount < maxRetries && !isAdminCodeValid) {
        isAdminCodeValid = await _isAdminCodeValid(_adminCodeController.text);
        if (!isAdminCodeValid) {
          if (retryCount == maxRetries - 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid admin code or network error after retries'),
                backgroundColor: Colors.red,
              ),
            );
            break;
          }
          retryCount++;
          print('Retry attempt $retryCount for admin code validation');
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (!isAdminCodeValid) {
        print('Admin code validation failed after retries');
        return;
      }

      // Proceed with sign-in
      final success = await _authController.signInWithEmail(
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
      );

      print('Sign-in result: success=$success, user=${_authController.currentUser.value?.email}, role=${_authController.currentUser.value?.role}, emailVerified=${_authController.currentUser.value?.emailVerified}');

      if (success && mounted) {
        final userData = _authController.currentUser.value;
        if (userData != null) {
          if (userData.role != UserRole.admin) {
            print('User role is not admin, updating to admin role for UID: ${userData.uid}');
            final updatedUserData = userData.copyWith(
              role: UserRole.admin,
              lastLogin: DateTime.now(),
            );
            await FirebaseDatabase.instance.ref('user/admin/${userData.uid}').set(updatedUserData.toJson());
            _authController.currentUser.value = updatedUserData;
          }

          if (userData.role == UserRole.admin) {
            if (_rememberMe) {
              // Implement remember me functionality if needed
            }

            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AuthSuccessAnimation(
                onAnimationComplete: () {
                  Navigator.pop(context);
                  Get.offAllNamed('/admin-dashboard');
                },
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Access denied: User is not an admin - Role: ${userData.role}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data not found after sign-in'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Sign-in error: $e');
      if (e is FirebaseAuthException && (e.code == 'wrong-password' || e.code == 'user-not-found')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during sign-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
 /* void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Attempting admin sign-in with email: ${_emailController.text}, password: [hidden], adminCode: ${_adminCodeController.text}');

      // Ensure the user is authenticated (temporary check before code validation)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await _authController.signInWithEmail(_emailController.text.trim().toLowerCase(), _passwordController.text);
      }

      int retryCount = 0;
      const maxRetries = 3;
      bool isAdminCodeValid = false;

      while (retryCount < maxRetries && !isAdminCodeValid) {
        isAdminCodeValid = await _isAdminCodeValid(_adminCodeController.text);
        if (!isAdminCodeValid) {
          if (retryCount == maxRetries - 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid admin code or network error after retries'),
                backgroundColor: Colors.red,
              ),
            );
            break;
          }
          retryCount++;
          print('Retry attempt $retryCount for admin code validation');
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (!isAdminCodeValid) {
        print('Admin code validation failed after retries');
        return;
      }

      // Proceed with sign-in if code is valid
      final success = await _authController.signInWithEmail(
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
      );

      print('Sign-in result: success=$success, user=${_authController.currentUser.value?.email}, role=${_authController.currentUser.value?.role}, emailVerified=${_authController.currentUser.value?.emailVerified}');

      if (success && mounted) {
        final userData = _authController.currentUser.value;
        if (userData != null) {
          if (userData.role != UserRole.admin) {
            print('User role is not admin, updating to admin role for UID: ${userData.uid}');
            await FirebaseDatabase.instance.ref('user/admin/${userData.uid}').set({
              'email': userData.email,
              'role': 'admin',
              'uid': userData.uid,
            });
            _authController.currentUser.value = userData.copyWith(role: UserRole.admin);
          }

          if (userData.role == UserRole.admin) {
            if (_rememberMe) {
              // Implement remember me functionality if needed
            }

            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AuthSuccessAnimation(
                onAnimationComplete: () {
                  Navigator.pop(context);
                  Get.offAllNamed('/admin-dashboard');
                },
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Access denied: User is not an admin - Role: ${userData.role}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data not found after sign-in'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Sign-in error: $e');
      if (e is FirebaseAuthException && (e.code == 'wrong-password' || e.code == 'user-not-found')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during sign-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: 50,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 500,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            right: -100,
            child: Container(
              width: 600,
              height: 450,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Admin\nPanel',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A60),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Welcome to the admin portal',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      InputField(
                        controller: _emailController,
                        hintText: 'Admin Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) => value != null && value.length >= 8
                            ? null
                            : 'Password must be at least 8 characters long',
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _adminCodeController,
                        hintText: 'Admin Code',
                        prefixIcon: Icons.admin_panel_settings,
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty ? 'Admin code is required' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) => setState(() => _rememberMe = value ?? false),
                          ),
                          const Text('Remember me'),
                        ],
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: 'ADMIN SIGN IN',
                        onPressed: _handleSignIn,
                        isLoading: _isLoading,
                        icon: Icons.admin_panel_settings,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}