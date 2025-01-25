import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/authControllers.dart';
import '../../Models/userModels.dart';
import '../DashBoard/Admin.dart';
import '../Shared/widgets/custom_button.dart';
import '../Shared/widgets/input_field.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Shared/widgets/auth_success_animation.dart';

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
      final DatabaseReference ref = FirebaseDatabase.instance.ref('admin_code');
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        String storedCode = snapshot.value.toString().trim();
        String enteredTrimmedCode = enteredCode.trim();
        return storedCode == enteredTrimmedCode;
      }
      return false;
    } catch (error) {
      print("Error validating admin code: $error");
      return false;
    }
  }

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool isAdminCodeValid = await _isAdminCodeValid(_adminCodeController.text);
      if (!isAdminCodeValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid admin code'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await _authController.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        final userData = _authController.currentUser.value;
        if (userData != null && userData.role == UserRole.admin) {
          if (_rememberMe) {
            // Implement remember me functionality
            // await _saveUserCredentials();
          }

          // Show success animation
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AuthSuccessAnimation(
              onAnimationComplete: () {
                Navigator.pop(context);
                Get.offAll(() => const AdminDashboard());
              },
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access denied: Admin only'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background circles
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
          //
          // Sign-in form
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
                        validator: (value) => value == null || value.isEmpty
                            ? 'Admin code is required'
                            : null,
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