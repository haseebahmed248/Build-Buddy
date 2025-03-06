import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({Key? key}) : super(key: key);

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic> vendorData = {};

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
    _fetchVendorData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendorData() async {
    final vendorId = _authController.currentUser.value?.uid;
    if (vendorId != null) {
      final snapshot = await _database.child('vendors/$vendorId').get();
      if (snapshot.exists) {
        setState(() {
          vendorData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    final bool confirm = await showDialog(
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
    ) ?? false;

    if (confirm) {
      try {
        await _authController.signOut();
        Get.offAllNamed('/stakeholder');
      } catch (e) {
        Get.snackbar('Error', 'Failed to sign out: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white,
            borderRadius: 10,
            margin: const EdgeInsets.all(10));
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
        child: Obx(() {
          final userData = _authController.currentUser.value;
          if (userData == null) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3))));
          }
          return _buildBody(userData);
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E1E1E)),
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
    return StreamBuilder(
      stream: _database.child('vendors/${_authController.currentUser.value?.uid}/notifications').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final notifications = snapshot.data!.snapshot.value as Map?;
        final count = notifications?.length ?? 0;
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1E1E1E)),
              onPressed: () => Get.toNamed('/vendor-notifications'),
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: CircleAvatar(
        backgroundColor: const Color(0xFF2196F3),
        radius: 18,
        child: Text(
          _authController.currentUser.value?.email?[0].toUpperCase() ?? 'V',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBody(userData) {
    return RefreshIndicator(
      onRefresh: _fetchVendorData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(userData),
              const SizedBox(height: 24),
              _buildQuickStats(),
              const SizedBox(height: 24),
              _buildSectionTitle('Recent Activities'),
              const SizedBox(height: 16),
              _buildRecentActivities(),
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

  Widget _buildWelcomeCard(userData) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF4DB6AC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF00897B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back!', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
                          const SizedBox(height: 8),
                          Text(userData.email ?? 'Vendor', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.store, color: Colors.white, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Verified Vendor', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return StreamBuilder(
      stream: _database.child('vendors/${_authController.currentUser.value?.uid}').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final data = snapshot.data!.snapshot.value as Map?;
        final products = data?['products'] as Map? ?? {};
        final orders = data?['orders'] as Map? ?? {};
        final totalSales = orders.values.fold<double>(0, (sum, order) => sum + (order['amount'] as num? ?? 0));
        return Row(
          children: [
            _buildStatCard('Active\nProducts', '${products.length}', Icons.inventory_2, Colors.blue),
            const SizedBox(width: 12),
            _buildStatCard('Pending\nOrders', '${orders.values.where((o) => o['status'] == 'Pending').length}', Icons.shopping_cart, Colors.orange),
            const SizedBox(width: 12),
            _buildStatCard('Total\nSales', '\$${totalSales.toStringAsFixed(2)}', Icons.attach_money, Colors.green),
          ],
        );
      },
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)));
  }

  Widget _buildRecentActivities() {
    return StreamBuilder(
      stream: _database.child('vendors/${_authController.currentUser.value?.uid}/orders').orderByChild('timestamp').limitToLast(2).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final orders = snapshot.data!.snapshot.value as Map?;
        if (orders == null) return const Text('No recent activities');
        final List<Widget> activities = [];
        orders.forEach((key, value) {
          activities.add(_buildActivityCard(
            'Order #${value['orderId']}',
            'Status: ${value['status']}',
            value['timestamp']?.toString() ?? 'Just now',
            Icons.shopping_cart,
            Colors.blue,
          ));
          activities.add(const SizedBox(height: 12));
        });
        return Column(children: activities);
      },
    );
  }

  Widget _buildActivityCard(String title, String description, String time, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsGrid() {
    final List<Map<String, dynamic>> actions = [
      {'title': 'Manage Products', 'icon': Icons.inventory_2, 'color': const Color(0xFF2196F3), 'onTap': () => Get.toNamed('/manage-products')},
      {'title': 'Orders', 'icon': Icons.shopping_cart_outlined, 'color': const Color(0xFF4CAF50), 'onTap': () => Get.toNamed('/vendor-orders')},
      {'title': 'Invoices', 'icon': Icons.receipt_outlined, 'color': const Color(0xFFFFC107), 'onTap': () => Get.toNamed('/vendor-invoices')},
      {'title': 'Messages', 'icon': Icons.message_outlined, 'color': const Color(0xFFE91E63), 'onTap': () => Get.toNamed('/vendor-messages')},
      {'title': 'Reviews', 'icon': Icons.star_outline, 'color': const Color(0xFF9C27B0), 'onTap': () => Get.toNamed('/vendor-reviews')},
      {'title': 'Analytics', 'icon': Icons.analytics_outlined, 'color': const Color(0xFF607D8B), 'onTap': () => Get.toNamed('/vendor-analytics')},
      {'title': 'Support', 'icon': Icons.help_outline, 'color': const Color(0xFF795548), 'onTap': () => Get.toNamed('/vendor-support')},
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
        boxShadow: [BoxShadow(color: action['color'].withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
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
                decoration: BoxDecoration(color: action['color'].withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(action['icon'], color: action['color'], size: 28),
              ),
              const SizedBox(height: 12),
              Text(action['title'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: action['color'].withOpacity(0.8))),
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
                  _buildDrawerItem(icon: Icons.help_outline, title: 'Help & Support', onTap: () { Navigator.pop(context); Get.toNamed('/vendor-support'); }),
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00897B).withOpacity(0.1)),
            child: const Center(child: Icon(Icons.store, size: 40, color: Color(0xFF00897B))),
          ),
          const SizedBox(height: 16),
          Text(_authController.currentUser.value?.email ?? 'Vendor', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('Professional Vendor', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF00897B), size: 24),
      title: Text(title, style: TextStyle(color: color ?? const Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}