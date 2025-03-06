/*

import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';

class ProjectService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<List<Contractor>> getContractors() async {
    try {
      print("Fetching professionals (contractors and architects) from Firebase");
      final List<Contractor> professionals = [];

      // Fetch contractors
      final contractorSnapshot = await _database.child('user/contractor').get();
      if (contractorSnapshot.exists && contractorSnapshot.value != null) {
        final contractorData = contractorSnapshot.value as Map<dynamic, dynamic>;
        print("Raw contractor data from Firebase: $contractorData");
        contractorData.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          map['uid'] = key; // Add UID as key
          map['role'] = 'Contractor'; // Set role as Contractor
          professionals.add(Contractor.fromMap(map));
        });
      }

      // Fetch architects
      final architectSnapshot = await _database.child('user/architect').get();
      if (architectSnapshot.exists && architectSnapshot.value != null) {
        final architectData = architectSnapshot.value as Map<dynamic, dynamic>;
        print("Raw architect data from Firebase: $architectData");
        architectData.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          map['uid'] = key; // Add UID as key
          map['role'] = 'Architect'; // Set role as Architect
          professionals.add(Contractor.fromMap(map));
        });
      }

      print("Professionals retrieved: ${professionals.length} - List: $professionals");
      return professionals;
    } catch (e) {
      print("Error fetching professionals: $e with stack trace: ${e.toString()}");
      return [];
    }
  }

  // Existing methods (unchanged for brevity)...
  Future<List<Project>> getProjects(String userId, String userType) async {
    try {
      print("Fetching projects for userId: $userId, userType: $userType");
      Query query;
      if (userType == 'homeowner') {
        query = _database.child('projects').orderByChild('userId').equalTo(userId);
      } else if (userType == 'contractor') {
        query = _database
            .child('projects')
            .orderByChild('assignedContractorId')
            .equalTo(userId);
      } else if (userType == 'architect') {
        query = _database
            .child('projects')
            .orderByChild('assignedArchitectId')
            .equalTo(userId);
      } else {
        print("Invalid userType: $userType");
        return [];
      }

      final snapshot = await query.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print("Raw data from Firebase for $userType: $data");
        return data.entries.map((entry) {
          print("Processing entry: ${entry.key} -> ${entry.value}");
          return Project.fromMap(Map<String, dynamic>.from(entry.value as Map));
        }).toList();
      } else {
        print("No projects found for $userType: $userId");
        return [];
      }
    } catch (e) {
      print("Error fetching projects: $e");
      return [];
    }
  }

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

  Future<void> assignProject(
      String projectId, String? contractorId, String? architectId) async {
    try {
      await _database.child('projects').child(projectId).update({
        'assignedContractorId': contractorId ?? '',
        'assignedArchitectId': architectId ?? '',
      });
      print("Project assigned successfully");
    } catch (e) {
      throw Exception('Error assigning project: $e');
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      await _database
          .child('projects')
          .child(projectId)
          .child('messages')
          .push()
          .set(message.toJson());
      print("Message sent successfully");
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _database.child('projects').child(project.id).update(project.toJson());
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
      print("Project deleted successfully: $projectId");
    } catch (e) {
      throw Exception('Error deleting project: $e');
    }
  }
}
*/




/////////



import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';

