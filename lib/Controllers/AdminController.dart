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
    _checkAdminStatus();
    _authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = _authController.currentUser.value?.role == UserRole.admin;
    if (isAdmin == true) {
      _startRealTimeListeners();
    } else {
      _stopRealTimeListeners();
      _errorMessage = 'User is not an admin';
      notifyListeners();
    }
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
      final isAdmin = _authController.currentUser.value?.role == UserRole.admin;
      if (isAdmin != true) {
        _errorMessage = 'Only admins can manage users';
        _isLoading = false;
        notifyListeners();
        return;
      }

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
      final isAdmin = _authController.currentUser.value?.role == UserRole.admin;
      if (isAdmin != true) {
        _errorMessage = 'Only admins can manage projects';
        _isLoading = false;
        notifyListeners();
        return;
      }

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
      final isAdmin = _authController.currentUser.value?.role == UserRole.admin;
      if (isAdmin != true) {
        _errorMessage = 'Only admins can manage contractors';
        _isLoading = false;
        notifyListeners();
        return;
      }

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
      if (!isAdmin) {
        _errorMessage = 'Only admins can create users';
        _isLoading = false;
        notifyListeners();
        return;
      }

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
    if (!isAdmin) {
      _errorMessage = 'Only admins can update users';
      notifyListeners();
      return;
    }

    try {
      await _database.child('user/${user.role.name}/${user.uid}').update(user.toJson());
    } catch (e) {
      print('Error updating user: $e');
      _errorMessage = 'Failed to update user: $e';
      notifyListeners();
    }
  }

  Future<void> deleteUser(String uid) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can delete users';
      notifyListeners();
      return;
    }

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
    if (!isAdmin) {
      _errorMessage = 'Only admins can suspend users';
      notifyListeners();
      return;
    }

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
    if (!isAdmin) {
      _errorMessage = 'Only admins can update projects';
      notifyListeners();
      return;
    }

    try {
      await _database.child('projects').child(project.id).update(project.toMap());
    } catch (e) {
      print('Error updating project: $e');
      _errorMessage = 'Failed to update project: $e';
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can delete projects';
      notifyListeners();
      return;
    }

    try {
      await _database.child('projects').child(projectId).remove();
    } catch (e) {
      print('Error deleting project: $e');
      _errorMessage = 'Failed to delete project: $e';
      notifyListeners();
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update settings';
      notifyListeners();
      return;
    }

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
    if (!isAdmin) {
      _errorMessage = 'Only admins can update support tickets';
      notifyListeners();
      return;
    }

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
    if (!isAdmin) {
      _errorMessage = 'Only admins can update content';
      notifyListeners();
      return;
    }

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
    if (!isAdmin) {
      _errorMessage = 'Only admins can edit content';
      notifyListeners();
      return;
    }

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
    if (!isAdmin) {
      _errorMessage = 'Only admins can delete content';
      notifyListeners();
      return;
    }

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











/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Controllers/chatController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'dart:async';

