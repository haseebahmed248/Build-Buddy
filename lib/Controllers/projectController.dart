import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/projectModel.dart';
import '../Services/projects/projectService.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  bool _isLoading = false;
  final String userType;

  ProjectController(this.userType);

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  // Load projects from Firebase
  Future<void> loadProjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _projects = await _projectService.getProjects(user.uid, userType);
    } catch (e) {
      print('Error loading projects: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add a new project
  Future<void> addProject(Project project) async {
    try {
      await _projectService.createProject(project);
      await loadProjects(); // Refresh list
    } catch (e) {
      print('Error adding project: $e');
    }
  }

  // Update an existing project
  Future<void> updateProject(Project project) async {
    try {
      await _projectService.updateProject(project);
      await loadProjects(); // Refresh list
    } catch (e) {
      print('Error updating project: $e');
    }
  }

  // Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.deleteProject(projectId, user.uid);
        await loadProjects(); // Refresh list
      }
    } catch (e) {
      print('Error deleting project: $e');
    }
  }
}










/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/projectModel.dart';
import '../Services/projects/projectService.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  bool _isLoading = false;
  final String userType;

  ProjectController(this.userType);

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  Future<void> loadProjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    _projects = []; // Reset projects before loading
    notifyListeners();

    try {
      _projects = await _projectService.getProjects(user.uid, userType);
    } catch (e) {
      print('Error loading projects: $e');
    }

    _isLoading = false;
    notifyListeners();
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

  */
/*Future<void> deleteProject(String projectId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.deleteProject(projectId, user.uid);
        await loadProjects();
      }
    } catch (e) {
      print('Error deleting project: $e');
    }
  }*//*

  Future<void> deleteProject(String projectId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _projectService.deleteProject(projectId, user.uid);
        notifyListeners(); // Notify UI updates
      }
    } catch (e) {
      print('Error deleting project: $e');
    }
  }
}
*/
