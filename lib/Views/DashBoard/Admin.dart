import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddyfyp/Controllers/authControllers.dart';

import '../Shared/widgets/appBarColor.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  final AuthController _authController = Get.find<AuthController>();

  Future<void> _handleSignOut() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kAppBarColor,
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
                    'User Management',
                    Icons.people,
                        () => Get.toNamed('/user-management'),
                    const Color(0xFF66BB6A),
                  ),
                  _buildDashboardCard(
                    'Project Monitoring',
                    Icons.construction,
                        () => Get.toNamed('/project-monitoring'),
                    const Color(0xFF42A5F5),
                  ),
                  _buildDashboardCard(
                    'Reports & Analytics',
                    Icons.bar_chart,
                        () => Get.toNamed('/reports'),
                    const Color(0xFFFFCA28),
                  ),
                  _buildDashboardCard(
                    'Settings',
                    Icons.settings,
                        () => Get.toNamed('/settings'),
                    const Color(0xFFAB47BC),
                  ),
                  _buildDashboardCard(
                    'Content Management',
                    Icons.article,
                        () => Get.toNamed('/content-management'),
                    const Color(0xFFEF5350),
                  ),
                  _buildDashboardCard(
                    'Help & Support',
                    Icons.help_outline,
                        () => Get.toNamed('/support'),
                    const Color(0xFF64B5F6),
                  ),
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
            'Welcome, ${userData.name ?? "Admin"}',
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
