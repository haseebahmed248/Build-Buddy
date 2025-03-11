
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
            reviewCount: professional.reviewCount! + 1,
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

