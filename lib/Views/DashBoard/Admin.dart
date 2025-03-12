import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Controllers/adminController.dart';
import 'package:provider/provider.dart';
import '../../Models/userModels.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
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
    if (adminController != null) {
      try {
        await Future.wait([
          adminController.loadUsers(),
          adminController.loadProjects(),
          adminController.loadContractors(),
          adminController.loadSupportTickets(),
          adminController.loadContent(),
        ]);
      } catch (e) {
        Get.snackbar('Error', 'Failed to load data: $e',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
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
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
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
    return Consumer<AdminController?>(
      builder: (context, controller, _) {
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
          backgroundColor: const Color(0xFFE3F2FD),
          appBar: _buildAppBar(),
          drawer: _buildDrawer(),
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
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Changed to light for white icons
      ),
      backgroundColor: const Color(0xFF1976D2), // Changed to deep blue
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), // Changed to white
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
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
          icon: const Icon(Icons.notifications_outlined, color: Colors.white), // Changed to white
          onPressed: () => Get.toNamed('/notifications'),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Consumer<AdminController?>(
              builder: (context, controller, _) => Text(
                controller != null
                    ? controller.supportTickets
                    .where((t) => t['status'] == 'pending')
                    .length
                    .toString()
                    : '0',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: CircleAvatar(
        backgroundColor: const Color(0xFF2196F3), // Kept for contrast
        radius: 18,
        child: Text(
          _authController.currentUser.value?.email?[0].toUpperCase() ?? 'A',
          style: const TextStyle(
            color: Colors.white, // Already white
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                _buildSectionTitle('Quick Actions'),
                const SizedBox(height: 16),
                _buildActionsGrid(),
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
          colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
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
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userData.email ?? 'Admin',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
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
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1E1E),
      ),
    );
  }

  Widget _buildActionsGrid() {
    final List<Map<String, dynamic>> actions = [
      {
        'title': 'Manage Users',
        'icon': Icons.people,
        'color': const Color(0xFF2196F3),
        'onTap': () => Get.toNamed('/manage-users'),
      },
      {
        'title': 'Manage Projects',
        'icon': Icons.construction,
        'color': const Color(0xFF4CAF50),
        'onTap': () => Get.toNamed('/manage-projects-admin'),
      },
      {
        'title': 'Manage Contractors',
        'icon': Icons.engineering,
        'color': const Color(0xFFFFC107),
        'onTap': () => Get.toNamed('/manage-contractors'),
      },
      {
        'title': 'Support Tickets',
        'icon': Icons.support_agent,
        'color': const Color(0xFFE91E63),
        'onTap': () => Get.toNamed('/support-tickets'),
      },
      {
        'title': 'Content Management',
        'icon': Icons.edit_document,
        'color': const Color(0xFF9C27B0),
        'onTap': () => Get.toNamed('/content-management'),
      },
      {
        'title': 'Analytics',
        'icon': Icons.analytics_outlined,
        'color': const Color(0xFF607D8B),
        'onTap': () => Get.toNamed('/admin-analytics'),
      },
      {
        'title': 'Help & Support',
        'icon': Icons.help_outline,
        'color': const Color(0xFF607D8B),
        'onTap': () => Get.toNamed('/admin-help'),
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
      itemCount: actions.length,
      itemBuilder: (context, index) => _buildActionCard(actions[index]),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: action['color'].withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action['onTap'],
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(action['icon'], color: action['color'], size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                action['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: action['color'].withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDrawerItem(icon: Icons.dashboard_outlined, title: 'Dashboard', onTap: () => Navigator.pop(context)),
                  _buildDrawerItem(icon: Icons.people, title: 'Manage Users', onTap: () { Navigator.pop(context); Get.toNamed('/manage-users'); }),
                  _buildDrawerItem(icon: Icons.construction, title: 'Manage Projects', onTap: () { Navigator.pop(context); Get.toNamed('/manage-projects-admin'); }),
                  _buildDrawerItem(icon: Icons.engineering, title: 'Manage Contractors', onTap: () { Navigator.pop(context); Get.toNamed('/manage-contractors'); }),
                  _buildDrawerItem(icon: Icons.support_agent, title: 'Support Tickets', onTap: () { Navigator.pop(context); Get.toNamed('/support-tickets'); }),
                  _buildDrawerItem(icon: Icons.edit_document, title: 'Content Management', onTap: () { Navigator.pop(context); Get.toNamed('/content-management'); }),
                  _buildDrawerItem(icon: Icons.analytics_outlined, title: 'Analytics', onTap: () { Navigator.pop(context); Get.toNamed('/admin-analytics'); }),
                  const Divider(height: 32),
                  _buildDrawerItem(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
                  _buildDrawerItem(icon: Icons.help_outline, title: 'Help & Support', onTap: () { Navigator.pop(context); Get.toNamed('/admin-help'); }),
                  _buildDrawerItem(icon: Icons.logout, title: 'Sign Out', onTap: () { Navigator.pop(context); _handleSignOut(); }, color: Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2196F3).withOpacity(0.1),
            ),
            child: const Center(child: Icon(Icons.admin_panel_settings_outlined, size: 40, color: Color(0xFF2196F3))),
          ),
          const SizedBox(height: 16),
          Text(
            _authController.currentUser.value?.email ?? 'Admin',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Administrator',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF1976D2), size: 24),
      title: Text(title, style: TextStyle(color: color ?? const Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}