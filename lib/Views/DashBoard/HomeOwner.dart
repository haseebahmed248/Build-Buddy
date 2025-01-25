
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddyfyp/Controllers/authControllers.dart';

import '../Shared/widgets/appBarColor.dart';

class HomeOwnerDashboard extends StatefulWidget {
  const HomeOwnerDashboard({super.key});

  @override
  HomeOwnerDashboardState createState() => HomeOwnerDashboardState();
}

class HomeOwnerDashboardState extends State<HomeOwnerDashboard> {
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
          'Homeowner Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
       backgroundColor: kAppBarColor,
        //backgroundColor: const Color(0xFFE3F2FD),
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Get.offAllNamed('/stakeholder');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black87),
            onPressed: () => Get.toNamed('/notifications'),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(userData),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    'My Projects',
                    Icons.construction,
                        () => Get.toNamed('/my-projects'),
                     const Color(0xFF42A5F5),
                    //const Color(0xFF81C784),
                  ),
                  _buildDashboardCard(
                    'Find Professionals',
                    Icons.people,
                        () => Get.toNamed('/find-professionals'),
                    //const Color(0xFF4FC3F7),
                    const Color(0xFF66BB6A),
                  ),
                  _buildDashboardCard(
                    'Messages',
                    Icons.message,
                        () => Get.toNamed('/messages'),
                   // const Color(0xFFFFB74D),
                    const Color(0xFFFFCA28),
                  ),
                  _buildDashboardCard(
                    'Settings',
                    Icons.settings,
                        () => Get.toNamed('/settings'),
                    //const Color(0xFFF06292),
                    const Color(0xFFAB47BC), // Purple
                  ),
                  _buildDashboardCard(
                    'Payments & Invoices',
                    Icons.attach_money,
                        () => Get.toNamed('/payments'),
                    //const Color(0xFF9575CD),
                    const Color(0xFFEF5350), // Red
                  ),
                  _buildDashboardCard(
                    'Rate & Review',
                    Icons.star,
                        () => Get.toNamed('/rate-review'),
                    const Color(0xFFFF8A65),
                  ),
                  _buildDashboardCard(
                    'Help & Support',
                    Icons.help_outline,
                        () => Get.toNamed('/support'),
                    const Color(0xFF64B5F6),
                  ),
                 /* _buildDashboardCard(
                    'Notifications',
                    Icons.notifications,
                        () => Get.toNamed('/notifications'),
                    const Color(0xFF90CAF9),
                  ),*/
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeCard(userData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFF81D4FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${userData.name ?? "Homeowner"}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userData.email ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      String title, IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
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











