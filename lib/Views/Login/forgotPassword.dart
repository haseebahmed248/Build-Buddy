import 'package:flutter/material.dart';

import '../Shared/widgets/custom_button.dart';
import '../Shared/widgets/input_field.dart';
import 'package:buildbuddyfyp/Views/Login/loginPage.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  void _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
        Navigator.pop(context);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -55,
            right: -90,
            child: Container(
              width: 250,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            top: -55,
            right: 50,
            child: Container(
              width: 250,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            bottom: -270,
            right: -150,
            child: Container(
              width: 500,
              height: 550,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),

    SafeArea(
    child: Padding(
    padding: const EdgeInsets.all(24.0),
    child: Form(
    key: _formKey,
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    const Text(
    'Forgot Password',
    style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A1A60),
    ),
    ),
    const SizedBox(height: 8),
    const Text(
    'Enter your email to reset your password',
    style: TextStyle(
    fontSize: 16,
    color: Colors.grey,
    ),
    ),
    const SizedBox(height: 32),
    InputField(
    controller: _emailController,
    hintText: 'Email',
    prefixIcon: Icons.email_outlined,
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email address';
    }
    return null;
    },
    ),
    const SizedBox(height: 32),
    CustomButton(
    text: 'RESET PASSWORD',
    onPressed: _handleResetPassword,
    isLoading: _isLoading,
    icon: Icons.lock_reset,
    ),
    const SizedBox(height: 16),
    TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text(
    'Back to Sign In',
    style: TextStyle(
    color: Color(0xFF1A1A60),
    fontSize: 16,
    ),
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    ],
    ),
    );
  }
}






/*

import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -55,
            right: -90,
            child: Container(
              width: 250,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            top: -55,
            right: 50,
            child: Container(
              width: 250,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            bottom: -270,
            right: -150,
            child: Container(
              width: 500,
              height: 550,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),

          Center(

            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your email to reset your password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe91e63),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Handle password reset logic
                    },
                    child: const Text('RESET PASSWORD'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back to Sign In',
                      style: TextStyle(
                        color: Color(0xFFe91e63),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



*/





























/*import 'package:flutter/material.dart';
import 'package:buildbuddyfyp/Controllers/authControllers.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E20EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                Image.asset(
                  'assets/Logo.png',
                  width: 200,
                  height: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                // Header Text
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Enter your email to reset your password',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                // Form Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Reset Password Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle password reset
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E20EE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'RESET PASSWORD',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Back to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Remember your password? '),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Login here',
                              style: TextStyle(
                                color: Color(0xFF6E20EE),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/



























//import 'package:flutter/cupertino.dart';
/*import 'package:flutter/material.dart';
import 'package:buildbuddyfyp/Views/Shared/widgets/input_field.dart';
import 'package:buildbuddyfyp/Views/Shared/widgets/custom_button.dart';

import '../../Controllers/authControllers.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authController = AuthController();

  Future<void> _resetPassword() async {
    await _authController.sendPasswordResetEmail(_emailController.text);
   // showSnackBar(context, 'Password reset email sent');
    //showSnackBar(context, 'Password reset email sent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Forgot Password screen UI
            InputField(controller: _emailController, hintText: 'Email'),
            const SizedBox(height: 24.0),
            CustomButton(text: 'Reset Password', onPressed: _resetPassword),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // Navigate to LoginScreen
              },
              child: const Text('Back to Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}*/