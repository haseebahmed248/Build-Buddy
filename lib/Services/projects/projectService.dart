import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/projectModel.dart';

class ProjectService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Create a new project
  Future<void> createProject(Project project) async {
    try {
      await _database.child('projects').child(project.id).set(project.toJson());
      await _database.child('userProjects').child(project.userId).child(project.id).set(true);
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }
  ////////////////////////////////////////
  /*Future<void> assignProject(String projectId, String? contractorId, String? architectId) async {
    try {
      await FirebaseDatabase.instance.ref('projects/$projectId').update({
        'assignedContractorId': contractorId ?? '',
        'assignedArchitectId': architectId ?? '',
      });
      print("Project assigned successfully");
    } catch (e) {
      print("Error assigning project: $e");
    }
  }


  Future<List<Project>> getAssignedProjects(String userId, String userType) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('projects').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        return data.entries
            .map((entry) => Project.fromJson(Map<String, dynamic>.from(entry.value)))
            .where((project) =>
        (userType == "contractor" && project.assignedContractorId == userId) ||
            (userType == "architect" && project.assignedArchitectId == userId))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching assigned projects: $e");
      return [];
    }
  }*/


  ///////////////////////////////


  // Fetch projects based on user role (Homeowner, Contractor, Architect)
  /*Future<List<Project>> getProjects(String userId, String userType) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('projects')
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print("Fetched projects: ${data.length}"); // ✅ Debugging print

        return data.entries.map((entry) {
          return Project.fromJson(Map<String, dynamic>.from(entry.value)); // ✅ Corrected
        }).toList();
      } else {
        print("No projects found for userId: $userId");
        return [];
      }
    } catch (e) {
      print("Error fetching projects: $e");
      return [];
    }
  }*/


  Future<List<Project>> getProjects(String userId, String userType) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('projects').orderByChild('userId').equalTo(userId).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print("Fetched projects: ${data.length}"); // ✅ Debugging print

        return data.entries.map((entry) {
          return Project.fromMap(Map<String, dynamic>.from(entry.value));
        }).toList();
      } else {
        print("No projects found for userId: $userId");
        return [];
      }
    } catch (e) {
      print("Error fetching projects: $e");
      return [];
    }
  }


  // Update an existing project
  Future<void> updateProject(Project project) async {
    try {
      await _database.child('projects').child(project.id).update(project.toJson());
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  // Delete a project
  Future<void> deleteProject(String projectId, String userId) async {
    try {
      await FirebaseDatabase.instance
          .ref('projects')
          .child(projectId) // ✅ Directly reference projectId
          .remove();

      print("Project deleted successfully: $projectId");
    } catch (e) {
      print("Error deleting project: $e");
    }
  }

}










/*
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/projectModel.dart';

import '../../Models/projectModel.dart';

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
*/
