

////////////////////
/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/projectModel.dart';
import '../Models/contractorModel.dart';
import '../Services/projects/projectService.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  List<Contractor> _contractors = [];
  bool _isLoading = false;
  final String userType;

  ProjectController(this.userType);

  List<Project> get projects => _projects;
  List<Contractor> get contractors => _contractors;
  bool get isLoading => _isLoading;

  Future<void> loadProjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in, cannot load projects");
      return;
    }

    print("Loading projects for user: ${user.uid}, type: $userType");
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await _projectService.getProjects(user.uid, userType);
      print("Projects retrieved: ${_projects.length} for ${user.uid}");
    } catch (e) {
      print('Error loading projects for ${user.uid}: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadContractors() async {
    print("Loading contractors");
    _isLoading = true;
    notifyListeners();

    try {
      _contractors = await _projectService.getContractors();
      print(
          "Contractors retrieved: ${_contractors.length} - List: $_contractors");
    } catch (e) {
      print('Error loading contractors: $e with stack trace: ${e.toString()}');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> assignProject(
      String projectId, String? contractorId, String? architectId) async {
    try {
      await _projectService.assignProject(projectId, contractorId, architectId);
      await loadProjects();
    } catch (e) {
      print('Error assigning project: $e');
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      await _projectService.sendMessage(projectId, message);
      await loadProjects();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await _projectService.createProject(project);
      await loadProjects();
    } catch (e) {
      print('Error adding project: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _projectService.updateProject(project);
      await loadProjects();
    } catch (e) {
      print('Error updating project: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.deleteProject(projectId, user.uid);
        _projects.removeWhere((project) => project.id == projectId);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting project: $e');
    }
  }
}*/
////////////
/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/projectModel.dart';
import '../Models/contractorModel.dart';
import '../Services/projects/projectService.dart';
import 'package:get/get.dart'; // Add for Get.snackbar

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  List<Contractor> _contractors = [];
  bool _isLoading = false;
  String _userType = 'homeowner'; // Default value to prevent null
  int _activeProjectsCount = 0;
  int _pendingReviewsCount = 0;
  int _newMessagesCount = 0;

  ProjectController(String userType) : _userType = userType.isEmpty ? 'homeowner' : userType;

  List<Project> get projects => _projects;
  List<Contractor> get contractors => _contractors;
  bool get isLoading => _isLoading;
  String get userType => _userType; // Expose userType for debugging
  int get activeProjectsCount => _activeProjectsCount;
  int get pendingReviewsCount => _pendingReviewsCount;
  int get newMessagesCount => _newMessagesCount;

  void updateUserType(String? newUserType) {
    if (newUserType == null || newUserType.isEmpty) {
      print('Error: Cannot update userType to null or empty string, defaulting to homeowner');
      newUserType = 'homeowner'; // Default to homeowner if null or empty
    }
    print('Updating userType from $_userType to $newUserType');
    _userType = newUserType;
    notifyListeners(); // Notify listeners of the change
    loadProjects(); // Reload projects with the new userType
  }

  Future<void> loadProjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in, cannot load projects");
      return;
    }

    print("Loading projects for user: ${user.uid}, type: $_userType");
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await _projectService.getProjects(user.uid, _userType).catchError((error) {
        print('Error fetching projects for ${user.uid}, type: $_userType: $error');
        if (error.toString().contains('permission-denied')) {
          Get.snackbar(
            'Permission Error',
            'You don’t have permission to access projects. Contact support.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return []; // Return empty list on error
      });
      print("Projects retrieved: ${_projects.length} for ${user.uid}, type: $_userType");
      await _loadStats(user.uid); // Load stats after projects
    } catch (e) {
      print('Error loading projects for ${user.uid}, type: $_userType: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadContractors() async {
    print("Loading contractors");
    _isLoading = true;
    notifyListeners();

    try {
      _contractors = await _projectService.getContractors();
      print("Contractors retrieved: ${_contractors.length} - List: $_contractors");
    } catch (e) {
      print('Error loading contractors: $e with stack trace: ${e.toString()}');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Contractor>> loadProfessionalsForReview(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final professionals = await _projectService.getProfessionalsForUser(userId);
      print("Professionals for review retrieved: ${professionals.length} - List: $professionals");
      _isLoading = false;
      notifyListeners();
      return professionals;
    } catch (e) {
      print('Error loading professionals for review: $e');
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<void> _loadStats(String userId) async {
    try {
      _activeProjectsCount = await _projectService.getActiveProjectsCount(userId).catchError((error) {
        print('Error fetching active projects count for $userId: $error');
        return 0; // Return 0 on error
      });
      _pendingReviewsCount = await _projectService.getPendingReviewsCount(userId).catchError((error) {
        print('Error fetching pending reviews count for $userId: $error');
        return 0; // Return 0 on error
      });
      _newMessagesCount = await _projectService.getNewMessagesCount(userId).catchError((error) {
        print('Error fetching new messages count for $userId: $error');
        return 0; // Return 0 on error
      });
      print("Stats loaded - Active: $_activeProjectsCount, Pending Reviews: $_pendingReviewsCount, New Messages: $_newMessagesCount");
    } catch (e) {
      print('Error loading stats: $e');
    }
    notifyListeners();
  }

  Future<void> saveReview(String projectId, String professionalId, int rating, String review, String professionalRole) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.saveReview(projectId, professionalId, user.uid, rating, review, professionalRole);
        await loadProjects(); // Refresh stats and projects
      }
    } catch (e) {
      print('Error saving review: $e');
    }
  }

  Future<void> assignProject(
      String projectId, String? contractorId, String? architectId) async {
    try {
      print("Assigning project $projectId to contractor: $contractorId, architect: $architectId");
      await _projectService.assignProject(projectId, contractorId, architectId);
      await loadProjects(); // Refresh projects after assignment
    } catch (e) {
      print('Error assigning project: $e');
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      await _projectService.sendMessage(projectId, message);
      await loadProjects(); // Refresh stats after sending a message
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await _projectService.createProject(project);
      await loadProjects();
    } catch (e) {
      print('Error adding project: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _projectService.updateProject(project);
      await loadProjects();
    } catch (e) {
      print('Error updating project: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.deleteProject(projectId, user.uid);
        _projects.removeWhere((project) => project.id == projectId);
        await _loadStats(user.uid); // Refresh stats after deletion
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting project: $e');
    }
  }
}*/


////////////














/*

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';
import 'package:buildbuddy/Services/projects/projectService.dart';

/// Manages project-related functionality for stakeholders, including Contractors.
/// Aligns with SRS 3.2.2 (Usability), 3.2.1 (Performance), 3.2.3 (Security), and 3.2.4 (Reliability).
class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Project> _projects = []; // Already updated to non-final in previous interaction
  List<Contractor> _contractors = []; // Remove 'final' to allow reassignment
  bool _isLoading = false;
  String _userType = 'homeowner'; // Default value, can be updated for Contractors
  int _activeProjectsCount = 0;
  int _pendingReviewsCount = 0;
  int _newMessagesCount = 0;

  StreamSubscription? _projectsSubscription;
  StreamSubscription? _contractorsSubscription;

  ProjectController(String userType) : _userType = userType.isEmpty ? 'homeowner' : userType {
    _startRealTimeListeners();
  }

  List<Project> get projects => _projects;
  List<Contractor> get contractors => _contractors;
  bool get isLoading => _isLoading;
  String get userType => _userType; // Expose userType for debugging
  int get activeProjectsCount => _activeProjectsCount;
  int get pendingReviewsCount => _pendingReviewsCount;
  int get newMessagesCount => _newMessagesCount;

  void updateUserType(String? newUserType) {
    if (newUserType == null || newUserType.isEmpty) {
      print('Error: Cannot update userType to null or empty string, defaulting to homeowner');
      newUserType = 'homeowner';
    }
    print('Updating userType from $_userType to $newUserType');
    _userType = newUserType;
    _startRealTimeListeners(); // Restart listeners with new userType
    notifyListeners();
  }

  /// Starts real-time listeners for projects and contractors based on user type and role.
  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in, cannot start real-time listeners");
      return;
    }

    _stopRealTimeListeners(); // Cancel existing subscriptions

    // Real-time listener for projects
    _projectsSubscription = _database.child('projects').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _projects.clear();
          data.forEach((projectId, projectData) {
            if (projectData is Map) {
              final project = Project.fromMap(Map<String, dynamic>.from(projectData)..['id'] = projectId);
              if (_userType == 'contractor' && project.assignedContractorId == user.uid) {
                _projects.add(project);
              } else if (_userType == 'homeowner' && project.userId == user.uid) {
                _projects.add(project);
              }
            }
          });
          // Sort by date, handling null dates safely
          _projects.sort((a, b) {
            final dateA = a.date;
            final dateB = b.date;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1; // Null dates go to the end
            if (dateB == null) return -1; // Null dates go to the end
            return dateB.compareTo(dateA); // Newest first
          });
          _loadStats(user.uid);
          notifyListeners();
        }
      }
    }, onError: (error) {
      print('Error loading projects in real-time: $error');
      Get.snackbar('Error', 'Failed to load projects: $error',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    });

    // Real-time listener for contractors (only if needed for Contractors)
    if (_userType == 'homeowner') {
      _contractorsSubscription = _database.child('contractors').onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _contractors.clear();
            data.forEach((contractorId, contractorData) {
              if (contractorData is Map) {
                _contractors.add(Contractor.fromMap(Map<String, dynamic>.from(contractorData)..['uid'] = contractorId));
              }
            });
            notifyListeners();
          }
        }
      }, onError: (error) {
        print('Error loading contractors in real-time: $error');
        Get.snackbar('Error', 'Failed to load contractors: $error',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      });
    }
  }

  /// Stops real-time listeners, ensuring resource cleanup and reliability (SRS 3.2.4).
  void _stopRealTimeListeners() {
    _projectsSubscription?.cancel();
    _contractorsSubscription?.cancel();
    _projects.clear();
    _contractors.clear();
  }

  /// Loads projects synchronously for the current user type, fallback for initial load.
  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    // Declare user outside the try block to ensure it's accessible in the catch block
    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in, cannot load projects");
      _isLoading = false; // Ensure _isLoading is reset
      notifyListeners();
      return;
    }

    try {
      print("Loading projects for user: ${user.uid}, type: $_userType");
      _projects = await _projectService.getProjects(user.uid, _userType).catchError((error) {
        print('Error fetching projects for ${user.uid}, type: $_userType: $error');
        if (error.toString().contains('permission-denied')) {
          Get.snackbar(
            'Permission Error',
            'You don’t have permission to access projects. Contact support.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return []; // Return empty list on error
      });
      print("Projects retrieved: ${_projects.length} for ${user.uid}, type: $_userType");
      await _loadStats(user.uid); // Load stats after projects
    } catch (e) {
      print('Error loading projects for ${user.uid}, type: $_userType: $e');
      Get.snackbar('Error', 'Failed to load projects: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads contractors synchronously (legacy, can be removed if real-time is sufficient).
  Future<void> loadContractors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _contractors = await _projectService.getContractors();
      print("Contractors retrieved: ${_contractors.length} - List: $_contractors");
    } catch (e) {
      print('Error loading contractors: $e with stack trace: ${e.toString()}');
      Get.snackbar('Error', 'Failed to load contractors: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Contractor>> loadProfessionalsForReview(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final professionals = await _projectService.getProfessionalsForUser(userId);
      print("Professionals for review retrieved: ${professionals.length} - List: $professionals");
      _isLoading = false;
      notifyListeners();
      return professionals;
    } catch (e) {
      print('Error loading professionals for review: $e');
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<void> _loadStats(String userId) async {
    try {
      _activeProjectsCount = await _projectService.getActiveProjectsCount(userId).catchError((error) {
        print('Error fetching active projects count for $userId: $error');
        return 0; // Return 0 on error
      });
      _pendingReviewsCount = await _projectService.getPendingReviewsCount(userId).catchError((error) {
        print('Error fetching pending reviews count for $userId: $error');
        return 0; // Return 0 on error
      });
      _newMessagesCount = await _projectService.getNewMessagesCount(userId).catchError((error) {
        print('Error fetching new messages count for $userId: $error');
        return 0; // Return 0 on error
      });
      print("Stats loaded - Active: $_activeProjectsCount, Pending Reviews: $_pendingReviewsCount, New Messages: $_newMessagesCount");
    } catch (e) {
      print('Error loading stats: $e');
    }
    notifyListeners();
  }

  Future<void> saveReview(String projectId, String professionalId, int rating, String review, String professionalRole) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.saveReview(projectId, professionalId, user.uid, rating, review, professionalRole);
        await loadProjects(); // Refresh stats and projects
      }
    } catch (e) {
      print('Error saving review: $e');
      Get.snackbar('Error', 'Failed to save review: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> assignProject(String projectId, String? contractorId, String? architectId) async {
    try {
      print("Assigning project $projectId to contractor: $contractorId, architect: $architectId");
      await _projectService.assignProject(projectId, contractorId, architectId);
      await loadProjects(); // Refresh projects after assignment
    } catch (e) {
      print('Error assigning project: $e');
      Get.snackbar('Error', 'Failed to assign project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      await _projectService.sendMessage(projectId, message);
      await loadProjects(); // Refresh stats after sending a message
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await _projectService.createProject(project);
      await loadProjects();
    } catch (e) {
      print('Error adding project: $e');
      Get.snackbar('Error', 'Failed to add project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _projectService.updateProject(project);
      await loadProjects();
    } catch (e) {
      print('Error updating project: $e');
      Get.snackbar('Error', 'Failed to update project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.deleteProject(projectId, user.uid);
        _projects.removeWhere((project) => project.id == projectId);
        await _loadStats(user.uid); // Refresh stats after deletion
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting project: $e');
      Get.snackbar('Error', 'Failed to delete project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  /// Cleans up resources, ensuring reliability (SRS 3.2.4).
  @override
  void dispose() {
    _stopRealTimeListeners();
    super.dispose();
  }
}*/


////////////////////////



/*


import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';
import 'package:buildbuddy/Services/projects/projectService.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Project> _projects = [];
  List<Contractor> _contractors = [];
  bool _isLoading = false;
  String _userType = 'homeowner';
  int _activeProjectsCount = 0;
  int _pendingReviewsCount = 0;
  int _newMessagesCount = 0;

  StreamSubscription? _projectsSubscription;
  StreamSubscription? _contractorsSubscription;
  final Map<String, StreamSubscription> _messageSubscriptions = {};

  ProjectController(String userType) : _userType = userType.isEmpty ? 'homeowner' : userType {
    _startRealTimeListeners();
  }

  List<Project> get projects => _projects;
  List<Contractor> get contractors => _contractors;
  bool get isLoading => _isLoading;
  String get userType => _userType;
  int get activeProjectsCount => _activeProjectsCount;
  int get pendingReviewsCount => _pendingReviewsCount;
  int get newMessagesCount => _newMessagesCount;

  void updateUserType(String? newUserType) {
    if (newUserType == null || newUserType.isEmpty) {
      print('Error: Cannot update userType to null or empty string, defaulting to homeowner');
      newUserType = 'homeowner';
    }
    print('Updating userType from $_userType to $newUserType');
    _userType = newUserType;
    _startRealTimeListeners();
    notifyListeners();
  }

  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in, cannot start real-time listeners");
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
    } else {
      print("Invalid userType: $_userType, skipping project listener");
      return;
    }

    print('ProjectController: Starting real-time listener for projects, userType=$_userType, userId=${user.uid}');
    _projectsSubscription = query.onValue.listen((event) {
      print('Projects listener triggered: snapshot exists=${event.snapshot.exists}');
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        print('Projects data: $data');
        if (data != null) {
          _projects.clear();
          data.forEach((projectId, projectData) {
            print('Processing project: $projectId, data: $projectData');
            if (projectData is Map) {
              final projectMap = Map<String, dynamic>.from(projectData);
              projectMap['id'] = projectId;
              try {
                final project = Project.fromMap(projectMap);
                print('Adding project: $projectId, title=${project.title}');
                _projects.add(project);
                _startMessageListener(projectId);
              } catch (e) {
                print('Error parsing project $projectId: $e');
                print('Project data causing error: $projectMap');
              }
            }
          });
          _projects.sort((a, b) {
            final dateA = a.date;
            final dateB = b.date;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });
          print('Final projects list: ${_projects.length} projects');
          _loadStats(user.uid);
          notifyListeners();
        }
      } else {
        print('ProjectController: No projects found for userType=$_userType, userId=${user.uid}');
        _loadAllProjectsAsFallback(user.uid);
      }
    }, onError: (error) {
      print('Error loading projects in real-time: $error');
      Get.snackbar('Error', 'Failed to load projects: $error',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      _loadAllProjectsAsFallback(user.uid);
    });

    if (_userType == 'homeowner') {
      print('ProjectController: Starting real-time listener for contractors');
      _contractorsSubscription = _database.child('user/contractor').onValue.listen((event) {
        print('Contractors listener triggered: snapshot exists=${event.snapshot.exists}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          print('Contractors data: $data');
          if (data != null) {
            _contractors.clear();
            data.forEach((contractorId, contractorData) {
              print('Processing contractor: $contractorId');
              if (contractorData is Map) {
                final contractorMap = Map<String, dynamic>.from(contractorData);
                contractorMap['uid'] = contractorId;
                try {
                  _contractors.add(Contractor.fromMap(contractorMap));
                  print('Adding contractor: $contractorId');
                } catch (e) {
                  print('Error parsing contractor $contractorId: $e');
                }
              }
            });
            print('Final contractors list: ${_contractors.length} contractors');
            notifyListeners();
          }
        } else {
          print('ProjectController: No contractors found at user/contractor');
        }
      }, onError: (error) {
        print('Error loading contractors in real-time: $error');
        Get.snackbar('Warning', 'Failed to load contractors: $error. Proceeding without contractors.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        _contractors = []; // Clear contractors list to avoid stale data
        notifyListeners();
      });

      print('ProjectController: Starting real-time listener for architects');
      _contractorsSubscription = _database.child('user/architect').onValue.listen((event) {
        print('Architects listener triggered: snapshot exists=${event.snapshot.exists}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          print('Architects data: $data');
          if (data != null) {
            data.forEach((architectId, architectData) {
              print('Processing architect: $architectId');
              if (architectData is Map) {
                final architectMap = Map<String, dynamic>.from(architectData);
                architectMap['uid'] = architectId;
                try {
                  _contractors.add(Contractor.fromMap(architectMap));
                  print('Adding architect: $architectId');
                } catch (e) {
                  print('Error parsing architect $architectId: $e');
                }
              }
            });
            print('Final contractors list (after architects): ${_contractors.length} contractors');
            notifyListeners();
          }
        } else {
          print('ProjectController: No architects found at user/architect');
        }
      }, onError: (error) {
        print('Error loading architects in real-time: $error');
        Get.snackbar('Warning', 'Failed to load architects: $error. Proceeding without architects.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        // Do not clear _contractors here, as contractors may have loaded successfully
        notifyListeners();
      });
    }
  }

  void _loadAllProjectsAsFallback(String userId) async {
    print('ProjectController: Falling back to load all projects (temporary solution)');
    try {
      final snapshot = await _database.child('projects').get();
      print('Fallback projects snapshot: exists=${snapshot.exists}, value=${snapshot.value}');
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('Fallback projects data: $data');
        _projects.clear();
        data.forEach((projectId, projectData) {
          print('Processing fallback project: $projectId, data: $projectData');
          if (projectData is Map) {
            final projectMap = Map<String, dynamic>.from(projectData);
            projectMap['id'] = projectId;
            projectMap['userId'] = projectMap['userId'] ?? 'unknown_user';
            projectMap['userType'] = projectMap['userType'] ?? 'homeowner';
            try {
              final project = Project.fromMap(projectMap);
              print('Adding fallback project: $projectId, title=${project.title}, userId=${project.userId}');
              _projects.add(project);
              _startMessageListener(projectId);
            } catch (e) {
              print('Error parsing fallback project $projectId: $e');
              print('Project data causing error: $projectMap');
            }
          }
        });
        _projects.sort((a, b) {
          final dateA = a.date;
          final dateB = b.date;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        print('Final projects list (fallback): ${_projects.length} projects');
        _loadStats(userId);
        notifyListeners();
      } else {
        print('ProjectController: No projects found in fallback load');
        Get.snackbar('Error', 'No projects found in database',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    } catch (e) {
      print('Error in fallback project load: $e');
      Get.snackbar('Error', 'Failed to load projects (fallback): $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
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
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        print('Messages data for project $projectId: $data');
        if (data != null) {
          final messages = data.entries.map((entry) {
            final messageData = Map<String, dynamic>.from(entry.value as Map);
            return Message.fromMap(messageData, id: entry.key);
          }).toList();
          final projectIndex = _projects.indexWhere((p) => p.id == projectId);
          if (projectIndex != -1) {
            final updatedProject = Project(
              id: _projects[projectIndex].id,
              title: _projects[projectIndex].title,
              description: _projects[projectIndex].description,
              userId: _projects[projectIndex].userId,
              userType: _projects[projectIndex].userType,
              status: _projects[projectIndex].status,
              progress: _projects[projectIndex].progress,
              date: _projects[projectIndex].date,
              icon: _projects[projectIndex].icon,
              assignedContractorId: _projects[projectIndex].assignedContractorId,
              assignedArchitectId: _projects[projectIndex].assignedArchitectId,
              messages: messages,
              reviewed: _projects[projectIndex].reviewed,
              createdAt: _projects[projectIndex].createdAt,
              lastUpdated: DateTime.now(),
            );
            _projects[projectIndex] = updatedProject;
            print('Updated messages for project $projectId: ${messages.length} messages');
            notifyListeners();
          }
        }
      } else {
        print('No messages found for project $projectId');
      }
    }, onError: (error) {
      print('Error loading messages for project $projectId: $error');
    });
  }

  void _stopRealTimeListeners() {
    _projectsSubscription?.cancel();
    _contractorsSubscription?.cancel();
    _messageSubscriptions.forEach((_, subscription) => subscription.cancel());
    _messageSubscriptions.clear();
    _projects.clear();
    _contractors.clear();
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in, cannot load projects");
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      print("Loading projects for user: ${user.uid}, type: $_userType");
      _projects = await _projectService.getProjects(user.uid, _userType).catchError((error) {
        print('Error fetching projects for ${user.uid}, type: $_userType: $error');
        if (error.toString().contains('permission-denied')) {
          Get.snackbar(
            'Permission Error',
            'You don’t have permission to access projects. Contact support.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return [];
      });
      print("Projects retrieved: ${_projects.length} for ${user.uid}, type: $_userType");
      for (var project in _projects) {
        _startMessageListener(project.id);
      }
      await _loadStats(user.uid);
    } catch (e) {
      print('Error loading projects for ${user.uid}, type: $_userType: $e');
      Get.snackbar('Error', 'Failed to load projects: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      _loadAllProjectsAsFallback(user.uid);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadContractors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _contractors = await _projectService.getContractors();
      print("Contractors retrieved: ${_contractors.length} - List: $_contractors");
    } catch (e) {
      print('Error loading contractors: $e with stack trace: ${e.toString()}');
      Get.snackbar('Warning', 'Failed to load contractors: $e. Proceeding without contractors.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
      _contractors = []; // Clear contractors list to avoid stale data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Contractor>> loadProfessionalsForReview(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final professionals = await _projectService.getProfessionalsForUser(userId);
      print("Professionals for review retrieved: ${professionals.length} - List: $professionals");
      return professionals;
    } catch (e) {
      print('Error loading professionals for review: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStats(String userId) async {
    try {
      _activeProjectsCount = await _projectService.getActiveProjectsCount(userId).catchError((error) {
        print('Error fetching active projects count for $userId: $error');
        return 0;
      });
      _pendingReviewsCount = await _projectService.getPendingReviewsCount(userId).catchError((error) {
        print('Error fetching pending reviews count for $userId: $error');
        return 0;
      });
      _newMessagesCount = await _projectService.getNewMessagesCount(userId).catchError((error) {
        print('Error fetching new messages count for $userId: $error');
        return 0;
      });
      print("Stats loaded - Active: $_activeProjectsCount, Pending Reviews: $_pendingReviewsCount, New Messages: $_newMessagesCount");
    } catch (e) {
      print('Error loading stats: $e');
    }
    notifyListeners();
  }

  Future<void> saveReview(String projectId, String professionalId, int rating, String review, String professionalRole) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.saveReview(projectId, professionalId, user.uid, rating, review, professionalRole);
        await loadProjects();
      }
    } catch (e) {
      print('Error saving review: $e');
      Get.snackbar('Error', 'Failed to save review: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> assignProject(String projectId, String? contractorId, String? architectId) async {
    try {
      print("Assigning project $projectId to contractor: $contractorId, architect: $architectId");
      await _projectService.assignProject(projectId, contractorId, architectId);
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final updatedProject = Project(
          id: _projects[projectIndex].id,
          title: _projects[projectIndex].title,
          description: _projects[projectIndex].description,
          userId: _projects[projectIndex].userId,
          userType: _projects[projectIndex].userType,
          status: _projects[projectIndex].status,
          progress: _projects[projectIndex].progress,
          date: _projects[projectIndex].date,
          icon: _projects[projectIndex].icon,
          assignedContractorId: contractorId ?? _projects[projectIndex].assignedContractorId,
          assignedArchitectId: architectId ?? _projects[projectIndex].assignedArchitectId,
          messages: _projects[projectIndex].messages,
          reviewed: _projects[projectIndex].reviewed,
          createdAt: _projects[projectIndex].createdAt,
          lastUpdated: DateTime.now(),
        );
        _projects[projectIndex] = updatedProject;
        notifyListeners();
      }
      await _database.child('projects/$projectId').update({'lastUpdated': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Error assigning project: $e');
      Get.snackbar('Error', 'Failed to assign project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      await _projectService.sendMessage(projectId, message);
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final updatedProject = Project(
          id: _projects[projectIndex].id,
          title: _projects[projectIndex].title,
          description: _projects[projectIndex].description,
          userId: _projects[projectIndex].userId,
          userType: _projects[projectIndex].userType,
          status: _projects[projectIndex].status,
          progress: _projects[projectIndex].progress,
          date: _projects[projectIndex].date,
          icon: _projects[projectIndex].icon,
          assignedContractorId: _projects[projectIndex].assignedContractorId,
          assignedArchitectId: _projects[projectIndex].assignedArchitectId,
          messages: _projects[projectIndex].messages,
          reviewed: _projects[projectIndex].reviewed,
          createdAt: _projects[projectIndex].createdAt,
          lastUpdated: DateTime.now(),
        );
        _projects[projectIndex] = updatedProject;
        notifyListeners();
      }
      await _database.child('projects/$projectId').update({'lastUpdated': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> addProject(Project project) async {
    try {
      final newProject = Project(
        id: project.id,
        title: project.title,
        description: project.description,
        userId: project.userId,
        userType: project.userType,
        status: project.status,
        progress: project.progress,
        date: project.date,
        icon: project.icon,
        assignedContractorId: project.assignedContractorId,
        assignedArchitectId: project.assignedArchitectId,
        messages: project.messages,
        reviewed: project.reviewed,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      await _projectService.createProject(newProject);
      await loadProjects();
    } catch (e) {
      print('Error adding project: $e');
      Get.snackbar('Error', 'Failed to add project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      final updatedProject = Project(
        id: project.id,
        title: project.title,
        description: project.description,
        userId: project.userId,
        userType: project.userType,
        status: project.status,
        progress: project.progress,
        date: project.date,
        icon: project.icon,
        assignedContractorId: project.assignedContractorId,
        assignedArchitectId: project.assignedArchitectId,
        messages: project.messages,
        reviewed: project.reviewed,
        createdAt: project.createdAt,
        lastUpdated: DateTime.now(),
      );
      await _projectService.updateProject(updatedProject);
      await loadProjects();
    } catch (e) {
      print('Error updating project: $e');
      Get.snackbar('Error', 'Failed to update project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.deleteProject(projectId, user.uid);
        _projects.removeWhere((project) => project.id == projectId);
        await _loadStats(user.uid);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting project: $e');
      Get.snackbar('Error', 'Failed to delete project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  void dispose() {
    _stopRealTimeListeners();
    super.dispose();
  }
}*/



import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';
import 'package:buildbuddy/Services/projects/projectService.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Project> _projects = [];
  List<Contractor> _contractors = [];
  bool _isLoading = false;
  String _userType = 'homeowner';
  int _activeProjectsCount = 0;
  int _pendingReviewsCount = 0;
  int _newMessagesCount = 0;

  StreamSubscription? _projectsSubscription;
  StreamSubscription? _contractorsSubscription;
  final Map<String, StreamSubscription> _messageSubscriptions = {};

  ProjectController(String userType) : _userType = userType.isEmpty ? 'homeowner' : userType {
    // Enable Firebase offline persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    _startRealTimeListeners();
  }

  List<Project> get projects => _projects;
  List<Contractor> get contractors => _contractors;
  bool get isLoading => _isLoading;
  String get userType => _userType;
  int get activeProjectsCount => _activeProjectsCount;
  int get pendingReviewsCount => _pendingReviewsCount;
  int get newMessagesCount => _newMessagesCount;

  void updateUserType(String? newUserType) {
    if (newUserType == null || newUserType.isEmpty) {
      print('Error: Cannot update userType to null or empty, defaulting to homeowner');
      newUserType = 'homeowner';
    }
    print('Updating userType from $_userType to $newUserType');
    _userType = newUserType;
    _startRealTimeListeners();
    notifyListeners();
  }

  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in, cannot start real-time listeners");
      Get.snackbar('Error', 'Please log in to view projects',
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
    } else {
      print("Invalid userType: $_userType, skipping project listener");
      return;
    }

    print('Starting real-time listener for projects, userType=$_userType, userId=${user.uid}');
    _projectsSubscription = query.onValue.listen((event) {
      print('Projects listener triggered: snapshot exists=${event.snapshot.exists}');
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        print('Raw projects data: $data');
        if (data != null) {
          _projects.clear();
          data.forEach((projectId, projectData) {
            print('Processing project: $projectId, data: $projectData');
            if (projectData is Map) {
              final projectMap = Map<String, dynamic>.from(projectData);
              projectMap['id'] = projectId;
              try {
                final project = Project.fromMap(projectMap);
                print('Adding project: $projectId, title=${project.title}');
                _projects.add(project);
                _startMessageListener(projectId);
              } catch (e) {
                print('Error parsing project $projectId: $e');
                print('Project data causing error: $projectMap');
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
          notifyListeners();
        }
      } else {
        print('No projects found for userType=$_userType, userId=${user.uid}');
        _projects.clear();
        _loadAllProjectsAsFallback(user.uid);
        notifyListeners();
      }
    }, onError: (error) {
      print('Error loading projects in real-time: $error');
      Get.snackbar('Error', 'Failed to load projects: $error',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      _loadAllProjectsAsFallback(user.uid);
    });

    if (_userType == 'homeowner') {
      print('Starting real-time listener for contractors');
      _contractorsSubscription = _database.child('user/contractor').onValue.listen((event) {
        print('Contractors listener triggered: snapshot exists=${event.snapshot.exists}');
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          print('Contractors data: $data');
          if (data != null) {
            _contractors.clear();
            data.forEach((contractorId, contractorData) {
              print('Processing contractor: $contractorId');
              if (contractorData is Map) {
                final contractorMap = Map<String, dynamic>.from(contractorData);
                contractorMap['uid'] = contractorId;
                try {
                  _contractors.add(Contractor.fromMap(contractorMap));
                  print('Adding contractor: $contractorId');
                } catch (e) {
                  print('Error parsing contractor $contractorId: $e');
                }
              }
            });
            print('Final contractors list: ${_contractors.length} contractors');
            notifyListeners();
          }
        }
      }, onError: (error) {
        print('Error loading contractors in real-time: $error');
        Get.snackbar('Warning', 'Failed to load contractors: $error',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        _contractors.clear();
        notifyListeners();
      });

      print('Starting real-time listener for architects');
      _contractorsSubscription = _database.child('user/architect').onValue.listen((event) {
        print('Architects listener triggered: snapshot exists=${event.snapshot.exists}');
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          print('Architects data: $data');
          if (data != null) {
            data.forEach((architectId, architectData) {
              print('Processing architect: $architectId');
              if (architectData is Map) {
                final architectMap = Map<String, dynamic>.from(architectData);
                architectMap['uid'] = architectId;
                try {
                  _contractors.add(Contractor.fromMap(architectMap));
                  print('Adding architect: $architectId');
                } catch (e) {
                  print('Error parsing architect $architectId: $e');
                }
              }
            });
            print('Final contractors list (after architects): ${_contractors.length} contractors');
            notifyListeners();
          }
        }
      }, onError: (error) {
        print('Error loading architects in real-time: $error');
        Get.snackbar('Warning', 'Failed to load architects: $error',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        notifyListeners();
      });
    }
  }

  void _loadAllProjectsAsFallback(String userId) async {
    print('Falling back to load all projects');
    try {
      final snapshot = await _database.child('projects').get();
      print('Fallback projects snapshot: exists=${snapshot.exists}, value=${snapshot.value}');
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('Fallback projects data: $data');
        _projects.clear();
        data.forEach((projectId, projectData) {
          print('Processing fallback project: $projectId, data: $projectData');
          if (projectData is Map) {
            final projectMap = Map<String, dynamic>.from(projectData);
            projectMap['id'] = projectId;
            projectMap['userId'] = projectMap['userId'] ?? 'unknown_user';
            projectMap['userType'] = projectMap['userType'] ?? 'homeowner';
            try {
              final project = Project.fromMap(projectMap);
              print('Adding fallback project: $projectId, title=${project.title}, userId=${project.userId}');
              _projects.add(project);
              _startMessageListener(projectId);
            } catch (e) {
              print('Error parsing fallback project $projectId: $e');
              print('Project data causing error: $projectMap');
            }
          }
        });
        _projects.sort((a, b) {
          final dateA = a.date ?? DateTime.now();
          final dateB = b.date ?? DateTime.now();
          return dateB.compareTo(dateA);
        });
        print('Final projects list (fallback): ${_projects.length} projects');
        _loadStats(userId);
        notifyListeners();
      } else {
        print('No projects found in fallback load');
        Get.snackbar('Info', 'No projects found in database',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
      }
    } catch (e) {
      print('Error in fallback project load: $e');
      Get.snackbar('Error', 'Failed to load projects (fallback): $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
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
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        print('Messages data for project $projectId: $data');
        if (data != null) {
          final messages = data.entries.map((entry) {
            final messageData = Map<String, dynamic>.from(entry.value as Map);
            return Message.fromMap(messageData, id: entry.key);
          }).toList();
          final projectIndex = _projects.indexWhere((p) => p.id == projectId);
          if (projectIndex != -1) {
            final updatedProject = Project(
              id: _projects[projectIndex].id,
              title: _projects[projectIndex].title,
              description: _projects[projectIndex].description,
              userId: _projects[projectIndex].userId,
              userType: _projects[projectIndex].userType,
              status: _projects[projectIndex].status,
              progress: _projects[projectIndex].progress,
              date: _projects[projectIndex].date,
              icon: _projects[projectIndex].icon,
              assignedContractorId: _projects[projectIndex].assignedContractorId,
              assignedArchitectId: _projects[projectIndex].assignedArchitectId,
              messages: messages,
              reviewed: _projects[projectIndex].reviewed,
              createdAt: _projects[projectIndex].createdAt,
              lastUpdated: DateTime.now(),
            );
            _projects[projectIndex] = updatedProject;
            print('Updated messages for project $projectId: ${messages.length} messages');
            notifyListeners();
          }
        }
      }
    }, onError: (error) {
      print('Error loading messages for project $projectId: $error');
    });
  }

  void _stopRealTimeListeners() {
    _projectsSubscription?.cancel();
    _contractorsSubscription?.cancel();
    _messageSubscriptions.forEach((_, subscription) => subscription.cancel());
    _messageSubscriptions.clear();
    _projects.clear();
    _contractors.clear();
    print('Stopped all real-time listeners');
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in, cannot load projects");
      _isLoading = false;
      notifyListeners();
      Get.snackbar('Error', 'Please log in to view projects',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    try {
      print("Loading projects for user: ${user.uid}, type: $_userType");
      _projects = await _projectService.getProjects(user.uid, _userType);
      print("Projects retrieved: ${_projects.length} for ${user.uid}, type: $_userType");
      for (var project in _projects) {
        _startMessageListener(project.id);
      }
      await _loadStats(user.uid);
    } catch (e) {
      print('Error loading projects: $e');
      _projects.clear();
      Get.snackbar('Error', 'Failed to load projects: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      _loadAllProjectsAsFallback(user.uid);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadContractors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _contractors = await _projectService.getContractors();
      print("Contractors retrieved: ${_contractors.length} - List: $_contractors");
    } catch (e) {
      print('Error loading contractors: $e');
      _contractors.clear();
      Get.snackbar('Warning', 'Failed to load contractors: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Contractor>> loadProfessionalsForReview(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final professionals = await _projectService.getProfessionalsForUser(userId);
      print("Professionals for review retrieved: ${professionals.length} - List: $professionals");
      return professionals;
    } catch (e) {
      print('Error loading professionals for review: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStats(String userId) async {
    try {
      _activeProjectsCount = await _projectService.getActiveProjectsCount(userId);
      _pendingReviewsCount = await _projectService.getPendingReviewsCount(userId);
      _newMessagesCount = await _projectService.getNewMessagesCount(userId);
      print("Stats loaded - Active: $_activeProjectsCount, Pending Reviews: $_pendingReviewsCount, New Messages: $_newMessagesCount");
    } catch (e) {
      print('Error loading stats: $e');
      _activeProjectsCount = 0;
      _pendingReviewsCount = 0;
      _newMessagesCount = 0;
    }
    notifyListeners();
  }

  Future<void> saveReview(String projectId, String professionalId, int rating, String review, String professionalRole) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _projectService.saveReview(projectId, professionalId, user.uid, rating, review, professionalRole);
        await loadProjects();
      }
    } catch (e) {
      print('Error saving review: $e');
      Get.snackbar('Error', 'Failed to save review: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> assignProject(String projectId, String? contractorId, String? architectId) async {
    try {
      print("Assigning project $projectId to contractor: $contractorId, architect: $architectId");
      await _projectService.assignProject(projectId, contractorId, architectId);
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final updatedProject = Project(
          id: _projects[projectIndex].id,
          title: _projects[projectIndex].title,
          description: _projects[projectIndex].description,
          userId: _projects[projectIndex].userId,
          userType: _projects[projectIndex].userType,
          status: _projects[projectIndex].status,
          progress: _projects[projectIndex].progress,
          date: _projects[projectIndex].date,
          icon: _projects[projectIndex].icon,
          assignedContractorId: contractorId ?? _projects[projectIndex].assignedContractorId,
          assignedArchitectId: architectId ?? _projects[projectIndex].assignedArchitectId,
          messages: _projects[projectIndex].messages,
          reviewed: _projects[projectIndex].reviewed,
          createdAt: _projects[projectIndex].createdAt,
          lastUpdated: DateTime.now(),
        );
        _projects[projectIndex] = updatedProject;
        notifyListeners();
      }
      await _database.child('projects/$projectId').update({'lastUpdated': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Error assigning project: $e');
      Get.snackbar('Error', 'Failed to assign project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      await _projectService.sendMessage(projectId, message);
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final updatedProject = Project(
          id: _projects[projectIndex].id,
          title: _projects[projectIndex].title,
          description: _projects[projectIndex].description,
          userId: _projects[projectIndex].userId,
          userType: _projects[projectIndex].userType,
          status: _projects[projectIndex].status,
          progress: _projects[projectIndex].progress,
          date: _projects[projectIndex].date,
          icon: _projects[projectIndex].icon,
          assignedContractorId: _projects[projectIndex].assignedContractorId,
          assignedArchitectId: _projects[projectIndex].assignedArchitectId,
          messages: _projects[projectIndex].messages,
          reviewed: _projects[projectIndex].reviewed,
          createdAt: _projects[projectIndex].createdAt,
          lastUpdated: DateTime.now(),
        );
        _projects[projectIndex] = updatedProject;
        notifyListeners();
      }
      await _database.child('projects/$projectId').update({'lastUpdated': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> addProject(Project project) async {
    try {
      final newProject = Project(
        id: project.id,
        title: project.title,
        description: project.description,
        userId: project.userId,
        userType: project.userType,
        status: project.status,
        progress: project.progress,
        date: project.date,
        icon: project.icon,
        assignedContractorId: project.assignedContractorId,
        assignedArchitectId: project.assignedArchitectId,
        messages: project.messages,
        reviewed: project.reviewed,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      await _projectService.createProject(newProject);
      print('Project created in database: ${newProject.id}, title=${newProject.title}');
      await loadProjects(); // Force reload to ensure UI updates
    } catch (e) {
      print('Error adding project: $e');
      Get.snackbar('Error', 'Failed to add project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      final updatedProject = Project(
        id: project.id,
        title: project.title,
        description: project.description,
        userId: project.userId,
        userType: project.userType,
        status: project.status,
        progress: project.progress,
        date: project.date,
        icon: project.icon,
        assignedContractorId: project.assignedContractorId,
        assignedArchitectId: project.assignedArchitectId,
        messages: project.messages,
        reviewed: project.reviewed,
        createdAt: project.createdAt,
        lastUpdated: DateTime.now(),
      );
      await _projectService.updateProject(updatedProject);
      await loadProjects(); // Force reload to ensure UI updates
    } catch (e) {
      print('Error updating project: $e');
      Get.snackbar('Error', 'Failed to update project: $e',
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
      print('Error deleting project: $e');
      Get.snackbar('Error', 'Failed to delete project: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  void dispose() {
    _stopRealTimeListeners();
    super.dispose();
  }
}