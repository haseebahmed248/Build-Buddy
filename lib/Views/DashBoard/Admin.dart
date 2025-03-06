import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart'; // Correct import for AuthController
import 'package:buildbuddy/Controllers/adminController.dart'; // Correct import for AdminController
import 'package:provider/provider.dart';
import '../../Models/userModels.dart';
import '../Shared/widgets/appBarColor.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final adminController = Provider.of<AdminController?>(context, listen: false);
    print('Loading initial data: adminController=${adminController != null ? "present" : "null"}, user=${_authController.currentUser.value?.email}, role=${_authController.currentUser.value?.role}');
    if (adminController != null) {
      try {
        await Future.wait([
          adminController.loadUsers(),
          adminController.loadProjects(),
          adminController.loadContractors(),
          adminController.loadSupportTickets(),
          adminController.loadContent(),
        ] as Iterable<Future<void>>); // Cast to Iterable<Future<void>>
      } catch (e) {
        Get.snackbar('Error', 'Failed to load data: $e',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    } else {
      print('AdminController is null, skipping data load');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignOut() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _authController.signOut();
        Get.offAllNamed('/stakeholder');
      } catch (e) {
        Get.snackbar('Error', 'Failed to sign out: $e',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Provider.of<AdminController?>(context, listen: false);
    print('AdminDashboard build: adminController=${adminController != null ? "present" : "null"}, user=${_authController.currentUser.value?.email}, role=${_authController.currentUser.value?.role}');
    return Consumer<AdminController?>(
      builder: (context, controller, _) {
        print('Consumer builder: controller=${controller != null ? "present" : "null"}, user=${_authController.currentUser.value?.email}, role=${_authController.currentUser.value?.role}');
        if (controller == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Access Denied: Admin privileges required',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: _buildAppBar(),
          body: Obx(() {
            final userData = _authController.currentUser.value;
            if (userData == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!userData.isAdmin) {
              return const Center(child: Text('Unauthorized Access: Admins Only'));
            }
            return _buildBody(userData, controller);
          }),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: kAppBarColor,
      title: const Text('Build Buddy Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
      actions: [
        _buildNotificationButton(),
        _buildProfileButton(),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Get.toNamed('/notifications'),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: Consumer<AdminController?>(
              builder: (context, controller, _) => Text(
                controller != null
                    ? controller.supportTickets
                    .where((t) => t['status'] == 'pending')
                    .length
                    .toString()
                    : '0',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      onPressed: _handleSignOut,
    );
  }

  Widget _buildBody(UserData userData, AdminController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage != null) {
      return Center(child: Text('Error: ${controller.errorMessage}'));
    }
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(userData),
                const SizedBox(height: 24),
                _buildQuickStats(controller),
                const SizedBox(height: 24),
                _buildSectionTitle('Admin Quick Access'),
                const SizedBox(height: 16),
                _buildDashboardGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(UserData userData) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.toNamed('/profile'),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back!',
                          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: 8),
                      Text(userData.email ?? 'Admin',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration:
                  BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(AdminController controller) {
    return Row(
      children: [
        _buildStatCard('Total\nUsers', controller.users.length.toString(), Icons.people, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard('Active\nProjects', controller.projects.length.toString(), Icons.construction, Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard(
            'Pending\nTickets',
            controller.supportTickets.where((t) => t['status'] == 'pending').length.toString(),
            Icons.pending,
            Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24, semanticLabel: title),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)));
  }

  Widget _buildDashboardGrid() {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'User Management',
        'icon': Icons.people,
        'color': const Color(0xFF2196F3),
        'route': '/user-management'
      },
      {
        'title': 'Project Monitoring',
        'icon': Icons.construction,
        'color': const Color(0xFF4CAF50),
        'route': '/project-monitoring'
      },
      {
        'title': 'Reports',
        'icon': Icons.bar_chart,
        'color': const Color(0xFFFFC107),
        'route': '/reports'
      },
      {
        'title': 'Content Management',
        'icon': Icons.article,
        'color': const Color(0xFFE91E63),
        'route': '/content-management'
      },
      {
        'title': 'Settings',
        'icon': Icons.settings,
        'color': const Color(0xFF9C27B0),
        'route': '/admin-settings'
      },
      {
        'title': 'Support',
        'icon': Icons.help_outline,
        'color': const Color(0xFF607D8B),
        'route': '/admin-support'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildDashboardCard(
          items[index]['title'],
          items[index]['icon'],
          items[index]['color'],
              () => Get.toNamed(items[index]['route']),
        );
      },
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28, semanticLabel: title),
              ),
              const SizedBox(height: 12),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color.withOpacity(0.8))),
            ],
          ),
        ),
      ),
    );
  }
}