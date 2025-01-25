import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({super.key});

  @override
  BoardingScreenState createState() => BoardingScreenState();
}

class BoardingScreenState extends State<BoardingScreen> {
  final PageController pageController = PageController();

  // Extended list of boarding screens (13 screens)
  final List<Map<String, dynamic>> boardingData = [
    {'image': 'assets/1.jpg', 'title': 'Welcome to BuildBuddy!', 'description': 'Your ultimate app for productivity and innovation.'},
    {'image': 'assets/2.jpg', 'title': 'Stay Organized', 'description': 'Manage your tasks and projects seamlessly.'},
    {'image': 'assets/3.jpg', 'title': 'Collaborate Effectively', 'description': 'Work together with your team in real time.'},
    {'image': 'assets/4.jpg', 'title': 'Get Started Today', 'description': 'Let’s build something amazing together!'},
    {'image': 'assets/5.jpg', 'title': 'Innovative Tools', 'description': 'Access cutting-edge tools and features to enhance your projects.'},
    {'image': 'assets/6.jpg', 'title': 'Easy Setup', 'description': 'Get started quickly with simple setup steps.'},
    {'image': 'assets/7.jpg', 'title': 'Smart Suggestions', 'description': 'Receive smart suggestions tailored to your needs.'},
    {'image': 'assets/8.jpg', 'title': 'Real-Time Notifications', 'description': 'Stay updated with real-time alerts and messages.'},
    {'image': 'assets/9.jpg', 'title': 'Collaborate in Real Time', 'description': 'Communicate directly with your team for efficient progress.'},
    {'image': 'assets/10.jpg', 'title': 'Track Your Progress', 'description': 'Monitor the status of your tasks and projects easily.'},
    {'image': 'assets/11.jpg', 'title': 'Secure Data', 'description': 'Your data is safe with our top-notch security features.'},
    {'image': 'assets/12.jpg', 'title': 'Smooth Experience', 'description': 'Enjoy a seamless user interface and experience.'},
    {'image': 'assets/13.jpg', 'title': 'Join the Community', 'description': 'Become part of the BuildBuddy community and connect with others.'},
  ];

  void _navigateToWelcome() {
    Navigator.pushNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: boardingData.length,
            itemBuilder: (context, index) {
              final data = boardingData[index];
              return BoardingSlide(
                image: data['image'],
                title: data['title'],
                description: data['description'],
                isLast: index == boardingData.length - 1,
                onGetStarted: _navigateToWelcome,
              );
            },
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: boardingData.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: const Color(0xFFFFA726),
                  dotColor: Colors.grey.shade400,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
            ),
          ),
          Positioned(
            top: 48,
            right: 16,
            child: TextButton(
              onPressed: _navigateToWelcome,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BoardingSlide extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final bool isLast;
  final VoidCallback onGetStarted;

  const BoardingSlide({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    this.isLast = false,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Full visible image with BoxFit.contain
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Image.asset(
              image,
              key: ValueKey(image),
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain, // Ensures the full image is visible
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          if (isLast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({super.key});

  @override
  BoardingScreenState createState() => BoardingScreenState();
}

class BoardingScreenState extends State<BoardingScreen> {
  final PageController pageController = PageController();

  final List<Map<String, dynamic>> boardingData = [
    {
      'image': 'assets/1.jpg',
      'title': 'Welcome to BuildBuddy!',
      'description': 'Your ultimate app for productivity and innovation.',
    },
    {
      'image': 'assets/2.jpg',
      'title': 'Stay Organized',
      'description': 'Manage your tasks and projects seamlessly.',
    },
    {
      'image': 'assets/3.jpg',
      'title': 'Collaborate Effectively',
      'description': 'Work together with your team in real time.',
    },
    {
      'image': 'assets/10.jpg',
      'title': 'Get Started Today',
      'description': 'Let’s build something amazing together!',
    },
  ];

  void _navigateToWelcome() {
    Navigator.pushNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: boardingData.length,
            itemBuilder: (context, index) {
              final data = boardingData[index];
              return BoardingSlide(
                image: data['image'],
                title: data['title'],
                description: data['description'],
                isLast: index == boardingData.length - 1,
                onGetStarted: _navigateToWelcome,
              );
            },
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: boardingData.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: const Color(0xFFFFA726),
                  dotColor: Colors.grey.shade400,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
            ),
          ),
          Positioned(
            top: 48,
            right: 16,
            child: TextButton(
              onPressed: _navigateToWelcome,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BoardingSlide extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final bool isLast;
  final VoidCallback onGetStarted;

  const BoardingSlide({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    this.isLast = false,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 300, width: 300, fit: BoxFit.cover),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          if (isLast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
