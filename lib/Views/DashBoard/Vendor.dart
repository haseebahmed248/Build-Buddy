import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Controllers/vendorController.dart';
import 'package:buildbuddy/Views/Shared/HelpandSupport.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({Key? key}) : super(key: key);

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    ) ?? false;

    if (confirm) {
      try {
        await _authController.signOut();
        Get.offAllNamed('/stakeholder');
      } catch (e) {
        Get.snackbar('Error', 'Failed to sign out: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<VendorController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${controller.errorMessage}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.refreshData();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return _buildBody(controller);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Changed to light for white icons on blue background
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
    return Consumer<VendorController>(
      builder: (context, controller, child) => Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white), // Changed to white
            onPressed: () => Get.toNamed('/vendor-notifications'),
          ),
          if (controller.notifications.isNotEmpty)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${controller.notifications.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: CircleAvatar(
        backgroundColor: const Color(0xFF2196F3), // Kept as is for contrast with AppBar
        radius: 18,
        child: Text(
          _authController.currentUser.value?.email?[0].toUpperCase() ?? 'V',
          style: const TextStyle(
            color: Colors.white, // Already white, no change needed
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(VendorController controller) {
    return RefreshIndicator(
      onRefresh: () async => await controller.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(controller),
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
    );
  }

  Widget _buildWelcomeCard(VendorController controller) {
    // Extract the username part before the @ symbol
    String displayName = _authController.currentUser.value?.email != null &&
        _authController.currentUser.value!.email.contains('@')
        ? _authController.currentUser.value!.email.split('@')[0]
        : 'Vendor';

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
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
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
                        displayName, // Updated to show only the username part
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
                  child: const Icon(Icons.store, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildQuickStats(VendorController controller) {
    final materials = controller.materials;
    final totalSales = controller.orders.fold<double>(0, (sum, order) => sum + (order.amount ?? 0.0));
    return Row(
      children: [
        _buildStatCard('Active\nMaterials', '${materials.length}', Icons.inventory_2, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard(
            'Pending\nOrders',
            '${controller.orders.where((o) => o.status == 'Pending').length}',
            Icons.shopping_cart,
            Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard('Total\nSales', '\$${totalSales.toStringAsFixed(2)}', Icons.attach_money, Colors.green),
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
    final actions = [
      {'title': 'Manage Products', 'icon': Icons.inventory_2, 'color': const Color(0xFF2196F3), 'onTap': () => Get.toNamed('/manage-products')},
      {'title': 'Orders', 'icon': Icons.shopping_cart_outlined, 'color': const Color(0xFF4CAF50), 'onTap': () => Get.toNamed('/vendor-orders')},
      {'title': 'Invoices', 'icon': Icons.receipt_outlined, 'color': const Color(0xFFFFC107), 'onTap': () => Get.toNamed('/vendor-invoices')},
      {'title': 'Messages', 'icon': Icons.message_outlined, 'color': const Color(0xFFE91E63), 'onTap': () => Get.toNamed('/vendor-messages')},
      {'title': 'Reviews', 'icon': Icons.star_outline, 'color': const Color(0xFF9C27B0), 'onTap': () => Get.toNamed('/vendor-reviews')},
      {'title': 'Analytics', 'icon': Icons.analytics_outlined, 'color': const Color(0xFF607D8B), 'onTap': () => Get.toNamed('/vendor-analytics')},
      {'title': 'Help & Support', 'icon': Icons.help_outline, 'color': const Color(0xFF607D8B), 'onTap': () => Get.toNamed('/vendor-help')},
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
                  _buildDrawerItem(icon: Icons.inventory_2, title: 'Manage Products', onTap: () { Navigator.pop(context); Get.toNamed('/manage-products'); }),
                  _buildDrawerItem(icon: Icons.shopping_cart_outlined, title: 'Orders', onTap: () { Navigator.pop(context); Get.toNamed('/vendor-orders'); }),
                  _buildDrawerItem(icon: Icons.receipt_outlined, title: 'Invoices', onTap: () { Navigator.pop(context); Get.toNamed('/vendor-invoices'); }),
                  _buildDrawerItem(icon: Icons.message_outlined, title: 'Messages', onTap: () { Navigator.pop(context); Get.toNamed('/vendor-messages'); }),
                  _buildDrawerItem(icon: Icons.star_outline, title: 'Reviews', onTap: () { Navigator.pop(context); Get.toNamed('/vendor-reviews'); }),
                  _buildDrawerItem(icon: Icons.analytics_outlined, title: 'Analytics', onTap: () { Navigator.pop(context); Get.toNamed('/vendor-analytics'); }),
                  const Divider(height: 32),
                  _buildDrawerItem(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
                  _buildDrawerItem(icon: Icons.help_outline, title: 'Help & Support', onTap: () { Navigator.pop(context); Get.toNamed('/vendor-help'); }),
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
            child: const Center(child: Icon(Icons.store, size: 40, color: Color(0xFF2196F3))),
          ),
          const SizedBox(height: 16),
          Text(
            _authController.currentUser.value?.email ?? 'Vendor',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Professional Vendor',
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