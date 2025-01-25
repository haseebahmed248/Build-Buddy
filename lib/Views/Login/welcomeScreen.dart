import 'package:flutter/material.dart';
import 'package:buildbuddyfyp/views/DashBoard/stakeHolderSelection.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Moved to a separate class for better organization
  static const _gradientColors = [
    Color(0xFF1E3799),  // Deep Blue
    Color(0xFF4834DF),  // Royal Blue
  ];

  final List<QuickAction> _quickActions = [
    QuickAction(
      icon: Icons.construction_outlined,
      label: 'Projects',
      color: const Color(0xFF1E3799),
      onTap: () {/* Navigate to Projects */},
    ),
    QuickAction(
      icon: Icons.storefront_outlined,
      label: 'Vendors',
      color: const Color(0xFF4834DF),
      onTap: () {/* Navigate to Vendors */},
    ),
    QuickAction(
      icon: Icons.engineering_outlined,
      label: 'Architect Plans',
      color: const Color(0xFF3498DB),
      onTap: () {/* Navigate to Architect Plans */},
    ),
    QuickAction(
      icon: Icons.attach_money_outlined,
      label: 'Payments',
      color: const Color(0xFF2ECC71),
      onTap: () {/* Navigate to Payments */},
    ),
    QuickAction(
      icon: Icons.file_copy_outlined,
      label: 'Documents',
      color: const Color(0xFFF1C40F),
      onTap: () {/* Navigate to Documents */},
    ),
    QuickAction(
      icon: Icons.chat_outlined,
      label: 'Chat',
      color: const Color(0xFFE74C3C),
      onTap: () {/* Navigate to Chat */},
    ),
    QuickAction(
      icon: Icons.payment_outlined,
      label: 'Invoices',
      color: const Color(0xFF9B59B6),
      onTap: () {/* Navigate to Invoices */},
    ),
    QuickAction(
      icon: Icons.star_border_outlined,
      label: 'Reviews',
      color: const Color(0xFFE67E22),
      onTap: () {/* Navigate to Reviews */},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Build Buddy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your Construction Management Companion',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {/* Handle notifications */},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildBackgroundDecorations(),
        RefreshIndicator(
          onRefresh: () async {
            // Implement refresh logic
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(),
                  const SizedBox(height: 24),
                  _buildUpdatesSection(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: _buildDecorativeCircle(
            const Color(0xFF4834DF),
            200,
          ),
        ),
        Positioned(
          bottom: -80,
          left: -60,
          child: _buildDecorativeCircle(
            const Color(0xFF1E3799),
            200,
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      decoration: _buildCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF3498DB),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Good Morning!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'User',
                  style: TextStyle(
                    color: Color(0xFF1E3799),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StakeholderSelection(),
                ),
              );
            },
            child: const Text(
              'View Profile',
              style: TextStyle(
                color: Color(0xFF4834DF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3799),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 600 ? 6 : 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: _quickActions.length,
              itemBuilder: (context, index) => QuickActionCard(
                action: _quickActions[index],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpdatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest Updates',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3799),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: _buildCardDecoration(),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              UpdateItem(
                icon: Icons.architecture,
                title: 'New Project Start',
                subtitle: 'Residential Complex Project Initialized',
                color: const Color(0xFF3498DB),
                onTap: () {/* Handle tap */},
              ),
              const Divider(height: 1),
              UpdateItem(
                icon: Icons.payments_outlined,
                title: 'Payment Update',
                subtitle: 'Last Invoice Processed Successfully',
                color: const Color(0xFF2ECC71),
                onTap: () {/* Handle tap */},
              ),
              const Divider(height: 1),
              UpdateItem(
                icon: Icons.file_copy_outlined,
                title: 'Document Review',
                subtitle: 'Architect Plans Approved',
                color: const Color(0xFFF1C40F),
                onTap: () {/* Handle tap */},
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF4834DF),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        // Handle navigation
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }
}

// Extracted into separate classes for better reusability
class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const QuickActionCard({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate appropriate sizes based on constraints
              final iconSize = constraints.maxWidth * 0.3;
              final fontSize = constraints.maxWidth * 0.15;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: iconSize,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        action.label,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }
}
class UpdateItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const UpdateItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E3799),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}