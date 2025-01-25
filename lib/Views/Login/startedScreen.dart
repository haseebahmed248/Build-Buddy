///////
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:buildbuddyfyp/Views/Login/signUP.dart';
import 'package:buildbuddyfyp/Views/Login/loginPage.dart';
import 'package:get/get.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  void _showToast(String action, String role) {
    Fluttertoast.showToast(
      msg: "$action as $role",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the selected role from arguments
    final String role = Get.arguments ?? '';

    return Scaffold(
      body: Stack(
        children: [
          // Top right circle
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          // Most left circle
          Positioned(
            bottom: -120,
            left: -100,
            child: Container(
              width: 350,
              height: 550,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          // Middle circle
          Positioned(
            bottom: -40,
            left: -80,
            right: -70,
            child: Container(
              width: 150,
              height: 290,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),
          // Most right circle
          Positioned(
            bottom: -136,
            right: -70,
            child: Container(
              width: 300,
              height: 500,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 75),
                const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1a237e),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Start with sign up or sign in',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 380),
                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    _showToast("Signing up", role);
                    Get.to(() => const SignUpScreen(), arguments: role);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8F8F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Sign In Button
                ElevatedButton(
                  onPressed: () {
                    _showToast("Signing in", role);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8F8F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}






















