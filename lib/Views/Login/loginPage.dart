import 'package:flutter/material.dart';
import 'package:buildbuddyfyp/Views/DashBoard/HomeOwner.dart';
import 'package:buildbuddyfyp/Views/Login/signUp.dart';
import 'package:buildbuddyfyp/Views/Login/forgotPassword.dart';
import 'package:get/get.dart';
import '../../Models/userModels.dart';
import '../Shared/widgets/custom_button.dart';
import '../Shared/widgets/input_field.dart';
import '../../Controllers/authControllers.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Architect.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Vendor.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Admin.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Constructor.dart';
import 'package:buildbuddyfyp/Views/Shared/widgets/auth_success_animation.dart';

// Password Validator class
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

// SignInScreen StatefulWidget
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}


class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Improved email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

////




  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print("Attempting sign in...");
      final success = await _authController.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );


      if (success) {
        print("Login Successful");
        print("User data: ${_authController.currentUser.value}");
      } else {
        print("Login Failed");
        if (_authController.errorMessage.value.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_authController.errorMessage.value),
              backgroundColor: Colors.red,
            ),
          );
        }

      }
      if (success && mounted) {
        // Clear any previous error messages
        _authController.clearError();

        final userData = _authController.currentUser.value;
        if (userData != null) {
          if (_rememberMe) {
            // Implement remember me functionality
            await _saveUserCredentials();
          }

          // Show success animation
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

      //final success = await _authController.signInWithGoogle();

      // Show role selection dialog for Google sign-in
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
                  .where((role) => role != UserRole.admin) // Exclude admin role
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
    print("Navigating based on role: ${role.toString()}");

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
    // Note: Use secure storage like flutter_secure_storage in production
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background circles for aesthetics
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
                        'Welcome\nBack',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A60),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Hey! Good to see you again',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      InputField(
                        controller: _emailController,
                        hintText: 'Email(e.g.,umer@gmail.com)',
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
                        validator: PasswordValidator.validatePassword,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                              ),
                              const Text('Remember me'),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(color: Color(0xFF1A1A60)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 140),
                      CustomButton(
                        text: 'SIGN IN',
                        onPressed: _handleSignIn,
                        isLoading: _isLoading,
                        icon: Icons.login,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        ),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Don't have an account? ", style: TextStyle(color: Colors.white)),
                              TextSpan(text: "Sign up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      OutlinedButton(
                        onPressed: _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_translate, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Sign in with Google', style: TextStyle(color: Colors.blue, fontSize: 16)),
                          ],
                        ),
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



























//Runnable code

/*
import 'package:flutter/material.dart';
import 'package:buildbuddyfyp/Views/DashBoard/HomeOwner.dart';
import 'package:buildbuddyfyp/Views/Login/signUp.dart';
import 'package:buildbuddyfyp/Views/Login/forgotPassword.dart';
import '../../Models/userModels.dart';
import '../Shared/widgets/custom_button.dart';
import '../Shared/widgets/input_field.dart';
import '../../Controllers/authControllers.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Architect.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Vendor.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Admin.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Constructor.dart';

import 'animationScreen.dart';

// Password Validator class
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

// SignInScreen StatefulWidget
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final _authController = UserController();
  bool _showSuccessAnimation = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Sign in handler
  */
/*void _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final response = await _authController.login(
          UserCredentials(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );

        if (mounted) {
          if (response.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signed in successfully!')),
            );
            _navigateBasedOnRole(response.userData!.role);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.message)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
*//*

  void _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final response = await _authController.login(
          UserCredentials(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );

        if (mounted) {
          if (response.success) {
            setState(() {
              _isLoading = false;
              _showSuccessAnimation = true;
            });

            // Show success animation before navigation
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AuthSuccessAnimation(
                onAnimationComplete: () {
                  Navigator.pop(context); // Close the dialog
                  _navigateBasedOnRole(response.userData!.role);
                },
              ),
            );
          } else {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.message)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }


  */
/*
/ Google sign-in handler
  void _handleGoogleSignIn() async {
    final selectedRole = await showDialog<UserRole>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Your Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) {
              return ListTile(
                title: Text(role.name.toUpperCase()),
                onTap: () => Navigator.pop(context, role),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedRole == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authController.signInWithGoogle(selectedRole);

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in with Google successfully!')),
          );
          _navigateBasedOnRole(response.userData!.role);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }*//*

  // Modify _handleGoogleSignIn method
  void _handleGoogleSignIn() async {
    final selectedRole = await showDialog<UserRole>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Your Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) {
              return ListTile(
                title: Text(role.name.toUpperCase()),
                onTap: () => Navigator.pop(context, role),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedRole == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authController.signInWithGoogle(selectedRole);

      if (mounted) {
        if (response.success) {
          setState(() {
            _isLoading = false;
            _showSuccessAnimation = true;
          });

          // Show success animation before navigation
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AuthSuccessAnimation(
              onAnimationComplete: () {
                Navigator.pop(context); // Close the dialog
                _navigateBasedOnRole(response.userData!.role);
              },
            ),
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }


  void _navigateBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.homeowner:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeOwnerDashboard()),
        );
        break;
      case UserRole.contractor:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ContractorDashboard()),
        );
        break;
      case UserRole.architect:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ArchitectDashboard()),
        );
        break;
      case UserRole.vendor:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VendorDashboard()),
        );
        break;
      case UserRole.admin:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
        break;
      default:
      // Optional: Handle undefined roles
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeOwnerDashboard()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background circles for aesthetics
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
                        'Welcome\nBack',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A60),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Hey! Good to see you again',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      InputField(
                        controller: _emailController,
                        hintText: 'Email',
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
                        validator: PasswordValidator.validatePassword,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                              ),
                              const Text('Remember me'),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(color: Color(0xFF1A1A60)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 140),
                      CustomButton(
                        text: 'SIGN IN',
                        onPressed: _handleSignIn,
                        isLoading: _isLoading,
                        icon: Icons.login,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        ),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Don't have an account? ", style: TextStyle(color: Colors.white)),
                              TextSpan(text: "Sign up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      OutlinedButton(
                        onPressed: _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_translate, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Sign in with Google', style: TextStyle(color: Colors.blue, fontSize: 16)),
                          ],
                        ),
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
*/

