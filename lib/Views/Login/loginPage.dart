import 'package:flutter/material.dart';
import 'package:buildbuddy/Views/DashBoard/HomeOwner.dart';
import 'package:buildbuddy/Views/Login/signUP.dart';
import 'package:buildbuddy/Views/Login/forgotPassword.dart';
import 'package:get/get.dart';
import '../../Models/userModels.dart';
import '../Shared/widgets/custom_button.dart';
import '../Shared/widgets/input_field.dart';
import '../../Controllers/authControllers.dart';
import 'package:buildbuddy/Views/DashBoard/Architect.dart';
import 'package:buildbuddy/Views/DashBoard/Vendor.dart';
import 'package:buildbuddy/Views/DashBoard/Admin.dart';
import 'package:buildbuddy/Views/DashBoard/Constructor.dart';
import 'package:buildbuddy/Views/Shared/widgets/auth_success_animation.dart';

class PasswordValidator {
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (value.contains(RegExp(r'^[0-9]+$'))) {
      return 'Password cannot be entirely numeric';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  double _keyboardHeight = 0.0;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    final newKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (newKeyboardHeight != _keyboardHeight) {
      setState(() {
        _keyboardHeight = newKeyboardHeight;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authController.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        _authController.clearError();

        final userData = _authController.currentUser.value;
        if (userData != null) {
          if (_rememberMe) {
            await _saveUserCredentials();
          }

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AuthSuccessAnimation(
              onAnimationComplete: () {
                Navigator.pop(context);
                _navigateBasedOnRole(userData.role);
              },
            ),
          );
        }
      } else {
        if (mounted && _authController.errorMessage.value.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_authController.errorMessage.value),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);

      final selectedRole = await _showRoleSelectionDialog();
      if (selectedRole == null) {
        setState(() => _isLoading = false);
        return;
      }

      final success = await _authController.signInWithGoogle(selectedRole);

      if (success && mounted) {
        final userData = _authController.currentUser.value;
        if (userData != null) {
          _navigateBasedOnRole(userData.role);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-in Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<UserRole?> _showRoleSelectionDialog() async {
    return showDialog<UserRole>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Your Role'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: UserRole.values
                  .where((role) => role != UserRole.admin)
                  .map((role) {
                return ListTile(
                  title: Text(role.toString().split('.').last.toUpperCase()),
                  onTap: () => Navigator.pop(context, role),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _navigateBasedOnRole(UserRole role) {
    if (!mounted) return;

    Widget dashboard;
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
        dashboard = const AdminDashboard();
        break;
      default:
        dashboard = const HomeOwnerDashboard();
    }

    Get.offAll(() => dashboard);
  }

  Future<void> _saveUserCredentials() async {
    // Implement secure credential storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background circles
              Positioned(
                top: -constraints.maxHeight * 0.1,
                right: -constraints.maxWidth * 0.2,
                child: Container(
                  width: constraints.maxWidth * 0.6,
                  height: constraints.maxWidth * 0.6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
              Positioned(
                top: -constraints.maxHeight * 0.05,
                right: constraints.maxWidth * 0.1,
                child: Container(
                  width: constraints.maxWidth * 0.4,
                  height: constraints.maxWidth * 0.4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1a237e),
                  ),
                ),
              ),
              Positioned(
                bottom: -constraints.maxHeight * 0.15,
                left: -constraints.maxWidth * 0.3,
                child: Container(
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxWidth * 0.8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
              Positioned(
                bottom: -constraints.maxHeight * 0.2,
                right: -constraints.maxWidth * 0.3,
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1a237e),
                  ),
                ),
              ),
              // Main content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.05,
                    vertical: constraints.maxHeight * 0.02,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.02),
                        const Text(
                          'Welcome\nBack',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A60),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        const Text(
                          'Hey! Good to see you again',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.04),
                        InputField(
                          controller: _emailController,
                          hintText: 'Email(e.g.,umer@gmail.com)',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        InputField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText:
                              _obscurePassword, // This makes the password hidden or visible
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons
                                      .visibility_off // Icon when password is hidden
                                  : Icons
                                      .visibility, // Icon when password is visible
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword; // Toggle visibility
                              });
                            },
                          ),
                          validator: PasswordValidator.validatePassword,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) => setState(
                                      () => _rememberMe = value ?? false),
                                ),
                                const Text('Remember me'),
                              ],
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen()),
                              ),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(color: Color(0xFF1A1A60)),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        CustomButton(
                          text: 'SIGN IN',
                          onPressed: _handleSignIn,
                          isLoading: _isLoading,
                          icon: Icons.login,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen()),
                          ),
                          child: const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(color: Colors.white)),
                                TextSpan(
                                    text: "Sign up",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        OutlinedButton(
                          onPressed: _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            side: const BorderSide(color: Colors.blue),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_translate, color: Colors.blue),
                              SizedBox(width: 10),
                              Text('Sign in with Google',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 16)),
                            ],
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
