import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);

    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.completed) {
        // Navigate to the next screen after the animation is complete
        Navigator.pushReplacementNamed(context, '/boarding');
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background for visual enhancement
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Centered logo and project name with animation
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset('assets/logo.png', width: 120),
                ),
                const SizedBox(height: 20),
                // Project name with styling
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Build Buddy',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                // Optional project tagline with styling
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Building Dreams, One Step at a Time',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
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



/*
import 'package:flutter/material.dart';
import '../shared/widgets/custom_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);

    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.completed) {
        // Navigate to the next screen after the animation is complete
        Navigator.pushReplacementNamed(context, '/boarding');
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color or image
          Container(
            color: Colors.white,
          ),
          // Animated app logo
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset('assets/logo.png', width: 120),
            ),
          ),
        ],
      ),
    );
  }
}


*/
