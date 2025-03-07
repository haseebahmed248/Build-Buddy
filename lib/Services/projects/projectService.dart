// lib/Services/projects/projectService.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/Professional.dart';
import 'package:buildbuddy/Models/contractorModel.dart';
import 'package:buildbuddy/Models/architectModel.dart';

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
        throw ArgumentError('Invalid userType: $userType');
      }

      final snapshot = await query.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Project> projects = [];
        data.forEach((projectId, projectData) {
          if (projectData is Map) {
            final projectMap = Map<String, dynamic>.from(projectData);
            projectMap['id'] = projectId;
            try {
              projects.add(Project.fromMap(projectMap));
            } catch (e) {
              print('Error parsing project $projectId: $e, Data: $projectMap');
            }
          }
        });
        return projects;
      }
      return [];
    } catch (e) {
      print('Error fetching projects: $e');
      throw Exception('Failed to fetch projects: $e');
    }
  }

  Future<List<Professional>> getContractors() async {
    try {
      final snapshot = await _database.child('user/contractor').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Professional> contractors = [];
        data.forEach((contractorId, contractorData) {
          if (contractorData is Map) {
            final contractorMap = Map<String, dynamic>.from(contractorData);
            contractorMap['uid'] = contractorId;
            try {
              contractors.add(Contractor.fromMap(contractorMap));
            } catch (e) {
              print('Error parsing contractor $contractorId: $e');
            }
          }
        });
        return contractors;
      }
      return [];
    } catch (e) {
      print('Error fetching contractors: $e');
      throw Exception('Failed to fetch contractors: $e');
    }
  }

  Future<List<Professional>> getArchitects() async {
    try {
      final snapshot = await _database.child('user/architect').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Professional> architects = [];
        data.forEach((architectId, architectData) {
          if (architectData is Map) {
            final architectMap = Map<String, dynamic>.from(architectData);
            architectMap['uid'] = architectId;
            try {
              architects.add(Architect.fromMap(architectMap));
            } catch (e) {
              print('Error parsing architect $architectId: $e');
            }
          }
        });
        return architects;
      }
      return [];
    } catch (e) {
      print('Error fetching architects: $e');
      throw Exception('Failed to fetch architects: $e');
    }
  }

  Future<List<Professional>> getProfessionalsForUser(String userId) async {
    try {
      final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final projectsData = Map<String, dynamic>.from(snapshot.value as Map);
        final List<String> professionalIds = [];
        projectsData.forEach((_, projectData) {
          if (projectData is Map) {
            final projectMap = Map<String, dynamic>.from(projectData);
            if (projectMap['assignedContractorId'] != null &&
                !professionalIds.contains(projectMap['assignedContractorId'])) {
              professionalIds.add(projectMap['assignedContractorId']);
            }
            if (projectMap['assignedArchitectId'] != null &&
                !professionalIds.contains(projectMap['assignedArchitectId'])) {
              professionalIds.add(projectMap['assignedArchitectId']);
            }
          }
        });

        final List<Professional> professionals = [];
        for (String id in professionalIds) {
          // Fetch contractor
          final contractorSnapshot = await _database.child('user/contractor/$id').get();
          if (contractorSnapshot.exists && contractorSnapshot.value != null) {
            final contractorData = Map<String, dynamic>.from(contractorSnapshot.value as Map);
            contractorData['uid'] = id;
            try {
              professionals.add(Contractor.fromMap(contractorData));
            } catch (e) {
              print('Error parsing contractor $id: $e');
            }
            continue; // Skip architect check if contractor is found
          }

          // Fetch architect
          final architectSnapshot = await _database.child('user/architect/$id').get();
          if (architectSnapshot.exists && architectSnapshot.value != null) {
            final architectData = Map<String, dynamic>.from(architectSnapshot.value as Map);
            architectData['uid'] = id;
            try {
              professionals.add(Architect.fromMap(architectData));
            } catch (e) {
              print('Error parsing architect $id: $e');
            }
          }
        }
        return professionals;
      }
      return [];
    } catch (e) {
      print('Error fetching professionals: $e');
      throw Exception('Failed to fetch professionals: $e');
    }
  }

  Future<void> createProject(Project project) async {
    try {
      await _database.child('projects/${project.id}').set(project.toMap());
    } catch (e) {
      print('Error creating project: $e');
      throw Exception('Failed to create project: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _database.child('projects/${project.id}').update(project.toMap());
    } catch (e) {
      print('Error updating project: $e');
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String projectId, String userId) async {
    try {
      await _database.child('projects/$projectId').remove();
    } catch (e) {
      print('Error deleting project: $e');
      throw Exception('Failed to delete project: $e');
    }
  }

  Future<void> assignProject(String projectId, String? contractorId, String? architectId) async {
    try {
      final updates = <String, dynamic>{};
      if (contractorId != null) updates['assignedContractorId'] = contractorId;
      if (architectId != null) updates['assignedArchitectId'] = architectId;
      updates['lastUpdated'] = DateTime.now().toIso8601String();
      await _database.child('projects/$projectId').update(updates);
    } catch (e) {
      print('Error assigning project: $e');
      throw Exception('Failed to assign project: $e');
    }
  }

  Future<void> sendMessage(String projectId, Message message) async {
    try {
      if (projectId.isEmpty) throw ArgumentError('projectId cannot be empty');
      if (message.content.isEmpty) throw ArgumentError('Message content cannot be empty');
      final messageId = _database.child('projects/$projectId/messages').push().key;
      if (messageId == null) throw Exception('Failed to generate message ID');
      await _database.child('projects/$projectId/messages/$messageId').set(message.toMap());
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> saveReview(String projectId, String professionalId, String userId, int rating, String review, String professionalRole) async {
    try {
      final reviewId = _database.child('reviews').push().key;
      if (reviewId == null) throw Exception('Failed to generate review ID');
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
    } catch (e) {
      print('Error saving review: $e');
      throw Exception('Failed to save review: $e');
    }
  }

  Future<int> getActiveProjectsCount(String userId) async {
    try {
      final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final projectsData = Map<String, dynamic>.from(snapshot.value as Map);
        return projectsData.values.where((project) {
          final projectMap = Map<String, dynamic>.from(project as Map);
          return projectMap['status'] == 'inProgress';
        }).length;
      }
      return 0;
    } catch (e) {
      print('Error fetching active projects count: $e');
      throw Exception('Failed to fetch active projects count: $e');
    }
  }

  Future<int> getPendingReviewsCount(String userId) async {
    try {
      final snapshot = await _database.child('projects').orderByChild('userId').equalTo(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final projectsData = Map<String, dynamic>.from(snapshot.value as Map);
        return projectsData.values.where((project) {
          final projectMap = Map<String, dynamic>.from(project as Map);
          return projectMap['status'] == 'completed' && projectMap['reviewed'] != true;
        }).length;
      }
      return 0;
    } catch (e) {
      print('Error fetching pending reviews count: $e');
      throw Exception('Failed to fetch pending reviews count: $e');
    }
  }

  Future<int> getNewMessagesCount(String userId, String userType) async {
    try {
      Query query;
      if (userType == 'homeowner') {
        query = _database.child('projects').orderByChild('userId').equalTo(userId);
      } else if (userType == 'contractor') {
        query = _database.child('projects').orderByChild('assignedContractorId').equalTo(userId);
      } else if (userType == 'architect') {
        query = _database.child('projects').orderByChild('assignedArchitectId').equalTo(userId);
      } else {
        return 0; // Invalid userType
      }

      final snapshot = await query.get();
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
    } catch (e) {
      print('Error fetching new messages count: $e');
      throw Exception('Failed to fetch new messages count: $e');
    }
  }
}







/////////////////////////////////////////////////////////////////////////////////////////////



/*
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
*/


