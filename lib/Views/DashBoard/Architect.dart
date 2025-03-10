import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Views/DashBoard/Architect/ViewProjectPlans.dart';
import 'package:buildbuddy/Views/DashBoard/Architect/ConsultWithHomeowners.dart';
import 'package:buildbuddy/Views/DashBoard/Architect/ReviewContractorTasks.dart';
import 'package:buildbuddy/Views/DashBoard/Architect/messages.dart';

class ArchitectDashboardController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final AuthController _authController = Get.find<AuthController>();

  final activeProjects = 0.obs;
  final pendingReviews = 0.obs;
  final newMessages = 0.obs;
  final projectsList = <Map<String, dynamic>>[].obs;
  final designsList = <Map<String, dynamic>>[].obs; // Added for design management
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchDashboardData();
  }

  void _fetchDashboardData() async {
    try {
      isLoading.value = true;
      final architectUid = _authController.currentUser.value?.uid;
      if (architectUid == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Fetch active projects
      final projectsRef = _database.child('projects');
      projectsRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final projects = <Map<String, dynamic>>[];
          int activeCount = 0;
          data.forEach((key, value) {
            final project = Map<String, dynamic>.from(value);
            if (project['assignedArchitectId'] == architectUid &&
                project['status'] != 'completed') { // Updated to match SRS terminology
              activeCount++;
              projects.add({
                'id': key,
                'title': project['title'] ?? 'Untitled Project',
                'status': project['status'] ?? 'inProgress',
                'progress': (project['progress'] ?? 0).toString() + '%',
                'color': project['status'] == 'pending' ? Colors.orange : Colors.blue,
              });
            }
          });
          activeProjects.value = activeCount;
          projectsList.assignAll(projects);
        }
      });

      // Fetch pending reviews
      final userRef = _database.child('users/architect/$architectUid');
      userRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          pendingReviews.value = data['pendingReviews'] ?? 0;
        }
      });

      // Fetch new messages
      final messagesRef = _database.child('messages/$architectUid');
      messagesRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          int unreadCount = 0;
          data.forEach((key, value) {
            final message = Map<String, dynamic>.from(value);
            if (message['read'] == false) {
              unreadCount++;
            }
          });
          newMessages.value = unreadCount;
        } else {
          newMessages.value = 0;
        }
      });

      // Fetch designs (new feature for architect integration)
      final designsRef = _database.child('designs/$architectUid');
      designsRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final designs = <Map<String, dynamic>>[];
          data.forEach((key, value) {
            final design = Map<String, dynamic>.from(value);
            designs.add({
              'id': key,
              'projectId': design['projectId'],
              'title': design['title'] ?? 'Untitled Design',
              'version': design['version'] ?? '1.0',
              'status': design['status'] ?? 'Draft',
            });
          });
          designsList.assignAll(designs);
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to upload a new design (for version control)
  Future<void> uploadDesign(String projectId, String title, String fileUrl) async {
    try {
      final architectUid = _authController.currentUser.value?.uid;
      if (architectUid == null) return;

      final designRef = _database.child('designs/$architectUid').push();
      await designRef.set({
        'projectId': projectId,
        'title': title,
        'fileUrl': fileUrl,
        'version': '1.0', // Initial version
        'status': 'Draft',
        'createdAt': DateTime.now().toIso8601String(),
      });
      Get.snackbar('Success', 'Design uploaded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload design: $e');
    }
  }
}

class ArchitectDashboard extends StatefulWidget {
  const ArchitectDashboard({super.key});

  @override
  State<ArchitectDashboard> createState() => _ArchitectDashboardState();
}

