import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/Professional.dart';
import 'package:buildbuddy/Models/projectModel.dart';

class ContractorRateReviewDashboard extends StatefulWidget {
  const ContractorRateReviewDashboard({Key? key}) : super(key: key);

  @override
  _ContractorRateReviewDashboardState createState() => _ContractorRateReviewDashboardState();
}

class _ContractorRateReviewDashboardState extends State<ContractorRateReviewDashboard> {
  List<Professional>? _users = [];
  final TextEditingController _reviewController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUsers();
      }
    });
  }

  Future<void> _loadUsers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final controller = Provider.of<ProjectController>(context, listen: false);
      _users = await controller.loadUsersForContractorReview(user.uid);
      print("Loaded users in ContractorRateReviewDashboard: $_users");
      setState(() {});
    }
  }

  Future<String?> _findProjectIdForVendor(String vendorId, String contractorId) async {
    final orderSnapshot = await _database
        .child('orders')
        .orderByChild('vendorId')
        .equalTo(vendorId)
        .get();

    if (orderSnapshot.exists && orderSnapshot.value != null) {
      final ordersData = Map<String, dynamic>.from(orderSnapshot.value as Map);
      for (var entry in ordersData.entries) {
        final orderMap = Map<String, dynamic>.from(entry.value);
        // Only consider orders that are completed and match the contractor
        if (orderMap['contractorId'] == contractorId &&
            orderMap['status'] == 'COMPLETED' && // Adjust status as needed
            orderMap['projectId'] != null) {
          return orderMap['projectId'];
        }
      }
    }
    return null;
  }

  void _saveReview(int userIndex, int rating) async {
    final user = _users?[userIndex];
    if (user == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final controller = Provider.of<ProjectController>(context, listen: false);
      final projects = controller.projects;

      Project? project;
      if (user.role == 'Homeowner') {
        // For homeowners, the userId in the project matches their UID
        project = projects.firstWhere(
              (p) => p.userId == user.uid,
          orElse: () => projects.firstWhere(
                (p) => p.status == ProjectStatus.completed && !p.reviewed,
            orElse: () => throw Exception('No eligible project found for homeowner review'),
          ),
        );
      } else if (user.role == 'Vendor') {
        // For vendors, find the project via the orders node
        final projectId = await _findProjectIdForVendor(user.uid, currentUser.uid);
        if (projectId == null) {
          throw Exception('No completed order found for vendor review');
        }
        project = projects.firstWhere(
              (p) => p.id == projectId,
          orElse: () => throw Exception('Project $projectId not found in contractor\'s projects'),
        );
        // Ensure the project is completed and not reviewed
        if (project.status != ProjectStatus.completed || project.reviewed) {
          throw Exception('Project $projectId is not eligible for review');
        }
      }

      if (project != null) {
        await controller.saveContractorReview(
          project.id,
          currentUser.uid,
          user.uid,
          rating,
          _reviewController.text.isEmpty ? 'No review provided' : _reviewController.text,
          user.role,
        );
        _reviewController.clear();
        setState(() {
          _users?[userIndex] = user.copyWith(
            rating: rating.toDouble(),
            reviewCount: user.reviewCount + 1,
          );
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4834DF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E3799).withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E3799),
                        const Color(0xFF4834DF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.rate_review_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Rate & Review',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Share Your Experience',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: _users == null || _users!.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _users!.length,
                    itemBuilder: (context, index) {
                      final user = _users![index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: user.role == 'Homeowner'
                                          ? const Color(0xFF4834DF).withOpacity(0.1)
                                          : const Color(0xFF1E3799).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      user.role == 'Homeowner'
                                          ? Icons.person
                                          : Icons.store,
                                      color: user.role == 'Homeowner'
                                          ? const Color(0xFF4834DF)
                                          : const Color(0xFF1E3799),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name ?? 'Unnamed User',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF1E3799),
                                          ),
                                        ),
                                        Text(
                                          user.role,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: List.generate(5, (starIndex) {
                                              return SizedBox(
                                                width: 40,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  icon: Icon(
                                                    starIndex < user.rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 30,
                                                  ),
                                                  onPressed: () {
                                                    _saveReview(index, starIndex + 1);
                                                  },
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),

                                      Flexible(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showReviewDialog(user, index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: const Color(0xFF4834DF),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                          ),
                                          child: const Text(
                                            'Submit Review',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(Professional user, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Review for ${user.name ?? 'Unnamed User'}'),
        content: TextField(
          controller: _reviewController,
          decoration: const InputDecoration(
            hintText: 'Write your review here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _saveReview(index, user.rating.round());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4834DF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}