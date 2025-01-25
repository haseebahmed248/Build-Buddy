import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddyfyp/Views/Login/startedScreen.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Contractor/ManageProjects.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Contractor/MaterialOrders.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Contractor/Messages.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Contractor/Payments.dart';
import 'package:buildbuddyfyp/Views/DashBoard/Contractor/RatingAndReviews.dart';
import 'package:buildbuddyfyp/Controllers/authControllers.dart';

class ContractorDashboard extends StatefulWidget {
  const ContractorDashboard({super.key});

  @override
  ContractorDashboardState createState() => ContractorDashboardState();
}

class ContractorDashboardState extends State<ContractorDashboard> {
  final AuthController _authController = Get.find<AuthController>();

  Future<void> _handleSignOut() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      try {
        await _authController.signOut();
        Get.offAllNamed('/stakeholder');
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to sign out: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contractor Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color(0xFFE1F5FE),
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GetStartedScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()), // Navigate to profile screen
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: Obx(() {
        final userData = _authController.currentUser.value;
        if (userData == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE1F5FE), Color(0xFF81D4FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${userData.name ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Here’s an overview of your activities:',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    'Manage Projects',
                    Icons.construction,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManageProjectsScreen()),
                      );
                    },
                    Colors.orange,
                  ),
                  _buildDashboardCard(
                    'Material Orders',
                    Icons.inventory,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MaterialOrdersScreen()),
                      );
                    },
                    Colors.green,
                  ),
                  _buildDashboardCard(
                    'Messages',
                    Icons.message,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MessagesScreen()),
                      );
                    },
                    Colors.purple,
                  ),
                  _buildDashboardCard(
                    'Payments',
                    Icons.payment,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PaymentsScreen()),
                      );
                    },
                    Colors.teal,
                  ),
                  _buildDashboardCard(
                    'Ratings & Reviews',
                    Icons.star,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RatingsReviewsScreen()),
                      );
                    },
                    Colors.amber,
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color(0xFFE1F5FE),
        elevation: 5,
      ),
      body: const Center(
        child: Text(
          'Profile Information Goes Here!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
