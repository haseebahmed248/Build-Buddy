import 'package:buildbuddyfyp/Views/shared/widgets/custom_button.dart';
import 'package:buildbuddyfyp/Views/Login/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/authControllers.dart';
import '../../Models/userModels.dart';
import '../Shared/widgets/auth_success_animation.dart';
import '../Shared/widgets/input_field.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late UserRole selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _authController = Get.find<AuthController>();
  @override
  void initState() {
    super.initState();
    print("SignUpScreen received arguments: ${Get.arguments}");
    if (Get.arguments != null && Get.arguments is String) {
      selectedRole = UserRole.values.firstWhere(
            (e) => e.name == Get.arguments,
        orElse: () => UserRole.admin,
      );
    } else {
      selectedRole = UserRole.admin;
    }
    print("Selected Role: $selectedRole");
  }



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  void _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show a toast about the selected role
      Get.snackbar(
        'Role Selected',
        'You are signing up as a ${selectedRole.name.toUpperCase()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
        icon: Icon(Icons.info_outline, color: Colors.white),
        duration: Duration(seconds: 2),
      );

      // Register user with selected role
      final success = await _authController.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: selectedRole,
      );

      if (success) {
        // Show the success animation
        await showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => AuthSuccessAnimation(
            onAnimationComplete: () {
              Navigator.pop(context); // Close the dialog
             // _authController.goToHome(); // Navigate to home
            },
          ),
        );
      }
    }
  }

  // color scheme
  static const Color darkBlue = Color(0xFF1A1A60);     // Deeper blue for large circles
  static const Color secondaryGrey = Color(0xFF757575); // Secondary text color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Wrap with ResizeToAvoidBottomInset to prevent keyboard from pushing up content
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Position circles using MediaQuery to calculate relative positions
          Positioned(
            top: MediaQuery.of(context).size.height * -0.2,
            right: MediaQuery.of(context).size.width * -0.25,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.08,
            right: MediaQuery.of(context).size.width * -0.17,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: darkBlue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * -0.2,
            left: MediaQuery.of(context).size.width * -0.25,
            child: Container(
              width: MediaQuery.of(context).size.width * 1.1,
              height: MediaQuery.of(context).size.height * 0.44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: darkBlue,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * -0.15,
            right: MediaQuery.of(context).size.width * -0.2,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          // Main content wrapped in SingleChildScrollView
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.16),
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          color: darkBlue,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Hello! let\'s join with us',
                        style: TextStyle(
                          fontSize: 18.5,
                          color: secondaryGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 50),
                      InputField(
                        controller: _emailController,
                        hintText: 'Email(e.g.,umer@gmail.com)',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _passwordController,
                        hintText: 'Password(e.g., Abx@1234)',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: PasswordValidator.validatePassword,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const Spacer(),
                      CustomButton(
                        text: 'SIGN UP',
                        onPressed: _handleSignUp,
                        icon: Icons.person_add,
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignInScreen()),
                          ),
                          child: const Text(
                            'You already have an account? Sign in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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

































