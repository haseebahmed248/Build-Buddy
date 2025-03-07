// lib/Views/RateReviewDashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/Professional.dart'; // Updated import
import 'package:buildbuddy/Models/projectModel.dart';

import '../../../Models/architectModel.dart';
import '../../../Models/contractorModel.dart';

class RateReviewDashboard extends StatefulWidget {
  const RateReviewDashboard({Key? key}) : super(key: key);

  @override
  _RateReviewDashboardState createState() => _RateReviewDashboardState();
}

class _RateReviewDashboardState extends State<RateReviewDashboard> {
  late List<Professional>? _professionals = []; // Changed to List<Professional>? and initialized as empty list
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProfessionals();
      }
    });
  }

  Future<void> _loadProfessionals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final controller = Provider.of<ProjectController>(context, listen: false);
      _professionals = await controller.loadProfessionalsForReview(user.uid);
      print("Loaded professionals in RateReviewDashboard: $_professionals");
      setState(() {});
    }
  }

  void _saveReview(int professionalIndex, int rating) {
    final professional = _professionals?[professionalIndex]; // Handle nullability
    if (professional == null) return; // Exit if professional is null

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final projects = Provider.of<ProjectController>(context, listen: false).projects;
      final project = projects.firstWhere(
            (p) => p.assignedContractorId == professional.uid || p.assignedArchitectId == professional.uid,
        orElse: () => projects.firstWhere(
              (p) => p.status == ProjectStatus.completed && !(p.reviewed ?? false),
          orElse: () => throw Exception('No eligible project found for review'),
        ),
      );

      Provider.of<ProjectController>(context, listen: false).saveReview(
        project.id,
        professional.uid,
        rating,
        _reviewController.text.isEmpty ? 'No review provided' : _reviewController.text,
        professional.role,
      );
      _reviewController.clear();
      setState(() {
        // Update the professional's rating and review count based on type
        if (professional is Contractor) {
          _professionals?[professionalIndex] = professional.copyWith(
            rating: rating.toDouble(),
            reviewCount: professional.reviewCount + 1,
          );
        } else if (professional is Architect) {
          _professionals?[professionalIndex] = professional.copyWith(
            rating: rating.toDouble(),
            reviewCount: professional.reviewCount + 1,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // Background Decorative Circles
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

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
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

                // Professionals List
                Expanded(
                  child: _professionals == null || _professionals!.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _professionals!.length,
                    itemBuilder: (context, index) {
                      final professional = _professionals![index];
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
                              // Professional Info
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: professional.role == 'Architect'
                                          ? const Color(0xFF4834DF).withOpacity(0.1)
                                          : const Color(0xFF1E3799).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      professional.role == 'Architect'
                                          ? Icons.architecture
                                          : Icons.construction,
                                      color: professional.role == 'Architect'
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
                                          professional.name ?? 'Unnamed Professional',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF1E3799),
                                          ),
                                        ),
                                        Text(
                                          professional.role,
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

                              // Rating Stars and Review Input
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Interactive Rating Stars
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
                                                    starIndex < professional.rating
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

                                      // Submit Review Button
                                      Flexible(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showReviewDialog(professional, index);
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

  void _showReviewDialog(Professional professional, int index) { // Changed parameter type to Professional
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Review for ${professional.name ?? 'Unnamed Professional'}'),
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
              _saveReview(index, professional.rating.round());
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

////////
/*
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';

class ProjectService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Fetch professionals (contractors and architects)
  Future<List<Contractor>> getContractors() async {
    try {
      print("Fetching professionals (contractors and architects) from Firebase");
      final List<Contractor> professionals = [];

      // Fetch contractors
      final contractorSnapshot = await _database.child('user/contractor').get();
      if (contractorSnapshot.exists && contractorSnapshot.value != null) {
        final contractorData = contractorSnapshot.value as Map<dynamic, dynamic>;
        print("Raw contractor data from Firebase: $contractorData");
        contractorData.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          map['uid'] = key; // Add UID as key
          map['role'] = 'Contractor'; // Set role as Contractor
          professionals.add(Contractor.fromMap(map));
        });
      }

      // Fetch architects
      final architectSnapshot = await _database.child('user/architect').get();
      if (architectSnapshot.exists && architectSnapshot.value != null) {
        final architectData = architectSnapshot.value as Map<dynamic, dynamic>;
        print("Raw architect data from Firebase: $architectData");
        architectData.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          map['uid'] = key; // Add UID as key
          map['role'] = 'Architect'; // Set role as Architect
          professionals.add(Contractor.fromMap(map));
        });
      }

      print("Professionals retrieved: ${professionals.length} - List: $professionals");
      return professionals;
    } catch (e) {
      print("Error fetching professionals: $e with stack trace: ${e.toString()}");
      return [];
    }
  }

  // Fetch projects for a user
  Future<List<Project>> getProjects(String userId, String userType) async {
    try {
      print("Fetching projects for userId: $userId, userType: $userType");
      Query query;
      if (userType == 'homeowner') {
        query = _database.child('projects').orderByChild('userId').equalTo(userId);
      } else if (userType == 'contractor') {
        query = _database
            .child('projects')
            .orderByChild('assignedContractorId')
            .equalTo(userId);
      } else if (userType == 'architect') {
        query = _database
            .child('projects')
            .orderByChild('assignedArchitectId')
            .equalTo(userId);
      } else {
        print("Invalid userType: $userType");
        return [];
      }

      final snapshot = await query.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print("Raw data from Firebase for $userType: $data");
        return data.entries.map((entry) {
          print("Processing entry: ${entry.key} -> ${entry.value}");
          return Project.fromMap(Map<String, dynamic>.from(entry.value as Map));
        }).toList();
      } else {
        print("No projects found for $userType: $userId");
        return [];
      }
    } catch (e) {
      print("Error fetching projects: $e");
      return [];
    }
  }

  // Fetch professionals assigned to homeowner's projects
  Future<List<Contractor>> getProfessionalsForUser(String userId) async {
    try {
      final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final projects = snapshot.value as Map<dynamic, dynamic>;
        final List<Contractor> professionals = [];
        for (var projectEntry in projects.entries) {
          final project = Project.fromMap(Map<String, dynamic>.from(projectEntry.value as Map));
          if (project.assignedContractorId != null && project.assignedContractorId!.isNotEmpty) {
            final contractorSnapshot = await _database.child('user/contractor').child(project.assignedContractorId!).get();
            if (contractorSnapshot.exists) {
              final contractorData = Map<String, dynamic>.from(contractorSnapshot.value as Map);
              contractorData['uid'] = project.assignedContractorId;
              contractorData['role'] = 'Contractor';
              professionals.add(Contractor.fromMap(contractorData));
            }
          }
          if (project.assignedArchitectId != null && project.assignedArchitectId!.isNotEmpty) {
            final architectSnapshot = await _database.child('user/architect').child(project.assignedArchitectId!).get();
            if (architectSnapshot.exists) {
              final architectData = Map<String, dynamic>.from(architectSnapshot.value as Map);
              architectData['uid'] = project.assignedArchitectId;
              architectData['role'] = 'Architect';
              professionals.add(Contractor.fromMap(architectData));
            }
          }
        }
        print("Professionals for user $userId retrieved: ${professionals.length} - List: $professionals");
        return professionals.distinctBy((p) => p.uid).toList(); // Remove duplicates by UID
      }
      return [];
    } catch (e) {
      print("Error fetching professionals for user: $e");
      return [];
    }
  }

  // Save a review and rating
  Future<void> saveReview(String projectId, String professionalId, String userId, int rating, String review, String professionalRole) async {
    try {
      final reviewId = _database.child('reviews').push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
      await _database.child('reviews').child(reviewId).set({
        'projectId': projectId,
        'professionalId': professionalId,
        'userId': userId,
        'rating': rating,
        'review': review,
        'timestamp': DateTime.now().toIso8601String(),
        'professionalRole': professionalRole,
      });

      // Update project as reviewed
      await _database.child('projects').child(projectId).update({'reviewed': true});

      // Update professional's average rating (optional, for future enhancement)
      await _updateProfessionalRating(professionalId, professionalRole, rating);
    } catch (e) {
      throw Exception('Failed to save review: $e');
    }
  }

  // Update professional's average rating (simplified for this example)
  Future<void> _updateProfessionalRating(String professionalId, String role, int newRating) async {
    try {
      final snapshot = await _database.child('reviews').orderByChild('professionalId').equalTo(professionalId).get();
      if (snapshot.exists && snapshot.value != null) {
        final reviews = snapshot.value as Map<dynamic, dynamic>;
        int totalRating = 0;
        int count = 0;
        reviews.forEach((_, value) {
          final review = Map<String, dynamic>.from(value as Map);
          totalRating += (review['rating'] as int?) ?? 0;
          count++;
        });
        final newAverage = count > 0 ? totalRating / count : newRating;
        await _database.child('user/$role').child(professionalId).update({
          'rating': newAverage,
          'reviewCount': count,
        });
      } else {
        // If no reviews exist, set the new rating
        await _database.child('user/$role').child(professionalId).update({
          'rating': newRating.toDouble(),
          'reviewCount': 1,
        });
      }
    } catch (e) {
      print("Error updating professional rating: $e");
    }
  }

  Future<int> getActiveProjectsCount(String userId) async {
    try {
      final snapshot = await _database
          .child('projects')
          .orderByChild('userId')
          .equalTo(userId)
          .get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.where((entry) {
          final project = Project.fromMap(
              Map<String, dynamic>.from(entry.value as Map));
          return project.status == ProjectStatus.inProgress ||
              project.status == ProjectStatus.pending;
        }).length;
      }
      return 0;
    } catch (e) {
      print("Error fetching active projects count: $e");
      return 0;
    }
  }

  Future<int> getPendingReviewsCount(String userId) async {
    try {
      final snapshot = await _database
          .child('projects')
          .orderByChild('userId')
          .equalTo(userId)
          .get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.where((entry) {
          final project = Project.fromMap(
              Map<String, dynamic>.from(entry.value as Map));
          return project.status == ProjectStatus.completed &&
              (project.reviewed ?? false) == false; // Assuming a 'reviewed' field
        }).length;
      }
      return 0;
    } catch (e) {
      print("Error fetching pending reviews count: $e");
      return 0;
    }
  }

  Future<int> getNewMessagesCount(String userId) async {
    try {
      final snapshot = await _database
          .child('projects')
          .orderByChild('userId')
          .equalTo(userId)
          .get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int unreadCount = 0;
        data.forEach((projectKey, projectValue) {
          final project = Project.fromMap(
              Map<String, dynamic>.from(projectValue as Map));
          if (project.messages != null) {
            unreadCount += project.messages!.where((message) => !(message.read ?? true)).length;
          }
        });
        return unreadCount;
      }
      return 0;
    } catch (e) {
      print("Error fetching new messages count: $e");
      return 0;
    }
  }

  Future<void> createProject(Project project) async {
    try {
      await _database.child('projects').child(project.id).set(project.toJson());
      await _database
          .child('userProjects')
          .child(project.userId)
          .child(project.id)
          .set(true);
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<void> assignProject(
      String projectId, String? contractorId, String? architectId) async {
    try {
      await _database.child('projects').child(projectId).update({
        'assignedContractorId': contractorId ?? '',
        'assignedArchitectId': architectId ?? '',
      });
      print("Project assigned successfully");
    } catch (e) {
      throw Exception('Error assigning project: $e');
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      await _database
          .child('projects')
          .child(projectId)
          .child('messages')
          .push()
          .set(message.toJson());
      print("Message sent successfully");
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _database.child('projects').child(project.id).update(project.toJson());
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String projectId, String userId) async {
    try {
      await _database.child('projects').child(projectId).remove();
      await _database
          .child('userProjects')
          .child(userId)
          .child(projectId)
          .remove();
      print("Project deleted successfully: $projectId");
    } catch (e) {
      throw Exception('Error deleting project: $e');
    }
  }
}*/