class ProjectService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<List<Project>> getProjects(String userId, String userType) async {
    try {
      Query query;
      if (userType == 'homeowner') {
        query = _database.child('projects').orderByChild('userId').equalTo(userId);
      } else if (userType == 'contractor') {
        query = _database.child('projects').orderByChild('assignedContractorId').equalTo(userId);
      } else if (userType == 'architect') {
        query = _database.child('projects').orderByChild('assignedArchitectId').equalTo(userId);
      } else {
        throw 'Invalid userType: $userType';
      }

      final snapshot = await query.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Project> projects = [];
        data.forEach((projectId, projectData) {
          final projectMap = Map<String, dynamic>.from(projectData as Map);
          projectMap['id'] = projectId;
          projects.add(Project.fromMap(projectMap));
        });
        return projects;
      }
      return [];
    } catch (e) {
      print('Error fetching projects: $e');
      rethrow;
    }
  }

  Future<List<Contractor>> getContractors() async {
    final snapshot = await _database.child('user/contractor').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final List<Contractor> contractors = [];
      data.forEach((contractorId, contractorData) {
        final contractorMap = Map<String, dynamic>.from(contractorData as Map);
        contractorMap['uid'] = contractorId;
        contractors.add(Contractor.fromMap(contractorMap));
      });
      return contractors;
    }
    return [];
  }

  Future<List<Contractor>> getProfessionalsForUser(String userId) async {
    final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
    if (snapshot.exists && snapshot.value != null) {
      final projectsData = Map<String, dynamic>.from(snapshot.value as Map);
      final List<String> professionalIds = [];
      projectsData.forEach((_, projectData) {
        final projectMap = Map<String, dynamic>.from(projectData as Map);
        if (projectMap['assignedContractorId'] != null && !professionalIds.contains(projectMap['assignedContractorId'])) {
          professionalIds.add(projectMap['assignedContractorId']);
        }
        if (projectMap['assignedArchitectId'] != null && !professionalIds.contains(projectMap['assignedArchitectId'])) {
          professionalIds.add(projectMap['assignedArchitectId']);
        }
      });

      final List<Contractor> professionals = [];
      for (String id in professionalIds) {
        final contractorSnapshot = await _database.child('user/contractor/$id').get();
        final architectSnapshot = await _database.child('user/architect/$id').get();
        if (contractorSnapshot.exists && contractorSnapshot.value != null) {
          final contractorData = Map<String, dynamic>.from(contractorSnapshot.value as Map);
          contractorData['uid'] = id;
          professionals.add(Contractor.fromMap(contractorData));
        } else if (architectSnapshot.exists && architectSnapshot.value != null) {
          final architectData = Map<String, dynamic>.from(architectSnapshot.value as Map);
          architectData['uid'] = id;
          professionals.add(Contractor.fromMap(architectData));
        }
      }
      return professionals;
    }
    return [];
  }

  Future<void> createProject(Project project) async {
    await _database.child('projects/${project.id}').set(project.toMap());
  }

  Future<void> updateProject(Project project) async {
    await _database.child('projects/${project.id}').update(project.toMap());
  }

  Future<void> deleteProject(String projectId, String userId) async {
    await _database.child('projects/$projectId').remove();
  }

  Future<void> assignProject(String projectId, String? contractorId, String? architectId) async {
    final updates = <String, dynamic>{};
    if (contractorId != null) updates['assignedContractorId'] = contractorId;
    if (architectId != null) updates['assignedArchitectId'] = architectId;
    updates['lastUpdated'] = DateTime.now().toIso8601String();
    await _database.child('projects/$projectId').update(updates);
  }

  Future<void> sendMessage(String projectId, Message message) async {
    final messageId = _database.child('projects/$projectId/messages').push().key;
    await _database.child('projects/$projectId/messages/$messageId').set(message.toMap());
  }

  Future<void> saveReview(String projectId, String professionalId, String userId, int rating, String review, String professionalRole) async {
    final reviewId = _database.child('reviews').push().key;
    await _database.child('reviews/$reviewId').set({
      'projectId': projectId,
      'professionalId': professionalId,
      'userId': userId,
      'rating': rating,
      'review': review,
      'professionalRole': professionalRole,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _database.child('projects/$projectId').update({'reviewed': true});
  }

  Future<int> getActiveProjectsCount(String userId) async {
    final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
    if (snapshot.exists && snapshot.value != null) {
      final projectsData = Map<String, dynamic>.from(snapshot.value as Map);
      return projectsData.values.where((project) {
        final projectMap = Map<String, dynamic>.from(project as Map);
        return projectMap['status'] == 'inProgress';
      }).length;
    }
    return 0;
  }

  Future<int> getPendingReviewsCount(String userId) async {
    final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
    if (snapshot.exists && snapshot.value != null) {
      final projectsData = Map<String, dynamic>.from(snapshot.value as Map);
      return projectsData.values.where((project) {
        final projectMap = Map<String, dynamic>.from(project as Map);
        return projectMap['status'] == 'completed' && projectMap['reviewed'] != true;
      }).length;
    }
    return 0;
  }

  Future<int> getNewMessagesCount(String userId) async {
    final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
    if (snapshot.exists && snapshot.value != null) {
      final projectsData = Map<String, dynamic>.from(snapshot.value as Map);
      int count = 0;
      for (var project in projectsData.values) {
        final projectMap = Map<String, dynamic>.from(project as Map);
        final messagesData = projectMap['messages'];
        if (messagesData != null && messagesData is Map) {
          final messages = Map<String, dynamic>.from(messagesData);
          count += messages.values.where((msg) {
            final msgMap = Map<String, dynamic>.from(msg as Map);
            return msgMap['read'] != true && msgMap['senderId'] != userId;
          }).length;
        }
      }
      return count;
    }
    return 0;
  }
}



///////////////



/*
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';

extension ListDistinct<T> on List<T> {
  List<T> distinctBy(dynamic Function(T) getKey) {
    final seen = <dynamic>{};
    return where((item) => seen.add(getKey(item))).toList();
  }
}

class ProjectService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<List<Contractor>> getContractors() async {
    try {
      print("Fetching professionals (contractors and architects) from Firebase");
      final List<Contractor> professionals = [];

      final contractorSnapshot = await _database.child('user/contractor').get();
      if (contractorSnapshot.exists && contractorSnapshot.value != null) {
        final contractorData = contractorSnapshot.value as Map<dynamic, dynamic>;
        print("Raw contractor data from Firebase: $contractorData");
        await _fetchProfessionalRatings('contractor', contractorData, professionals);
      } else {
        print("No contractors found at user/contractor");
      }

      final architectSnapshot = await _database.child('user/architect').get();
      if (architectSnapshot.exists && architectSnapshot.value != null) {
        final architectData = architectSnapshot.value as Map<dynamic, dynamic>;
        print("Raw architect data from Firebase: $architectData");
        await _fetchProfessionalRatings('architect', architectData, professionals);
      } else {
        print("No architects found at user/architect");
      }

      print("Professionals retrieved: ${professionals.length} - List: $professionals");
      return professionals;
    } catch (e) {
      print("Error fetching professionals: $e with stack trace: ${e.toString()}");
      return [];
    }
  }

  Future<void> _fetchProfessionalRatings(String role, Map<dynamic, dynamic> userData, List<Contractor> professionals) async {
    try {
      for (var entry in userData.entries) {
        final uid = entry.key;
        final userMap = Map<String, dynamic>.from(entry.value as Map);
        userMap['uid'] = uid;
        userMap['role'] = role;

        double rating = 0.0;
        int reviewCount = 0;
        try {
          final reviewsSnapshot = await _database.child('reviews').orderByChild('professionalId').equalTo(uid).get();
          if (reviewsSnapshot.exists && reviewsSnapshot.value != null) {
            final reviews = reviewsSnapshot.value as Map<dynamic, dynamic>;
            int totalRating = 0;
            reviewCount = reviews.length;
            reviews.forEach((_, value) {
              final review = Map<String, dynamic>.from(value as Map);
              totalRating += (review['rating'] as int?) ?? 0;
            });
            rating = reviewCount > 0 ? (totalRating / reviewCount).toDouble() : 0.0;
          }
        } catch (e) {
          print("Error fetching ratings for $uid: $e");
          rating = 0.0;
          reviewCount = 0;
        }

        userMap['rating'] = rating;
        userMap['reviewCount'] = reviewCount;
        professionals.add(Contractor.fromMap(userMap));
      }
    } catch (e) {
      print("Error processing professional ratings for role $role: $e");
    }
  }

  Future<List<Project>> getProjects(String userId, String userType) async {
    try {
      print("Fetching projects for userId: $userId, userType: $userType");
      Query query;
      if (userType == 'homeowner') {
        query = _database.child('projects').orderByChild('userId').equalTo(userId);
      } else if (userType == 'contractor') {
        query = _database.child('projects').orderByChild('assignedContractorId').equalTo(userId);
      } else if (userType == 'architect') {
        query = _database.child('projects').orderByChild('assignedArchitectId').equalTo(userId);
      } else {
        print("Invalid userType: $userType");
        return [];
      }

      query.onValue.drain();
      final snapshot = await query.get();
      print('ProjectService.getProjects snapshot: exists=${snapshot.exists}, value=${snapshot.value}');
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print("Raw data from Firebase for $userType: $data");
        return data.entries.map((entry) {
          final projectData = Map<String, dynamic>.from(entry.value as Map);
          projectData['id'] = entry.key;
          print("Processing project entry: ${entry.key} -> $projectData");
          return Project.fromMap(projectData);
        }).toList();
      } else {
        print("No projects found for $userType: $userId");
        return [];
      }
    } catch (e) {
      print("Error fetching projects: $e with stack trace: ${e.toString()}");
      return [];
    }
  }

  Future<List<Contractor>> getProfessionalsForUser(String userId) async {
    try {
      final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final projects = snapshot.value as Map<dynamic, dynamic>;
        final List<Contractor> professionals = [];
        for (var projectEntry in projects.entries) {
          final projectData = Map<String, dynamic>.from(projectEntry.value as Map);
          projectData['id'] = projectEntry.key;
          final project = Project.fromMap(projectData);
          if (project.assignedContractorId != null && project.assignedContractorId!.isNotEmpty) {
            final contractorSnapshot = await _database.child('user/contractor').child(project.assignedContractorId!).get();
            if (contractorSnapshot.exists) {
              final contractorData = Map<String, dynamic>.from(contractorSnapshot.value as Map);
              contractorData['uid'] = project.assignedContractorId;
              contractorData['role'] = 'Contractor';
              professionals.add(Contractor.fromMap(contractorData));
            }
          }
          if (project.assignedArchitectId != null && project.assignedArchitectId!.isNotEmpty) {
            final architectSnapshot = await _database.child('user/architect').child(project.assignedArchitectId!).get();
            if (architectSnapshot.exists) {
              final architectData = Map<String, dynamic>.from(architectSnapshot.value as Map);
              architectData['uid'] = project.assignedArchitectId;
              architectData['role'] = 'Architect';
              professionals.add(Contractor.fromMap(architectData));
            }
          }
        }
        print("Professionals for user $userId retrieved: ${professionals.length} - List: $professionals");
        return professionals.distinctBy((p) => p.uid).toList();
      }
      print("No projects found for user $userId in getProfessionalsForUser");
      return [];
    } catch (e) {
      print("Error fetching professionals for user: $e");
      return [];
    }
  }

  Future<void> saveReview(String projectId, String professionalId, String userId, int rating, String review, String professionalRole) async {
    try {
      final reviewId = _database.child('reviews').push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
      await _database.child('reviews').child(reviewId).set({
        'projectId': projectId,
        'professionalId': professionalId,
        'userId': userId,
        'rating': rating,
        'review': review,
        'timestamp': DateTime.now().toIso8601String(),
        'professionalRole': professionalRole,
      });

      await _database.child('projects').child(projectId).update({
        'reviewed': true,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      await _updateProfessionalRating(professionalId, professionalRole, rating);
    } catch (e) {
      throw Exception('Failed to save review: $e');
    }
  }

  Future<void> _updateProfessionalRating(String professionalId, String role, int newRating) async {
    try {
      final snapshot = await _database.child('reviews').orderByChild('professionalId').equalTo(professionalId).get();
      if (snapshot.exists && snapshot.value != null) {
        final reviews = snapshot.value as Map<dynamic, dynamic>;
        int totalRating = 0;
        int count = 0;
        reviews.forEach((_, value) {
          final review = Map<String, dynamic>.from(value as Map);
          totalRating += (review['rating'] as int?) ?? 0;
          count++;
        });
        final newAverage = count > 0 ? (totalRating / count).toDouble() : newRating.toDouble();
        await _database.child('user/$role').child(professionalId).update({
          'rating': newAverage,
          'reviewCount': count,
        });
      } else {
        await _database.child('user/$role').child(professionalId).update({
          'rating': newRating.toDouble(),
          'reviewCount': 1,
        });
      }
    } catch (e) {
      print("Error updating professional rating: $e");
    }
  }

  Future<int> getActiveProjectsCount(String userId) async {
    try {
      final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.where((entry) {
          final projectData = Map<String, dynamic>.from(entry.value as Map);
          projectData['id'] = entry.key;
          final project = Project.fromMap(projectData);
          return project.status == ProjectStatus.inProgress || project.status == ProjectStatus.pending;
        }).length;
      }
      return 0;
    } catch (e) {
      print("Error fetching active projects count: $e");
      return 0;
    }
  }

  Future<int> getPendingReviewsCount(String userId) async {
    try {
      final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.where((entry) {
          final projectData = Map<String, dynamic>.from(entry.value as Map);
          projectData['id'] = entry.key;
          final project = Project.fromMap(projectData);
          return project.status == ProjectStatus.completed && (project.reviewed ?? false) == false;
        }).length;
      }
      return 0;
    } catch (e) {
      print("Error fetching pending reviews count: $e");
      return 0;
    }
  }

  Future<int> getNewMessagesCount(String userId) async {
    try {
      final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int unreadCount = 0;
        data.forEach((projectKey, projectValue) {
          final projectData = Map<String, dynamic>.from(projectValue as Map);
          projectData['id'] = projectKey;
          final project = Project.fromMap(projectData);
          if (project.messages != null) {
            unreadCount += project.messages!.where((message) => !(message.read ?? true)).length;
          }
        });
        return unreadCount;
      }
      return 0;
    } catch (e) {
      print("Error fetching new messages count: $e");
      return 0;
    }
  }

  Future<void> createProject(Project project) async {
    try {
      final projectData = project.toJson();
      projectData['createdAt'] = DateTime.now().toIso8601String();
      projectData['lastUpdated'] = DateTime.now().toIso8601String();
      await _database.child('projects').child(project.id).set(projectData);
      await _database
          .child('userProjects')
          .child(project.userId)
          .child(project.id)
          .set(true);
      print("Project created successfully: ${project.id}");
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<void> assignProject(String projectId, String? contractorId, String? architectId) async {
    try {
      print("Updating project $projectId assignment in Firebase");
      await _database.child('projects').child(projectId).update({
        'assignedContractorId': contractorId ?? '',
        'assignedArchitectId': architectId ?? '',
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      print("Project assigned successfully");
    } catch (e) {
      throw Exception('Error assigning project: $e');
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      await _database
          .child('projects')
          .child(projectId)
          .child('messages')
          .push()
          .set(message.toJson());
      await _database.child('projects').child(projectId).update({
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      print("Message sent successfully");
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      final projectData = project.toJson();
      projectData['lastUpdated'] = DateTime.now().toIso8601String();
      await _database.child('projects').child(project.id).update(projectData);
      print("Project updated successfully: ${project.id}");
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
      print("Project deleted successfully: $projectId");
    } catch (e) {
      throw Exception('Error deleting project: $e');
    }
  }
}*/
