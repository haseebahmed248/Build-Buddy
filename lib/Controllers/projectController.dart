import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/Professional.dart';
import 'package:buildbuddy/Models/contractorModel.dart';
import 'package:buildbuddy/Models/architectModel.dart';
import 'package:buildbuddy/Services/projects/projectService.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Project> _projects = [];
  List<Professional> _professionals = []; // Unified list
  bool _isLoading = false;
  String _userType = 'homeowner';
  int _activeProjectsCount = 0;
  int _pendingReviewsCount = 0;
  int _newMessagesCount = 0;
  String? _errorMessage;

  StreamSubscription? _projectsSubscription;
  StreamSubscription? _professionalsSubscription; // Unified subscription
  final Map<String, StreamSubscription> _messageSubscriptions = {};

  ProjectController(String userType)
      : _userType = userType.isEmpty ? 'homeowner' : userType {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    _startRealTimeListeners();
  }

  List<Project> get projects => _projects;
  List<Professional> get professionals => _professionals; // Updated getter
  bool get isLoading => _isLoading;
  String get userType => _userType;
  int get activeProjectsCount => _activeProjectsCount;
  int get pendingReviewsCount => _pendingReviewsCount;
  int get newMessagesCount => _newMessagesCount;
  String? get errorMessage => _errorMessage;

  void updateUserType(String? newUserType) {
    if (newUserType == null || newUserType.isEmpty) {
      print('Error: Cannot update userType to null or empty, defaulting to homeowner');
      newUserType = 'homeowner';
    }
    if (_userType != newUserType) {
      print('Updating userType from $_userType to $newUserType');
      _userType = newUserType;
      _projects.clear();
      _professionals.clear();
      _errorMessage = null;
      _startRealTimeListeners();
      notifyListeners();
    }
  }

  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'No user logged in, please log in';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    _stopRealTimeListeners();

    Query query;
    if (_userType == 'homeowner') {
      query = _database.child('projects').orderByChild('userId').equalTo(user.uid);
    } else if (_userType == 'contractor') {
      query = _database.child('projects').orderByChild('assignedContractorId').equalTo(user.uid);
    } else if (_userType == 'architect') {
      query = _database.child('projects').orderByChild('assignedArchitectId').equalTo(user.uid);
    } else if (_userType == 'vendor') {
      _errorMessage = 'Vendors do not have direct access to projects.';
      print(_errorMessage);
      _projects.clear();
      notifyListeners();
      return;
    } else {
      _errorMessage = 'Invalid userType: $_userType';
      print(_errorMessage);
      notifyListeners();
      return;
    }

    print('Starting real-time listener for projects, userType=$_userType, userId=${user.uid}, queryPath=${query.path}');
    _projectsSubscription = query.onValue.listen((event) {
      print('Projects listener triggered: snapshot exists=${event.snapshot.exists}, value=${event.snapshot.value}');
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        print('Raw projects data: $data');
        _projects.clear();
        data.forEach((projectId, projectData) {
          print('Processing project: $projectId, data: $projectData');
          if (projectData is Map) {
            final projectMap = Map<String, dynamic>.from(projectData);
            projectMap['id'] = projectId;
            try {
              final project = Project.fromMap(projectMap);
              if (_userType == 'homeowner' && project.userId == user.uid ||
                  _userType == 'contractor' && project.assignedContractorId == user.uid ||
                  _userType == 'architect' && project.assignedArchitectId == user.uid) {
                print('Adding project: $projectId, title=${project.title}, userId=${project.userId}, assignedContractorId=${project.assignedContractorId}');
                _projects.add(project);
                _startMessageListener(projectId);
              } else {
                print('Skipping project $projectId: User ${user.uid} does not have access');
              }
            } catch (e) {
              _errorMessage = 'Error parsing project $projectId: $e';
              print('$_errorMessage, Data: $projectMap');
            }
          }
        });
        _projects.sort((a, b) {
          final dateA = a.date ?? DateTime.now();
          final dateB = b.date ?? DateTime.now();
          return dateB.compareTo(dateA);
        });
        print('Final projects list: ${_projects.length} projects');
        _loadStats(user.uid);
        _errorMessage = null;
      } else {
        _errorMessage = 'No projects found for userType=$_userType, userId=${user.uid}';
        print(_errorMessage);
        _projects.clear();
        notifyListeners();
      }
    }, onError: (error) {
      _errorMessage = 'Error loading projects: $error';
      print('Projects listener error: $_errorMessage');
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      _projects.clear();
      notifyListeners();
    });

    if (_userType == 'homeowner') {
      _professionalsSubscription = _database.child('user').onValue.listen((event) {
        print('Professionals listener triggered: snapshot exists=${event.snapshot.exists}');
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          _professionals.clear();
          data.forEach((type, typeData) {
            if (typeData is Map && (type == 'contractor' || type == 'architect')) {
              typeData.forEach((uid, professionalData) {
                if (professionalData is Map) {
                  final professionalMap = Map<String, dynamic>.from(professionalData);
                  professionalMap['uid'] = uid;
                  try {
                    if (type == 'contractor') {
                      _professionals.add(Contractor.fromMap(professionalMap));
                    } else if (type == 'architect') {
                      _professionals.add(Architect.fromMap(professionalMap));
                    }
                    print('Adding professional: $uid, type: $type');
                  } catch (e) {
                    _errorMessage = 'Error parsing professional $uid: $e';
                    print(_errorMessage);
                  }
                }
              });
            }
          });
          print('Final professionals list: ${_professionals.length} professionals');
          notifyListeners();
        }
      }, onError: (error) {
        _errorMessage = 'Error loading professionals: $error';
        print(_errorMessage);
        Get.snackbar('Warning', _errorMessage!,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        _professionals.clear();
        notifyListeners();
      });
    }
  }

  void _startMessageListener(String projectId) {
    _messageSubscriptions[projectId]?.cancel();
    print('Starting message listener for project: $projectId');
    _messageSubscriptions[projectId] = _database
        .child('projects/$projectId/messages')
        .onValue
        .listen((event) {
      print('Messages listener triggered for project $projectId: snapshot exists=${event.snapshot.exists}');
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        print('Messages data for project $projectId: $data');
        final messages = data.entries.map((entry) {
          final messageData = Map<String, dynamic>.from(entry.value as Map);
          return Message.fromMap(messageData, id: entry.key);
        }).toList();
        final projectIndex = _projects.indexWhere((p) => p.id == projectId);
        if (projectIndex != -1) {
          final updatedProject = _projects[projectIndex].copyWith(
            messages: messages,
            lastUpdated: DateTime.now(),
          );
          _projects[projectIndex] = updatedProject;
          print('Updated messages for project $projectId: ${messages.length} messages');
          notifyListeners();
        } else {
          print('Project $projectId not found in _projects list');
        }
      } else {
        print('No messages found for project $projectId');
      }
    }, onError: (error) {
      _errorMessage = 'Error loading messages for project $projectId: $error';
      print(_errorMessage);
      notifyListeners();
    });
  }

  void _stopRealTimeListeners() {
    _projectsSubscription?.cancel();
    _professionalsSubscription?.cancel();
    _messageSubscriptions.forEach((_, subscription) => subscription.cancel());
    _messageSubscriptions.clear();
    _projects.clear();
    _professionals.clear();
    _errorMessage = null;
    print('Stopped all real-time listeners');
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'No user logged in, please log in';
      _isLoading = false;
      notifyListeners();
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    try {
      print("Loading projects for user: ${user.uid}, type: $_userType");
      _projects = await _projectService.getProjects(user.uid, _userType);
      print("Projects retrieved: ${_projects.length} for ${user.uid}, type: $_userType");
      _projects.forEach((project) {
        print("Loaded project: ${project.id}, userId: ${project.userId}, assignedContractorId: ${project.assignedContractorId}");
      });

      for (var project in _projects) {
        _startMessageListener(project.id);
      }

      await _loadStats(user.uid);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load projects: $e';
      print("Error loading projects: $_errorMessage");
      _projects.clear();
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStats(String userId) async {
    try {
      _activeProjectsCount = await _projectService.getActiveProjectsCount(userId);
      _pendingReviewsCount = await _projectService.getPendingReviewsCount(userId);
      _newMessagesCount = await _projectService.getNewMessagesCount(userId, _userType);
      print("Stats loaded - Active: $_activeProjectsCount, Pending Reviews: $_pendingReviewsCount, New Messages: $_newMessagesCount");
    } catch (e) {
      _errorMessage = 'Failed to load stats: $e';
      print(_errorMessage);
      _activeProjectsCount = 0;
      _pendingReviewsCount = 0;
      _newMessagesCount = 0;
      if (_errorMessage!.contains('index-not-defined') || _errorMessage!.contains('permission-denied')) {
        print('Retrying stats load due to index or permission error...');
        Future.delayed(const Duration(seconds: 2), () => _loadStats(userId));
      }
    }
    notifyListeners();
  }
  Future<void> loadProfessionals() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get professionals
      final contractors = await _projectService.getContractors();
      final architects = await _projectService.getArchitects();
      _professionals = [...contractors, ...architects];

      print("Professionals loaded: ${_professionals.length}");

      // If we have professionals, now fetch and apply reviews
      if (_professionals.isNotEmpty) {
        await _applyReviewsToProfessionals();

        // Sort professionals by rating (highest first)
        _professionals.sort((a, b) => b.rating.compareTo(a.rating));
      }
    } catch (e) {
      _errorMessage = 'Failed to load professionals: $e';
      print(_errorMessage);
      _professionals.clear();
      Get.snackbar('Warning', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> _applyReviewsToProfessionals() async {
    try {
      // Get the database reference
      final DatabaseReference reviewsRef = FirebaseDatabase.instance.ref().child('reviews');
      print("Fetching reviews from path: ${reviewsRef.path}");

      final snapshot = await reviewsRef.get();
      if (!snapshot.exists || snapshot.value == null) {
        print("No reviews found in database at path: ${reviewsRef.path}");
        return;
      }

      print("Reviews snapshot found with value type: ${snapshot.value.runtimeType}");
      final reviewsData = Map<String, dynamic>.from(snapshot.value as Map);
      print("Total reviews entries: ${reviewsData.length}");

      // Debug: Print all professional IDs we have
      print("Professional IDs in our list:");
      for (var prof in _professionals) {
        print("Professional ID: ${prof.uid}, Email: ${prof.email}");
      }

      // Create a map to track ratings and counts for each professional
      Map<String, List<double>> professionalRatings = {};

      // Process each review and print what we find
      reviewsData.forEach((reviewId, reviewData) {
        print("Processing review ID: $reviewId");
        if (reviewData is Map) {
          final review = Map<String, dynamic>.from(reviewData);
          String professionalId = review['professionalId'] ?? '';
          print("Review for professional ID: $professionalId");

          if (professionalId.isNotEmpty && review.containsKey('rating')) {
            double rating = (review['rating'] as num).toDouble();
            print("Rating found: $rating");

            if (!professionalRatings.containsKey(professionalId)) {
              professionalRatings[professionalId] = [];
            }
            professionalRatings[professionalId]!.add(rating);
          } else {
            print("Review missing professionalId or rating: $review");
          }
        } else {
          print("Review data is not a Map: $reviewData");
        }
      });

      print("Processed ratings for ${professionalRatings.length} professionals");
      print("Professional IDs with ratings: ${professionalRatings.keys.toList()}");

      // Check if any professionals match our ratings
      bool anyMatches = false;
      for (var prof in _professionals) {
        if (professionalRatings.containsKey(prof.uid)) {
          anyMatches = true;
          break;
        }
      }
      print("Any matches between professionals and reviews? $anyMatches");

      // Update each professional with their calculated rating
      for (int i = 0; i < _professionals.length; i++) {
        final professional = _professionals[i];

        if (professionalRatings.containsKey(professional.uid)) {
          final ratings = professionalRatings[professional.uid]!;
          final totalRating = ratings.reduce((a, b) => a + b);
          final averageRating = totalRating / ratings.length;

          print("Updating professional ${professional.email}: Rating $averageRating, Reviews ${ratings.length}");

          // Create a new professional with updated rating and review count
          final updatedProfessional = professional.copyWith(
              rating: averageRating,
              reviewCount: ratings.length
          );

          // Check if the update worked
          print("Before: Rating=${professional.rating}, After: Rating=${updatedProfessional.rating}");

          // Update in the list
          _professionals[i] = updatedProfessional;
        } else {
          print("No reviews found for professional ID: ${professional.uid}, Email: ${professional.email}");
        }
      }

      // Verify the updates worked
      print("After updates, professionals with non-zero ratings:");
      for (var prof in _professionals) {
        if (prof.rating > 0) {
          print("Professional ${prof.email}: Rating ${prof.rating}, Reviews ${prof.reviewCount}");
        }
      }

      // Make sure to call notifyListeners() so the UI updates
      notifyListeners();
    } catch (e) {
      print('Error applying reviews to professionals: $e');
      print(e.toString());
      if (e is Error) {
        print(e.stackTrace);
      }
    }
  }
 /* Future<void> loadProfessionals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final contractors = await _projectService.getContractors();
      final architects = await _projectService.getArchitects();
      _professionals = [...contractors, ...architects];
      print("Professionals retrieved: ${_professionals.length} - List: $_professionals");
    } catch (e) {
      _errorMessage = 'Failed to load professionals: $e';
      print(_errorMessage);
      _professionals.clear();
      Get.snackbar('Warning', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
*/
  Future<List<Professional>?> loadProfessionalsForReview(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final professionals = await _projectService.getProfessionalsForUser(userId);
      print("Professionals for review retrieved: ${professionals.length} - List: $professionals");
      return professionals;
    } catch (e) {
      _errorMessage = 'Failed to load professionals for review: $e';
      print(_errorMessage);
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveReview(String projectId, String professionalId, int rating, String review, String professionalRole) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _projectService.saveReview(projectId, professionalId, user.uid, rating, review, professionalRole);
        await loadProjects();
      }
    } catch (e) {
      _errorMessage = 'Failed to save review: $e';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> assignProject(String projectId, String? contractorId, String? architectId) async {
    try {
      print("Assigning project $projectId to contractor: $contractorId, architect: $architectId");
      await _projectService.assignProject(projectId, contractorId, architectId);
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final updatedProject = _projects[projectIndex].copyWith(
          assignedContractorId: contractorId ?? _projects[projectIndex].assignedContractorId,
          assignedArchitectId: architectId ?? _projects[projectIndex].assignedArchitectId,
          lastUpdated: DateTime.now(),
        );
        _projects[projectIndex] = updatedProject;
        notifyListeners();
      }
      await _database.child('projects/$projectId').update({'lastUpdated': DateTime.now().toIso8601String()});
    } catch (e) {
      _errorMessage = 'Failed to assign project: $e';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      await _projectService.sendMessage(projectId, message);
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final updatedProject = _projects[projectIndex].copyWith(lastUpdated: DateTime.now());
        _projects[projectIndex] = updatedProject;
        notifyListeners();
      }
      await _database.child('projects/$projectId').update({'lastUpdated': DateTime.now().toIso8601String()});
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error sending message: $e';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> addProject(Project project) async {
    try {
      final newProject = project.copyWith(
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      await _projectService.createProject(newProject);
      print('Project created in database: ${newProject.id}, title=${newProject.title}');
      await loadProjects();
    } catch (e) {
      _errorMessage = 'Failed to add project: $e';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      final updatedProject = project.copyWith(lastUpdated: DateTime.now());
      await _projectService.updateProject(updatedProject);
      await loadProjects();
    } catch (e) {
      _errorMessage = 'Failed to update project: $e';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _projectService.deleteProject(projectId, user.uid);
        _projects.removeWhere((project) => project.id == projectId);
        await _loadStats(user.uid);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to delete project: $e';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  void dispose() {
    _stopRealTimeListeners();
    super.dispose();
  }
}

extension ProjectExtension on Project {
  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    String? userType,
    ProjectStatus? status,
    int? progress,
    DateTime? date,
    String? icon,
    String? assignedContractorId,
    String? assignedArchitectId,
    List<Message>? messages,
    bool? reviewed,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      date: date ?? this.date,
      icon: icon ?? this.icon,
      assignedContractorId: assignedContractorId ?? this.assignedContractorId,
      assignedArchitectId: assignedArchitectId ?? this.assignedArchitectId,
      messages: messages ?? this.messages,
      reviewed: reviewed ?? this.reviewed,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}