/// Manages admin-specific functionality, including user management, project monitoring,
/// contractor management, settings, support tickets, content, and chat interactions.
/// Aligns with SRS 3.1.1 (Admin Functionality), 3.2.1 (Performance), 3.2.2 (Usability),
/// 3.2.3 (Security), and 3.2.4 (Reliability).
class AdminController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController; // Reference to AuthController for user data
  final ChatController _chatController; // Reference to ChatController for chat access

  List<UserData> _users = [];
  List<Project> _projects = [];
  List<Contractor> _contractors = [];
  Map<String, dynamic> _settings = {};
  List<Map<String, dynamic>> _supportTickets = [];
  List<Map<String, dynamic>> _content = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Getters for admin-managed data, ensuring real-time updates and usability (SRS 3.2.2).
  List<UserData> get users => _users;
  List<Project> get projects => _projects;
  List<Contractor> get contractors => _contractors;
  Map<String, dynamic> get settings => _settings;
  List<Map<String, dynamic>> get supportTickets => _supportTickets;
  List<Map<String, dynamic>> get content => _content;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userType => 'admin'; // Added for consistency

  StreamSubscription? _usersSubscription;
  StreamSubscription? _projectsSubscription;
  StreamSubscription? _contractorsSubscription;

  /// Constructor initializes with AuthController and ChatController for integrated functionality.
  AdminController(this._authController)
      : _chatController = ChatController() { // Remove the _authController parameter
    _checkAdminStatus();
    _authController.addListener(_onAuthStateChanged); // Listen to AuthController changes
  }

  /// Handles authentication state changes to update admin status and listeners.
  void _onAuthStateChanged() {
    _checkAdminStatus();
  }

  /// Checks if the current user is an admin, starting or stopping real-time listeners accordingly.
  /// Ensures security and role-based access (SRS 3.2.3).
  Future<void> _checkAdminStatus() async {
    final isAdmin = _authController.currentUser.value?.role == UserRole.admin;
    if (isAdmin == true) {
      _startRealTimeListeners(); // Only start listeners if user is an admin
    } else {
      _stopRealTimeListeners();
      _errorMessage = 'User is not an admin';
      notifyListeners();
    }
  }

  /// Starts real-time listeners for users, projects, and contractors, ensuring performance (SRS 3.2.1)
  /// and real-time updates (SRS 3.2.2).
  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    // Real-time listener for users (all roles)
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
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load users: $error';
      notifyListeners();
    });

    // Real-time listener for projects (using indexed userId for efficiency, SRS 3.2.1)
    _projectsSubscription = _database.child('projects').orderByChild('userId').equalTo(user.uid).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _projects = data.entries.map((entry) {
            return Project.fromMap(Map<String, dynamic>.from(entry.value as Map)
              ..['id'] = entry.key); // Ensure id is included
          }).toList();
          notifyListeners();
        }
      }
    }, onError: (error) {
      print('Error loading projects: $error');
      _errorMessage = 'Failed to load projects: $error. Please check Firebase rules for indexes.';
      notifyListeners();
    });

    // Real-time listener for contractors (assuming admin can manage all contractors)
    _contractorsSubscription = _database.child('contractors').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _contractors = data.entries.map((entry) {
            return Contractor.fromMap(Map<String, dynamic>.from(entry.value as Map)
              ..['uid'] = entry.key);
          }).toList();
          notifyListeners();
        }
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load contractors: $error';
      notifyListeners();
    });
  }

  /// Stops real-time listeners, ensuring resource cleanup and reliability (SRS 3.2.4).
  void _stopRealTimeListeners() {
    _usersSubscription?.cancel();
    _projectsSubscription?.cancel();
    _contractorsSubscription?.cancel();
    _users.clear();
    _projects.clear();
    _contractors.clear();
    notifyListeners();
  }

  /// Checks if the current user is an admin, ensuring security (SRS 3.2.3).
  bool get isAdmin => _authController.currentUser.value?.role == UserRole.admin ?? false;

  /// Loads settings synchronously for simplicity, with error handling for reliability (SRS 3.2.4).
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('settings').get();
      if (snapshot.exists && snapshot.value != null) {
        _settings = Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        _settings = {'notificationsEnabled': true, 'twoFactorAuthEnabled': false}; // Default settings
      }
    } catch (e) {
      print('Error loading settings: $e');
      _errorMessage = 'Failed to load settings: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Loads support tickets synchronously, ensuring usability and reliability (SRS 3.2.2, 3.2.4).
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

  /// Loads content synchronously, ensuring usability and reliability (SRS 3.2.2, 3.2.4).
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

  /// Loads all users, restricted to admins for security (SRS 3.2.3).
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final isAdmin = _authController.currentUser.value?.role == UserRole.admin;
      if (isAdmin != true) {
        _errorMessage = 'Only admins can manage users';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Force refresh by clearing and re-fetching (real-time listener will update)
      _users.clear();
      notifyListeners(); // Notify immediately to clear the list
    } catch (e) {
      print('Error loading users: $e');
      _errorMessage = 'Failed to load users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads all projects, restricted to admins and using indexed userId for performance (SRS 3.2.1, 3.2.3).
  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();
    try {
      final isAdmin = _authController.currentUser.value?.role == UserRole.admin;
      if (isAdmin != true) {
        _errorMessage = 'Only admins can manage projects';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Query projects using the indexed userId (if filtering by userId is needed)
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final query = _database.child('projects').orderByChild('userId').equalTo(user.uid);
      final snapshot = await query.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _projects = data.entries.map((entry) {
            return Project.fromMap(Map<String, dynamic>.from(entry.value as Map)
              ..['id'] = entry.key); // Ensure id is included
          }).toList();
        } else {
          _projects.clear();
        }
      } else {
        _projects.clear();
      }
    } catch (e) {
      print('Error loading projects: $e');
      _errorMessage = 'Failed to load projects: $e. Please check Firebase rules for indexes.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads all contractors, restricted to admins for security (SRS 3.2.3).
  Future<void> loadContractors() async {
    _isLoading = true;
    notifyListeners();
    try {
      final isAdmin = _authController.currentUser.value?.role == UserRole.admin;
      if (isAdmin != true) {
        _errorMessage = 'Only admins can manage contractors';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Force refresh by clearing and re-fetching (real-time listener will update)
      _contractors.clear();
      notifyListeners(); // Notify immediately to clear the list
    } catch (e) {
      print('Error loading contractors: $e');
      _errorMessage = 'Failed to load contractors: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Provides access to chat functionality for admins, ensuring usability (SRS 3.2.2)
  /// and integration with the chat system across stakeholders.
  ChatController get chat => _chatController;

  /// Creates a new user, restricted to admins for security (SRS 3.2.3).
  Future<void> createUser(String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!isAdmin) {
        _errorMessage = 'Only admins can create users';
        _isLoading = false;
        notifyListeners();
        return;
      }

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
      // Real-time listener will update _users
    } catch (e) {
      print('Error creating user: $e');
      _errorMessage = 'Failed to create user: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing user, restricted to admins for security (SRS 3.2.3).
  Future<void> updateUser(UserData user) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update users';
      notifyListeners();
      return;
    }

    try {
      await _database.child('user/${user.role.name}/${user.uid}').update(user.toJson());
      // Real-time listener will update _users
    } catch (e) {
      print('Error updating user: $e');
      _errorMessage = 'Failed to update user: $e';
      notifyListeners();
    }
  }

  /// Deletes a user, restricted to admins for security (SRS 3.2.3).
  Future<void> deleteUser(String uid) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can delete users';
      notifyListeners();
      return;
    }

    try {
      // Find the user to determine their role
      final user = _users.firstWhere((u) => u.uid == uid, orElse: () => throw Exception('User not found'));
      await _database.child('user/${user.role.name}/$uid').remove();
      // Real-time listener will update _users
    } catch (e) {
      print('Error deleting user: $e');
      _errorMessage = 'Failed to delete user: $e';
      notifyListeners();
    }
  }

  /// Suspends or activates a user, restricted to admins for security (SRS 3.2.3).
  Future<void> suspendUser(String uid, String status) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can suspend users';
      notifyListeners();
      return;
    }

    try {
      // Find the user to determine their role
      final user = _users.firstWhere((u) => u.uid == uid, orElse: () => throw Exception('User not found'));
      await _database.child('user/${user.role.name}/$uid/status').set(status);
      // Real-time listener will update _users
    } catch (e) {
      print('Error suspending user: $e');
      _errorMessage = 'Failed to suspend user: $e';
      notifyListeners();
    }
  }

  /// Updates an existing project, restricted to admins for security (SRS 3.2.3).
  Future<void> updateProject(Project project) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update projects';
      notifyListeners();
      return;
    }

    try {
      await _database.child('projects').child(project.id).update(project.toJson());
      // Real-time listener will update _projects
    } catch (e) {
      print('Error updating project: $e');
      _errorMessage = 'Failed to update project: $e';
      notifyListeners();
    }
  }

  /// Deletes a project, restricted to admins for security (SRS 3.2.3).
  Future<void> deleteProject(String projectId) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can delete projects';
      notifyListeners();
      return;
    }

    try {
      await _database.child('projects').child(projectId).remove();
      // Real-time listener will update _projects
    } catch (e) {
      print('Error deleting project: $e');
      _errorMessage = 'Failed to delete project: $e';
      notifyListeners();
    }
  }

  /// Updates application settings, restricted to admins for security (SRS 3.2.3).
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update settings';
      notifyListeners();
      return;
    }

    try {
      await _database.child('settings').update(settings);
      await loadSettings(); // Refresh settings synchronously for consistency
    } catch (e) {
      print('Error updating settings: $e');
      _errorMessage = 'Failed to update settings: $e';
      notifyListeners();
    }
  }

  /// Updates a support ticket, restricted to admins for security (SRS 3.2.3).
  Future<void> updateSupportTicket(String ticketId, String status) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update support tickets';
      notifyListeners();
      return;
    }

    try {
      final updatedTicket = {
        'ticket': _supportTickets.firstWhere((ticket) => ticket['id'] == ticketId)['ticket'],
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _database.child('supportTickets').child(ticketId).update(updatedTicket);
      await loadSupportTickets(); // Refresh tickets synchronously for consistency
    } catch (e) {
      print('Error updating support ticket: $e');
      _errorMessage = 'Failed to update support ticket: $e';
      notifyListeners();
    }
  }

  /// Creates or updates content, restricted to admins for security (SRS 3.2.3).
  Future<void> updateContent(String type, String content) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update content';
      notifyListeners();
      return;
    }

    try {
      final newContent = {
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final contentRef = _database.child('content').push();
      await contentRef.set(newContent);
      await loadContent(); // Refresh content synchronously for consistency
    } catch (e) {
      print('Error updating content: $e');
      _errorMessage = 'Failed to update content: $e';
      notifyListeners();
    }
  }

  /// Edits existing content, restricted to admins for security (SRS 3.2.3).
  Future<void> editContent(String contentId, String type, String content) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can edit content';
      notifyListeners();
      return;
    }

    try {
      final updatedContent = {
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _database.child('content').child(contentId).update(updatedContent);
      await loadContent(); // Refresh content synchronously for consistency
    } catch (e) {
      print('Error editing content: $e');
      _errorMessage = 'Failed to edit content: $e';
      notifyListeners();
    }
  }

  /// Deletes existing content, restricted to admins for security (SRS 3.2.3).
  Future<void> deleteContent(String contentId) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can delete content';
      notifyListeners();
      return;
    }

    try {
      await _database.child('content').child(contentId).remove();
      await loadContent(); // Refresh content synchronously for consistency
    } catch (e) {
      print('Error deleting content: $e');
      _errorMessage = 'Failed to delete content: $e';
      notifyListeners();
    }
  }

  /// Cleans up resources, ensuring reliability (SRS 3.2.4).
  @override
  void dispose() {
    _stopRealTimeListeners();
    _authController.removeListener(_onAuthStateChanged);
    _chatController.dispose(); // Clean up ChatController
    super.dispose();
  }
}
*/











