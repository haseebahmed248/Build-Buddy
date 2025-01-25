import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddyfyp/Models/projectModel.dart';

class ProjectService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

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

  Future<List<Project>> getProjects(String userId, String userType) async {
    try {
      final snapshot = await _database
          .child('projects')
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      if (!snapshot.exists) return [];

      List<Project> projects = [];
      final data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        if (value['userType'] == userType) {
          projects.add(Project.fromJson(Map<String, dynamic>.from(value)));
        }
      });

      return projects;
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _database
          .child('projects')
          .child(project.id)
          .update(project.toJson());
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
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }
}
