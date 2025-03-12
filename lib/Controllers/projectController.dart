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
  List<Professional> _professionals = [];
  List<Professional> _users = [];
  bool _isLoading = false;
  String _userType = 'homeowner';
  int _activeProjectsCount = 0;
  int _pendingReviewsCount = 0;
  int _newMessagesCount = 0;
  String? _errorMessage;

  StreamSubscription<DatabaseEvent>? _projectsSubscription;
  StreamSubscription<DatabaseEvent>? _professionalsSubscription;
  StreamSubscription<DatabaseEvent>? _usersSubscription;
  final Map<String, StreamSubscription<DatabaseEvent>> _messageSubscriptions = {};

  ProjectController(String userType)
      : _userType = userType.isEmpty ? 'homeowner' : userType {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    // Do not start listeners here; wait until role is confirmed
  }

  List<Project> get projects => _projects;
  List<Professional> get professionals => _professionals;
  List<Professional> get users => _users;
  bool get isLoading => _isLoading;
  String get userType => _userType;
  int get activeProjectsCount => _activeProjectsCount;
  int get pendingReviewsCount => _pendingReviewsCount;
  int get newMessagesCount => _newMessagesCount;
  String? get errorMessage => _errorMessage;

  void updateUserType(String? newUserType) {
    newUserType = newUserType?.isEmpty ?? true ? 'homeowner' : newUserType;
    if (newUserType != null && _userType != newUserType) {
      print('Updating userType from $_userType to $newUserType');
      _userType = newUserType;
      _projects.clear();
      _professionals.clear();
      _users.clear();
      _errorMessage = null;
      _startRealTimeListeners();
      notifyListeners();
    }
  }

  void startListeningAfterRoleSelection() {
    _startRealTimeListeners();
  }

  void _startRealTimeListeners() {
    final User? user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'No user logged in, please log in';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      Get.offAllNamed('/login'); // Redirect to login screen
      return;
    }

    _stopRealTimeListeners();

    Query query;
    switch (_userType) {
      case 'homeowner':
        query = _database.child('projects').orderByChild('userId').equalTo(user.uid);
        break;
      case 'contractor':
        query = _database.child('projects').orderByChild('assignedContractorId').equalTo(user.uid);
        break;
      case 'architect':
        query = _database.child('projects').orderByChild('assignedArchitectId').equalTo(user.uid);
        break;
      case 'vendor':
        _errorMessage = 'Vendors do not have direct access to projects.';
        print(_errorMessage);
        _projects.clear();
        notifyListeners();
        return;
      default:
        _errorMessage = 'Invalid userType: $_userType';
        print(_errorMessage);
        notifyListeners();
        return;
    }

    print('Starting real-time listener for projects, userType=$_userType, userId=${user.uid}, queryPath=${query.path}');
    _projectsSubscription = query.onValue.listen(
          (event) {
        print('Projects listener triggered: snapshot exists=${event.snapshot.exists}, value=${event.snapshot.value}');
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
          print('Raw projects data: $data');
          _projects.clear();
          data.forEach((projectId, projectData) {
            if (projectData is Map) {
              final projectMap = Map<String, dynamic>.from(projectData);
              projectMap['id'] = projectId as String;
              try {
                final project = Project.fromMap(projectMap);
                if ((_userType == 'homeowner' && project.userId == user.uid) ||
                    (_userType == 'contractor' && project.assignedContractorId == user.uid) ||
                    (_userType == 'architect' && project.assignedArchitectId == user.uid)) {
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
          _loadStats(user.uid).then((_) {
            _errorMessage = null;
            notifyListeners();
          }).catchError((e) {
            _errorMessage = 'Failed to load stats: $e';
            notifyListeners();
          });
        } else {
          _errorMessage = 'No projects found for userType=$_userType, userId=${user.uid}';
          print(_errorMessage);
          _projects.clear();
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Error loading projects: $error';
        print('Projects listener error: $_errorMessage');
        Get.snackbar('Error', _errorMessage!,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        _projects.clear();
        notifyListeners();
      },
    );

    if (_userType == 'homeowner') {
      _professionalsSubscription = _database.child('user').onValue.listen(
            (event) {
          print('Professionals listener triggered: snapshot exists=${event.snapshot.exists}');
          if (event.snapshot.exists && event.snapshot.value != null) {
            final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
            _professionals.clear();
            data.forEach((type, typeData) {
              if (typeData is Map && (type == 'contractor' || type == 'architect')) {
                (typeData as Map<dynamic, dynamic>).forEach((uid, professionalData) {
                  if (professionalData is Map) {
                    final professionalMap = Map<String, dynamic>.from(professionalData);
                    professionalMap['uid'] = uid as String;
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
            _applyReviewsToProfessionals().then((_) => notifyListeners()).catchError((e) {
              _errorMessage = 'Error applying reviews: $e';
              notifyListeners();
            });
          }
        },
        onError: (error) {
          _errorMessage = 'Error loading professionals: $error';
          print(_errorMessage);
          Get.snackbar('Warning', _errorMessage!,
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
          _professionals.clear();
          notifyListeners();
        },
      );
    } else if (_userType == 'contractor') {
      _usersSubscription = _database.child('user').onValue.listen(
            (event) {
          print('Users listener triggered: snapshot exists=${event.snapshot.exists}');
          if (event.snapshot.exists && event.snapshot.value != null) {
            final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
            _users.clear();
            data.forEach((type, typeData) {
              if (typeData is Map && (type == 'homeowner' || type == 'vendor')) {
                (typeData as Map<dynamic, dynamic>).forEach((uid, userData) {
                  if (userData is Map) {
                    final userMap = Map<String, dynamic>.from(userData);
                    userMap['uid'] = uid as String;
                    try {
                      if (type == 'homeowner') {
                        _users.add(Professional.fromMap({...userMap, 'role': 'Homeowner'}));
                      } else if (type == 'vendor') {
                        _users.add(Professional.fromMap({...userMap, 'role': 'Vendor'}));
                      }
                      print('Adding user: $uid, type: $type');
                    } catch (e) {
                      _errorMessage = 'Error parsing user $uid: $e';
                      print(_errorMessage);
                    }
                  }
                });
              }
            });
            print('Final users list: ${_users.length} users');
            _applyContractorReviewsToUsers().then((_) => notifyListeners()).catchError((e) {
              _errorMessage = 'Error applying contractor reviews: $e';
              notifyListeners();
            });
          }
        },
        onError: (error) {
          _errorMessage = 'Error loading users: $error';
          print(_errorMessage);
          Get.snackbar('Warning', _errorMessage!,
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
          _users.clear();
          notifyListeners();
        },
      );
    }
  }

  void _startMessageListener(String projectId) {
    _messageSubscriptions[projectId]?.cancel();
    print('Starting message listener for project: $projectId');
    _messageSubscriptions[projectId] = _database
        .child('projects/$projectId/messages')
        .onValue
        .listen(
          (event) {
        print('Messages listener triggered for project $projectId: snapshot exists=${event.snapshot.exists}');
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
          print('Messages data for project $projectId: $data');
          final messages = data.entries
              .map((entry) => Message.fromMap(Map<String, dynamic>.from(entry.value as Map), id: entry.key as String))
              .toList();
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
      },
      onError: (error) {
        _errorMessage = 'Error loading messages for project $projectId: $error';
        print(_errorMessage);
        notifyListeners();
      },
    );
  }

  void _stopRealTimeListeners() {
    _projectsSubscription?.cancel();
    _professionalsSubscription?.cancel();
    _usersSubscription?.cancel();
    _messageSubscriptions.forEach((_, subscription) => subscription.cancel());
    _messageSubscriptions.clear();
    _projects.clear();
    _professionals.clear();
    _users.clear();
    _errorMessage = null;
    print('Stopped all real-time listeners');
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    final User? user = _auth.currentUser;
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
      if (_errorMessage != null &&
          (_errorMessage!.contains('index-not-defined') || _errorMessage!.contains('permission-denied'))) {
        print('Retrying stats load due to index or permission error...');
        await Future.delayed(const Duration(seconds: 2));
        await _loadStats(userId);
      }
    }
    notifyListeners();
  }

  Future<void> loadProfessionals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final contractors = await _projectService.getContractors();
      final architects = await _projectService.getArchitects();
      _professionals = [...contractors, ...architects];
      print("Professionals retrieved: ${_professionals.length} - List: $_professionals");

      if (_professionals.isNotEmpty) {
        await _applyReviewsToProfessionals();
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

      print("Professional IDs in our list:");
      for (var prof in _professionals) {
        print("Professional ID: ${prof.uid}, Email: ${prof.email}");
      }

      Map<String, List<double>> professionalRatings = {};

      reviewsData.forEach((reviewId, reviewData) {
        print("Processing review ID: $reviewId");
        if (reviewData is Map) {
          final review = Map<String, dynamic>.from(reviewData);
          String professionalId = review['professionalId'] ?? '';
          print("Review for professional ID: $professionalId");

          if (professionalId.isNotEmpty && review.containsKey('rating')) {
            double rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
            print("Rating found: $rating");

            professionalRatings.putIfAbsent(professionalId, () => []).add(rating);
          } else {
            print("Review missing professionalId or rating: $review");
          }
        } else {
          print("Review data is not a Map: $reviewData");
        }
      });

      print("Processed ratings for ${professionalRatings.length} professionals");
      print("Professional IDs with ratings: ${professionalRatings.keys.toList()}");

      bool anyMatches = false;
      for (var prof in _professionals) {
        if (professionalRatings.containsKey(prof.uid)) {
          anyMatches = true;
          break;
        }
      }
      print("Any matches between professionals and reviews? $anyMatches");

      for (int i = 0; i < _professionals.length; i++) {
        final professional = _professionals[i];

        if (professionalRatings.containsKey(professional.uid)) {
          final ratings = professionalRatings[professional.uid]!;
          final totalRating = ratings.reduce((a, b) => a + b);
          final averageRating = totalRating / ratings.length;

          print("Updating professional ${professional.email}: Rating $averageRating, Reviews ${ratings.length}");

          final updatedProfessional = professional.copyWith(
            rating: averageRating,
            reviewCount: ratings.length,
          );

          print("Before: Rating=${professional.rating}, After: Rating=${updatedProfessional.rating}");

          _professionals[i] = updatedProfessional;
        } else {
          print("No reviews found for professional ID: ${professional.uid}, Email: ${professional.email}");
        }
      }

      print("After updates, professionals with non-zero ratings:");
      for (var prof in _professionals) {
        if (prof.rating > 0) {
          print("Professional ${prof.email}: Rating ${prof.rating}, Reviews ${prof.reviewCount}");
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error applying reviews to professionals: $e');
      if (e is Error) {
        print(e.stackTrace);
      }
    }
  }

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

  Future<List<Professional>?> loadUsersForContractorReview(String contractorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final users = await _projectService.getUsersForContractor(contractorId);
      print("Users for contractor review retrieved: ${users.length} - List: $users");
      _users = users;
      return users;
    } catch (e) {
      _errorMessage = 'Failed to load users for contractor review: $e';
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
        await _applyReviewsToProfessionals();
      }
    } catch (e) {
      _errorMessage = 'Failed to save review: $e';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> saveContractorReview(String projectId, String contractorId, String reviewedUserId, int rating, String review, String reviewedUserRole) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _projectService.saveContractorReview(projectId, contractorId, reviewedUserId, user.uid, rating, review, reviewedUserRole);
        await loadProjects();
        await _applyContractorReviewsToUsers();
      }
    } catch (e) {
      _errorMessage = 'Failed to save contractor review: $e';
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> _applyContractorReviewsToUsers() async {
    try {
      final DatabaseReference reviewsRef = FirebaseDatabase.instance.ref().child('reviews/contractor_reviews');
      print("Fetching contractor reviews from path: ${reviewsRef.path}");

      final snapshot = await reviewsRef.get();
      if (!snapshot.exists || snapshot.value == null) {
        print("No contractor reviews found in database at path: ${reviewsRef.path}");
        return;
      }

      print("Contractor reviews snapshot found with value type: ${snapshot.value.runtimeType}");
      final reviewsData = Map<String, dynamic>.from(snapshot.value as Map);
      print("Total contractor reviews entries: ${reviewsData.length}");

      print("User IDs in our list:");
      for (var user in _users) {
        print("User ID: ${user.uid}, Name: ${user.name}");
      }

      Map<String, List<double>> userRatings = {};

      reviewsData.forEach((contractorId, contractorReviews) {
        if (contractorReviews is Map) {
          final contractorReviewsMap = Map<String, dynamic>.from(contractorReviews);
          contractorReviewsMap.forEach((reviewId, reviewData) {
            if (reviewData is Map) {
              final review = Map<String, dynamic>.from(reviewData);
              String reviewedUserId = review['reviewedUserId'] ?? '';
              print("Review for user ID: $reviewedUserId");

              if (reviewedUserId.isNotEmpty && review.containsKey('rating')) {
                double rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
                print("Rating found: $rating");

                userRatings.putIfAbsent(reviewedUserId, () => []).add(rating);
              } else {
                print("Review missing reviewedUserId or rating: $review");
              }
            }
          });
        }
      });

      print("Processed ratings for ${userRatings.length} users");
      print("User IDs with ratings: ${userRatings.keys.toList()}");

      bool anyMatches = false;
      for (var user in _users) {
        if (userRatings.containsKey(user.uid)) {
          anyMatches = true;
          break;
        }
      }
      print("Any matches between users and reviews? $anyMatches");

      for (int i = 0; i < _users.length; i++) {
        final user = _users[i];

        if (userRatings.containsKey(user.uid)) {
          final ratings = userRatings[user.uid]!;
          final totalRating = ratings.reduce((a, b) => a + b);
          final averageRating = totalRating / ratings.length;

          print("Updating user ${user.name}: Rating $averageRating, Reviews ${ratings.length}");

          final updatedUser = user.copyWith(
            rating: averageRating,
            reviewCount: ratings.length,
          );

          print("Before: Rating=${user.rating}, After: Rating=${updatedUser.rating}");

          _users[i] = updatedUser;

          if (user.role == 'Homeowner') {
            await _database
                .child('user/homeowner/${user.uid}')
                .update({'rating': averageRating, 'reviewCount': ratings.length});
          } else if (user.role == 'Vendor') {
            await _database
                .child('user/vendor/${user.uid}')
                .update({'rating': averageRating, 'reviewCount': ratings.length});
          }
        } else {
          print("No reviews found for user ID: ${user.uid}, Name: ${user.name}");
        }
      }

      print("After updates, users with non-zero ratings:");
      for (var user in _users) {
        if (user.rating > 0) {
          print("User ${user.name}: Rating ${user.rating}, Reviews ${user.reviewCount}");
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error applying contractor reviews to users: $e');
      if (e is Error) {
        print(e.stackTrace);
      }
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