/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'dart:async';

class AdminController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController;

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
  bool get isAdmin => _authController.currentUser.value?.role == UserRole.admin ?? false;
  String get userType => 'admin';

  StreamSubscription? _usersSubscription;
  StreamSubscription? _projectsSubscription;
  StreamSubscription? _contractorsSubscription;

  AdminController(this._authController) {
    _authController.addListener(_onAuthStateChanged);
    _checkAdminStatus(); // Initial check
  }

  void _onAuthStateChanged() {
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = _authController.currentUser.value;
    print('Checking admin status: user=${user?.email}, role=${user?.role}');
    if (user != null && user.role == UserRole.admin) {
      await _startRealTimeListeners();
      _errorMessage = null; // Clear any previous error
    } else {
      _stopRealTimeListeners();
      _errorMessage = user == null ? 'Authentication required' : 'Access denied: Admin privileges required';
    }
    notifyListeners();
  }

  Future<void> _startRealTimeListeners() async {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'Authentication required';
      notifyListeners();
      return;
    }

    // Users listener (all roles)
    _usersSubscription?.cancel();
    _usersSubscription = _database.child('user').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _users = [];
          data.forEach((role, users) {
            if (users is Map) {
              users.forEach((uid, userData) async {
                if (userData is Map) {
                  try {
                    final user = await UserData.fromJson(
                        Map<String, dynamic>.from(userData), uid);
                    _users.add(user);
                  } catch (e) {
                    debugPrint('Error parsing user $uid: $e');
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

    // Projects listener (all projects for admin)
    _projectsSubscription?.cancel();
    _projectsSubscription = _database.child('projects').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _projects = data.entries.map((entry) {
            return Project.fromMap(Map<String, dynamic>.from(entry.value as Map)
              ..['id'] = entry.key);
          }).toList();
          notifyListeners();
        }
      } else {
        _projects.clear();
        notifyListeners();
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load projects: $error';
      notifyListeners();
    });

    // Contractors listener (all contractors)
    _contractorsSubscription?.cancel();
    _contractorsSubscription = _database.child('contractors').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _contractors = data.entries.map((entry) {
            return Contractor.fromMap(Map<String, dynamic>.from(entry.value as Map)
              ..['uid'] = entry.key);
          }).toList();
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

  // Keep other methods (loadSettings, loadSupportTickets, loadContent, etc.) as they are, but ensure they check isAdmin
  Future<void> loadSettings() async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can access settings';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('settings').get();
      _settings = snapshot.exists && snapshot.value != null
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : {'notificationsEnabled': true, 'twoFactorAuthEnabled': false};
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSupportTickets() async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can access support tickets';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('supportTickets').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _supportTickets = data.entries.map((entry) {
          return Map<String, dynamic>.from(entry.value as Map)..['id'] = entry.key;
        }).toList();
      } else {
        _supportTickets = [];
      }
    } catch (e) {
      _errorMessage = 'Failed to load support tickets: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadContent() async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can access content';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('content').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _content = data.entries.map((entry) {
          return Map<String, dynamic>.from(entry.value as Map)..['id'] = entry.key;
        }).toList();
      } else {
        _content = [];
      }
    } catch (e) {
      _errorMessage = 'Failed to load content: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can manage users';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('user').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _users = [];
        data.forEach((role, users) {
          if (users is Map) {
            users.forEach((uid, userData) async {
              if (userData is Map) {
                try {
                  final user = await UserData.fromJson(
                      Map<String, dynamic>.from(userData), uid);
                  _users.add(user);
                } catch (e) {
                  debugPrint('Error parsing user $uid: $e');
                }
              }
            });
          }
        });
        _users.sort((a, b) => a.email.compareTo(b.email));
      }
    } catch (e) {
      _errorMessage = 'Failed to load users: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProjects() async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can manage projects';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('projects').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        _projects = data != null
            ? data.entries.map((entry) {
          return Project.fromMap(
              Map<String, dynamic>.from(entry.value as Map)..['id'] = entry.key);
        }).toList()
            : [];
      } else {
        _projects.clear();
      }
    } catch (e) {
      _errorMessage = 'Failed to load projects: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadContractors() async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can manage contractors';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('contractors').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        _contractors = data != null
            ? data.entries.map((entry) {
          return Contractor.fromMap(
              Map<String, dynamic>.from(entry.value as Map)..['uid'] = entry.key);
        }).toList()
            : [];
      } else {
        _contractors.clear();
      }
    } catch (e) {
      _errorMessage = 'Failed to load contractors: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createUser(String email, String password, UserRole role) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can create users';
      notifyListeners();
      return;
    }
    if (!_validateEmail(email)) {
      _errorMessage = 'Invalid email format';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
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
      _errorMessage = 'Failed to create user: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(UserData user) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update users';
      notifyListeners();
      return;
    }
    try {
      await _database.child('user/${user.role.name}/${user.uid}').update(user.toJson());
    } catch (e) {
      _errorMessage = 'Failed to update user: $e';
      notifyListeners();
    }
  }

  Future<void> deleteUser(String uid) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can delete users';
      notifyListeners();
      return;
    }
    try {
      final user = _users.firstWhere((u) => u.uid == uid);
      await _database.child('user/${user.role.name}/$uid').remove();
      await _auth.currentUser?.delete(); // Optional: Delete Firebase Auth user
    } catch (e) {
      _errorMessage = 'Failed to delete user: $e';
      notifyListeners();
    }
  }

  Future<void> suspendUser(String uid, String status) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can suspend users';
      notifyListeners();
      return;
    }
    try {
      final user = _users.firstWhere((u) => u.uid == uid);
      await _database.child('user/${user.role.name}/$uid/status').set(status);
    } catch (e) {
      _errorMessage = 'Failed to suspend user: $e';
      notifyListeners();
    }
  }

  Future<void> updateProject(Project project) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update projects';
      notifyListeners();
      return;
    }
    try {
      await _database.child('projects/${project.id}').update(project.toJson());
    } catch (e) {
      _errorMessage = 'Failed to update project: $e';
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can delete projects';
      notifyListeners();
      return;
    }
    try {
      await _database.child('projects/$projectId').remove();
    } catch (e) {
      _errorMessage = 'Failed to delete project: $e';
      notifyListeners();
    }
  }

  Future<void> updateContent(String type, String content) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update content';
      notifyListeners();
      return;
    }
    try {
      final newContent = {
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final contentRef = _database.child('content').push();
      await contentRef.set(newContent);
    } catch (e) {
      _errorMessage = 'Failed to update content: $e';
      notifyListeners();
    }
  }

  Future<void> editContent(String contentId, String type, String content) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can edit content';
      notifyListeners();
      return;
    }
    try {
      final updatedContent = {
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _database.child('content/$contentId').update(updatedContent);
    } catch (e) {
      _errorMessage = 'Failed to edit content: $e';
      notifyListeners();
    }
  }

  Future<void> deleteContent(String contentId) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can delete content';
      notifyListeners();
      return;
    }
    try {
      await _database.child('content/$contentId').remove();
    } catch (e) {
      _errorMessage = 'Failed to delete content: $e';
      notifyListeners();
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update settings';
      notifyListeners();
      return;
    }
    try {
      await _database.child('settings').update(settings);
      await loadSettings();
    } catch (e) {
      _errorMessage = 'Failed to update settings: $e';
      notifyListeners();
    }
  }

  Future<void> updateSupportTicket(String ticketId, String status) async {
    if (!isAdmin) {
      _errorMessage = 'Only admins can update support tickets';
      notifyListeners();
      return;
    }
    try {
      final updatedTicket = {
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _database.child('supportTickets/$ticketId').update(updatedTicket);
      await loadSupportTickets();
    } catch (e) {
      _errorMessage = 'Failed to update support ticket: $e';
      notifyListeners();
    }
  }

  bool _validateEmail(String email) {
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  @override
  void dispose() {
    _stopRealTimeListeners();
    _authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}*/
