
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  late double _videoDuration;
  late double _currentPosition;

  // Initial background color
  Color _startColor = const Color(0xFF6A82FB); // Soft Blue
  Color _endColor = const Color(0xFFFC5C7D); // Soft Pink

  @override
  void initState() {
    super.initState();

    // Initialize video controller with your video file
    _controller = VideoPlayerController.asset('assets/animation.mp4')
      ..initialize().then((_) {
        setState(() {
          _videoDuration = _controller.value.duration.inMilliseconds.toDouble();
        });
        _controller.play(); // Start playing the video
        _controller.setLooping(false); // Disable looping if you only want to show it once
      });

    // Update the background color as the video plays
    _controller.addListener(() {
      setState(() {
        _currentPosition = _controller.value.position.inMilliseconds.toDouble();
        // Change color as the video progresses
        double progress = _currentPosition / _videoDuration;
        _startColor = Color.lerp(const Color(0xFF6A82FB), const Color(0xFFFC5C7D), progress)!;
        _endColor = Color.lerp(const Color(0xFFFC5C7D), const Color(0xFF6A82FB), progress)!;
      });

      if (_controller.value.position == _controller.value.duration) {
        // Video has finished playing, navigate to the next screen
        Navigator.pushReplacementNamed(context, '/boarding'); // Use named route '/boarding'
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // Dispose of the video controller to release resources
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500), // Smooth transition for background color
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_startColor, _endColor], // Dynamic colors changing as video progresses
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : const CircularProgressIndicator(), // Show loading while video is initializing
        ),
      ),
    );
  }
}

















