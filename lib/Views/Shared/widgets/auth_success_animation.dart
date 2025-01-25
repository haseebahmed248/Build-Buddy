import 'package:flutter/material.dart';

class AuthSuccessAnimation extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const AuthSuccessAnimation({Key? key, required this.onAnimationComplete}) : super(key: key);

  @override
  _AuthSuccessAnimationState createState() => _AuthSuccessAnimationState();
}

class _AuthSuccessAnimationState extends State<AuthSuccessAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), widget.onAnimationComplete);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                "Success!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
