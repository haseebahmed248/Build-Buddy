import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddyfyp/Controllers/authControllers.dart';

class VendorDashboard extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/stakeholder');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/stakeholder');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authController.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/stakeholder', (route) => false);
            },
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final userData = _authController.currentUser.value;

                if (userData == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.withOpacity(0.2),
                        Colors.teal,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${userData.name ?? "Vendor"}!',
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
                );
              }),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Manage Products',
                    icon: Icons.inventory,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/manage-products');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Orders',
                    icon: Icons.shopping_cart,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, '/vendor-orders');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Invoices',
                    icon: Icons.receipt_long,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(context, '/vendor-invoices');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Messages',
                    icon: Icons.message,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pushNamed(context, '/vendor-messages');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Ratings & Reviews',
                    icon: Icons.star_rate,
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.pushNamed(context, '/vendor-reviews');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Analytics',
                    icon: Icons.bar_chart,
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pushNamed(context, '/vendor-analytics');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Notifications',
                    icon: Icons.notifications,
                    color: Colors.deepOrange,
                    onTap: () {
                      Navigator.pushNamed(context, '/vendor-notifications');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Support',
                    icon: Icons.help_outline,
                    color: Colors.deepOrange,
                    onTap: () {
                      Navigator.pushNamed(context, '/vendor-support');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDashboardCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



















/*
import 'package:flutter/material.dart';

class VendorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Dashboard'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
      ),
      body: Stack(
        children: [
          // Background Circles
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 350,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            bottom: -270,
            right: -150,
            child: Container(
              width: 500,
              height: 450,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),

          // Grid of Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'Manage Products',
                  icon: Icons.inventory,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, '/manage-products');
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Orders',
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, '/vendor-orders');
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Invoices',
                  icon: Icons.receipt_long,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, '/vendor-invoices');
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Messages',
                  icon: Icons.message,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, '/vendor-messages');
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Ratings & Reviews',
                  icon: Icons.star_rate,
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pushNamed(context, '/vendor-reviews');
                  },
                ),

                // New Cards for Analytics, Notifications, and Support
                _buildDashboardCard(
                  context,
                  title: 'Analytics',
                  icon: Icons.bar_chart,
                  color: Colors.indigo,
                  onTap: () {
                    // Navigate to the analytics screen
                    Navigator.pushNamed(context, '/vendor-analytics');
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Notifications',
                  icon: Icons.notifications,
                  color: Colors.yellow,
                  onTap: () {
                    // Navigate to notifications
                    Navigator.pushNamed(context, '/vendor-notifications');
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Support',
                  icon: Icons.help_outline,
                  color: Colors.deepOrange,
                  onTap: () {
                    // Navigate to the support page
                    Navigator.pushNamed(context, '/vendor-support');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}









*/
