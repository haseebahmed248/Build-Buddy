import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Controllers/chatController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'dart:async';

class AdminController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController;
  final ChatController _chatController;

  List<UserData> _users = [];
  List<Project> _projects = [];
  List<Contractor> _contractors = [];
  Map<String, dynamic> _settings = {};
  List<Map<String, dynamic>> _supportTickets = [];
  List<Map<String, dynamic>> _content = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserData> get users => _users;
  List<Project> get projects => _projects;
  List<Contractor> get contractors => _contractors;
  Map<String, dynamic> get settings => _settings;
  List<Map<String, dynamic>> get supportTickets => _supportTickets;
  List<Map<String, dynamic>> get content => _content;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userType => 'admin';

  StreamSubscription<DatabaseEvent>? _usersSubscription;
  StreamSubscription<DatabaseEvent>? _projectsSubscription;
  StreamSubscription<DatabaseEvent>? _contractorsSubscription;

  AdminController(this._authController)
      : _chatController = ChatController() {
    _startRealTimeListeners();
    _authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    // Skip admin status check and always start listeners
    _startRealTimeListeners();
  }

  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _usersSubscription = _database.child('user').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _users.clear();
          data.forEach((role, users) {
            if (users is Map) {
              users.forEach((uid, userData) async {
                if (userData is Map) {
                  try {
                    final user = await UserData.fromJson(
                        Map<String, dynamic>.from(userData), uid);
                    _users.add(user);
                  } catch (e) {
                    print('Error parsing user $uid: $e');
                  }
                }
              });
            }
          });
          _users.sort((a, b) => a.email.compareTo(b.email));
          notifyListeners();
        }
      } else {
        _users.clear();
        notifyListeners();
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load users: $error';
      notifyListeners();
    });

    _projectsSubscription = _database.child('projects').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _projects = data.entries.map((entry) {
            final projectData = Map<String, dynamic>.from(entry.value as Map)
              ..['id'] = entry.key;
            return Project.fromMap(projectData);
          }).toList();
          notifyListeners();
        } else {
          _projects.clear();
          notifyListeners();
        }
      } else {
        _projects.clear();
        notifyListeners();
      }
    }, onError: (error) {
      print('Error loading projects: $error');
      _errorMessage = 'Failed to load projects: $error. Please check Firebase rules.';
      notifyListeners();
    });

    _contractorsSubscription = _database.child('user/contractor').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _contractors = data.entries.map((entry) {
            final contractorData = Map<String, dynamic>.from(entry.value as Map)
              ..['uid'] = entry.key;
            return Contractor.fromMap(contractorData);
          }).toList();
          notifyListeners();
        } else {
          _contractors.clear();
          notifyListeners();
        }
      } else {
        _contractors.clear();
        notifyListeners();
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load contractors: $error';
      notifyListeners();
    });
  }

  void _stopRealTimeListeners() {
    _usersSubscription?.cancel();
    _projectsSubscription?.cancel();
    _contractorsSubscription?.cancel();
    _users.clear();
    _projects.clear();
    _contractors.clear();
    notifyListeners();
  }

  bool get isAdmin => _authController.currentUser.value?.role == UserRole.admin ?? false;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('settings').get();
      if (snapshot.exists && snapshot.value != null) {
        _settings = Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        _settings = {'notificationsEnabled': true, 'twoFactorAuthEnabled': false};
      }
    } catch (e) {
      print('Error loading settings: $e');
      _errorMessage = 'Failed to load settings: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSupportTickets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('supportTickets').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _supportTickets = data.entries.map((entry) {
          return Map<String, dynamic>.from(entry.value as Map)..['id'] = entry.key;
        }).toList().cast<Map<String, dynamic>>();
      } else {
        _supportTickets = [];
      }
    } catch (e) {
      print('Error loading support tickets: $e');
      _errorMessage = 'Failed to load support tickets: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadContent() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('content').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _content = data.entries.map((entry) {
          return Map<String, dynamic>.from(entry.value as Map)..['id'] = entry.key;
        }).toList().cast<Map<String, dynamic>>();
      } else {
        _content = [];
      }
    } catch (e) {
      print('Error loading content: $e');
      _errorMessage = 'Failed to load content: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users.clear();
      notifyListeners();
    } catch (e) {
      print('Error loading users: $e');
      _errorMessage = 'Failed to load users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('projects').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _projects = data.entries.map((entry) {
            final projectData = Map<String, dynamic>.from(entry.value as Map)
              ..['id'] = entry.key;
            return Project.fromMap(projectData);
          }).toList();
        } else {
          _projects.clear();
        }
      } else {
        _projects.clear();
      }
    } catch (e) {
      print('Error loading projects: $e');
      _errorMessage = 'Failed to load projects: $e. Please check Firebase rules.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadContractors() async {
    _isLoading = true;
    notifyListeners();
    try {
      _contractors.clear();
      notifyListeners();
    } catch (e) {
      print('Error loading contractors: $e');
      _errorMessage = 'Failed to load contractors: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ChatController get chat => _chatController;

  Future<void> createUser(String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final userData = UserData(
        uid: userCredential.user!.uid,
        email: email.trim(),
        role: role,
        displayName: '',
        phoneNumber: '',
        emailVerified: false,
        provider: 'password',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        status: 'active',
      );

      await _database.child('user/${role.name}/${userData.uid}').set(userData.toJson());
    } catch (e) {
      print('Error creating user: $e');
      _errorMessage = 'Failed to create user: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserData user) async {
    try {
      await _database.child('user/${user.role.name}/${user.uid}').update(user.toJson());
    } catch (e) {
      print('Error updating user: $e');
      _errorMessage = 'Failed to update user: $e';
      notifyListeners();
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      final user = _users.firstWhere((u) => u.uid == uid, orElse: () => throw Exception('User not found'));
      await _database.child('user/${user.role.name}/$uid').remove();
    } catch (e) {
      print('Error deleting user: $e');
      _errorMessage = 'Failed to delete user: $e';
      notifyListeners();
    }
  }

  Future<void> suspendUser(String uid, String status) async {
    try {
      final user = _users.firstWhere((u) => u.uid == uid, orElse: () => throw Exception('User not found'));
      await _database.child('user/${user.role.name}/$uid/status').set(status);
    } catch (e) {
      print('Error suspending user: $e');
      _errorMessage = 'Failed to suspend user: $e';
      notifyListeners();
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _database.child('projects').child(project.id).update(project.toMap());
    } catch (e) {
      print('Error updating project: $e');
      _errorMessage = 'Failed to update project: $e';
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _database.child('projects').child(projectId).remove();
    } catch (e) {
      print('Error deleting project: $e');
      _errorMessage = 'Failed to delete project: $e';
      notifyListeners();
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _database.child('settings').update(settings);
      await loadSettings();
    } catch (e) {
      print('Error updating settings: $e');
      _errorMessage = 'Failed to update settings: $e';
      notifyListeners();
    }
  }

  Future<void> updateSupportTicket(String ticketId, String status) async {
    try {
      final updatedTicket = {
        'ticket': _supportTickets.firstWhere((ticket) => ticket['id'] == ticketId)['ticket'],
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _database.child('supportTickets').child(ticketId).update(updatedTicket);
      await loadSupportTickets();
    } catch (e) {
      print('Error updating support ticket: $e');
      _errorMessage = 'Failed to update support ticket: $e';
      notifyListeners();
    }
  }

  Future<void> updateContent(String type, String content) async {
    try {
      final newContent = {
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final contentRef = _database.child('content').push();
      await contentRef.set(newContent);
      await loadContent();
    } catch (e) {
      print('Error updating content: $e');
      _errorMessage = 'Failed to update content: $e';
      notifyListeners();
    }
  }

  Future<void> editContent(String contentId, String type, String content) async {
    try {
      final updatedContent = {
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _database.child('content').child(contentId).update(updatedContent);
      await loadContent();
    } catch (e) {
      print('Error editing content: $e');
      _errorMessage = 'Failed to edit content: $e';
      notifyListeners();
    }
  }

  Future<void> deleteContent(String contentId) async {
    try {
      await _database.child('content').child(contentId).remove();
      await loadContent();
    } catch (e) {
      print('Error deleting content: $e');
      _errorMessage = 'Failed to delete content: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopRealTimeListeners();
    _authController.removeListener(_onAuthStateChanged);
    _chatController.dispose();
    super.dispose();
  }
}