class _ArchitectDashboardState extends State<ArchitectDashboard> with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ArchitectDashboardController _dashboardController = Get.put(ArchitectDashboardController());

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
        Get.snackbar('Error', 'Failed to sign out: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
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
          if (_dashboardController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3))));
          }
          final userData = _authController.currentUser.value;
          if (userData == null) {
            return const Center(child: Text('User not authenticated'));
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
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1E1E1E)),
          onPressed: () {},
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Obx(() => Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              _dashboardController.newMessages.value.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: CircleAvatar(
        backgroundColor: const Color(0xFF2196F3),
        radius: 18,
        child: Text(
          _authController.currentUser.value?.email?[0].toUpperCase() ?? 'A',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBody(userData) {
    return RefreshIndicator(
      onRefresh: () async {
        _dashboardController._fetchDashboardData();
      },
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
              _buildSectionTitle('Project Overview'),
              const SizedBox(height: 16),
              _buildProjectsGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('Design Management'), // New section
              const SizedBox(height: 16),
              _buildDesignsGrid(), // New grid for designs
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
        gradient: const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF2196F3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF1E88E5).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
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
                          Text(userData.email ?? 'Architect', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.architecture, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Obx(() => _buildStatCard('Active\nProjects', _dashboardController.activeProjects.value.toString(), Icons.architecture, Colors.blue)),
        const SizedBox(width: 12),
        Obx(() => _buildStatCard('Pending\nReviews', _dashboardController.pendingReviews.value.toString(), Icons.rate_review, Colors.orange)),
        const SizedBox(width: 12),
        Obx(() => _buildStatCard('New\nMessages', _dashboardController.newMessages.value.toString(), Icons.message, Colors.green)),
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

  Widget _buildProjectsGrid() {
    return Obx(() {
      if (_dashboardController.projectsList.isEmpty) {
        return const Center(child: Text('No projects available'));
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5),
        itemCount: _dashboardController.projectsList.length,
        itemBuilder: (context, index) {
          final project = _dashboardController.projectsList[index];
          return _buildProjectCard(project['title'], project['status'], project['progress'], project['color']);
        },
      );
    });
  }

  Widget _buildProjectCard(String title, String status, String progress, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/view-project-plans'), // Navigate to detailed view
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(status, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                    ),
                    const Spacer(),
                    Text(progress, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: double.parse(progress.replaceAll('%', '')) / 100,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesignsGrid() { // New method for design management
    return Obx(() {
      if (_dashboardController.designsList.isEmpty) {
        return const Center(child: Text('No designs uploaded yet'));
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5),
        itemCount: _dashboardController.designsList.length,
        itemBuilder: (context, index) {
          final design = _dashboardController.designsList[index];
          return _buildDesignCard(design['title'], design['version'], design['status'], design['projectId']);
        },
      );
    });
  }

  Widget _buildDesignCard(String title, String version, String status, String projectId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDesignUploadDialog(projectId), // Allow updating design
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Version: $version', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(status, style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDesignUploadDialog(String projectId) { // New dialog for uploading designs
    final titleController = TextEditingController();
    final fileUrlController = TextEditingController(); // Placeholder for file URL (e.g., from Firebase Storage)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Design'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Design Title'),
            ),
            TextField(
              controller: fileUrlController,
              decoration: const InputDecoration(labelText: 'Design File URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dashboardController.uploadDesign(projectId, titleController.text, fileUrlController.text);
              Navigator.pop(context);
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsGrid() {
    final List<Map<String, dynamic>> actions = [
      {'title': 'View Plans', 'icon': Icons.architecture, 'color': const Color(0xFF2196F3), 'onTap': () => Get.toNamed('/view-project-plans')},
      {'title': 'Consultations', 'icon': Icons.people_outline, 'color': const Color(0xFF4CAF50), 'onTap': () => Get.toNamed('/consult-homeowners')},
      {'title': 'Reviews', 'icon': Icons.rate_review_outlined, 'color': const Color(0xFFFFC107), 'onTap': () => Get.toNamed('/review-contractor-tasks')},
      {'title': 'Messages', 'icon': Icons.message_outlined, 'color': const Color(0xFFE91E63), 'onTap': () => Get.toNamed('/architect-messages')},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3),
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
                  _buildDrawerItem(icon: Icons.architecture, title: 'View Plans', onTap: () { Navigator.pop(context); Get.toNamed('/view-project-plans'); }),
                  _buildDrawerItem(icon: Icons.people_outline, title: 'Consultations', onTap: () { Navigator.pop(context); Get.toNamed('/consult-homeowners'); }),
                  _buildDrawerItem(icon: Icons.rate_review_outlined, title: 'Reviews', onTap: () { Navigator.pop(context); Get.toNamed('/review-contractor-tasks'); }),
                  _buildDrawerItem(icon: Icons.message_outlined, title: 'Messages', onTap: () { Navigator.pop(context); Get.toNamed('/architect-messages'); }),
                  const Divider(height: 32),
                  _buildDrawerItem(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
                  _buildDrawerItem(icon: Icons.help_outline, title: 'Help & Support', onTap: () { Navigator.pop(context); Get.toNamed('/architect-help'); }),
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
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1))),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF2196F3).withOpacity(0.1)),
            child: const Center(child: Icon(Icons.architecture, size: 40, color: Color(0xFF2196F3))),
          ),
          const SizedBox(height: 16),
          Text(_authController.currentUser.value?.email ?? 'Architect', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('Professional Architect', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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







