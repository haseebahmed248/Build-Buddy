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
  List<Contractor> _architects = [];
  bool _isLoading = false;
  String _userType = 'homeowner';
  int _activeProjectsCount = 0;
  int _pendingReviewsCount = 0;
  int _newMessagesCount = 0;
  String? _errorMessage;

  StreamSubscription? _projectsSubscription;
  StreamSubscription? _contractorsSubscription;
  StreamSubscription? _architectsSubscription;
  final Map<String, StreamSubscription> _messageSubscriptions = {};

  ProjectController(String userType)
      : _userType = userType.isEmpty ? 'homeowner' : userType {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    _startRealTimeListeners();
  }

  List<Project> get projects => _projects;
  List<Contractor> get contractors => _contractors;
  List<Contractor> get architects => _architects;
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
      _contractors.clear();
      _architects.clear();
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
    } else {
      _errorMessage = 'Invalid userType: $_userType';
      print(_errorMessage);
      notifyListeners();
      return;
    }

    print('Starting real-time listener for projects, userType=$_userType, userId=${user.uid}');
    _projectsSubscription = query.onValue.listen((event) {
      print('Projects listener triggered: snapshot exists=${event.snapshot.exists}');
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
              print('Adding project: $projectId, title=${project.title}');
              _projects.add(project);
              _startMessageListener(projectId);
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
      print(_errorMessage);
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      _projects.clear();
      notifyListeners();
    });

    if (_userType == 'homeowner') {
      _contractorsSubscription = _database.child('user/contractor').onValue.listen((event) {
        print('Contractors listener triggered: snapshot exists=${event.snapshot.exists}');
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          _contractors.clear();
          data.forEach((contractorId, contractorData) {
            if (contractorData is Map) {
              final contractorMap = Map<String, dynamic>.from(contractorData);
              contractorMap['uid'] = contractorId;
              try {
                _contractors.add(Contractor.fromMap(contractorMap));
                print('Adding contractor: $contractorId');
              } catch (e) {
                _errorMessage = 'Error parsing contractor $contractorId: $e';
                print(_errorMessage);
              }
            }
          });
          print('Final contractors list: ${_contractors.length} contractors');
          notifyListeners();
        }
      }, onError: (error) {
        _errorMessage = 'Error loading contractors: $error';
        print(_errorMessage);
        Get.snackbar('Warning', _errorMessage!,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        _contractors.clear();
        notifyListeners();
      });

      _architectsSubscription = _database.child('user/architect').onValue.listen((event) {
        print('Architects listener triggered: snapshot exists=${event.snapshot.exists}');
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          _architects.clear();
          data.forEach((architectId, architectData) {
            if (architectData is Map) {
              final architectMap = Map<String, dynamic>.from(architectData);
              architectMap['uid'] = architectId;
              try {
                _architects.add(Contractor.fromMap(architectMap));
                print('Adding architect: $architectId');
              } catch (e) {
                _errorMessage = 'Error parsing architect $architectId: $e';
                print(_errorMessage);
              }
            }
          });
          print('Final architects list: ${_architects.length} architects');
          notifyListeners();
        }
      }, onError: (error) {
        _errorMessage = 'Error loading architects: $error';
        print(_errorMessage);
        Get.snackbar('Warning', _errorMessage!,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        _architects.clear();
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
        }
      }
    }, onError: (error) {
      _errorMessage = 'Error loading messages for project $projectId: $error';
      print(_errorMessage);
    });
  }

  void _stopRealTimeListeners() {
    _projectsSubscription?.cancel();
    _contractorsSubscription?.cancel();
    _architectsSubscription?.cancel();
    _messageSubscriptions.forEach((_, subscription) => subscription.cancel());
    _messageSubscriptions.clear();
    _projects.clear();
    _contractors.clear();
    _architects.clear();
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
      for (var project in _projects) {
        _startMessageListener(project.id);
      }
      await _loadStats(user.uid);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load projects: $e';
      print(_errorMessage);
      _projects.clear();
      Get.snackbar('Error', _errorMessage!,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
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
      _errorMessage = 'Failed to load contractors: $e';
      print(_errorMessage);
      _contractors.clear();
      Get.snackbar('Warning', _errorMessage!,
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
      _errorMessage = 'Failed to load professionals for review: $e';
      print(_errorMessage);
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
      _newMessagesCount = await _projectService.getNewMessagesCount(userId, _userType);
      print("Stats loaded - Active: $_activeProjectsCount, Pending Reviews: $_pendingReviewsCount, New Messages: $_newMessagesCount");
    } catch (e) {
      _errorMessage = 'Failed to load stats: $e';
      print(_errorMessage);
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

// Extension for Project to simplify updates
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
}*/
