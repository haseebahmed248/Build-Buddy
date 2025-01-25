
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buildbuddyfyp/Models/projectModel.dart';
import 'package:buildbuddyfyp/Services/projects/projectService.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  bool _isLoading = false;
  final String userType;

  ProjectController(this.userType);

  List<Project> get projects => _projects;

  bool get isLoading => _isLoading;

  //Future<void> loadProjects() async {
    Future<void> loadProjects() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final projectsRef = FirebaseDatabase.instance
          .ref()
          .child('userProjects')
          .child(user.uid);
      _isLoading = true;
      notifyListeners();

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _projects = await _projectService.getProjects(user.uid, userType);
        }
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
        rethrow;
      }
    }

    Future<void> updateProject(Project project) async {
      try {
        await _projectService.updateProject(project);
        await loadProjects();
      } catch (e) {
        print('Error updating project: $e');
        rethrow;
      }
    }

    Future<void> deleteProject(String projectId) async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _projectService.deleteProject(projectId, user.uid);
          await loadProjects();
        }
      } catch (e) {
        print('Error deleting project: $e');
        rethrow;
      }
    }
  }


