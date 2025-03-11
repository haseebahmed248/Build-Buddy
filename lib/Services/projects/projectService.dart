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
          final contractorSnapshot = await _database.child('user/contractor/$id').get();
          if (contractorSnapshot.exists && contractorSnapshot.value != null) {
            final contractorData = Map<String, dynamic>.from(contractorSnapshot.value as Map);
            contractorData['uid'] = id;
            try {
              professionals.add(Contractor.fromMap(contractorData));
            } catch (e) {
              print('Error parsing contractor $id: $e');
            }
            continue;
          }

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

  Future<List<Professional>> getUsersForContractor(String contractorId) async {
    try {
      final snapshot = await _database.child('projects').orderByChild('assignedContractorId').equalTo(contractorId).get();
      if (snapshot.exists && snapshot.value != null) {
        final projectsData = Map<String, dynamic>.from(snapshot.value as Map);
        final List<String> userIds = [];
        projectsData.forEach((_, projectData) {
          if (projectData is Map) {
            final projectMap = Map<String, dynamic>.from(projectData);
            if (projectMap['userId'] != null && !userIds.contains(projectMap['userId'])) {
              userIds.add(projectMap['userId']);
            }
            if (projectMap['vendorId'] != null && !userIds.contains(projectMap['vendorId'])) {
              userIds.add(projectMap['vendorId']);
            }
          }
        });

        final List<Professional> users = [];
        for (String id in userIds) {
          final homeownerSnapshot = await _database.child('user/homeowner/$id').get();
          if (homeownerSnapshot.exists && homeownerSnapshot.value != null) {
            final homeownerData = Map<String, dynamic>.from(homeownerSnapshot.value as Map);
            homeownerData['uid'] = id;
            try {
              users.add(Professional.fromMap({...homeownerData, 'role': 'Homeowner'}));
            } catch (e) {
              print('Error parsing homeowner $id: $e');
            }
            continue;
          }

          final vendorSnapshot = await _database.child('user/vendor/$id').get();
          if (vendorSnapshot.exists && vendorSnapshot.value != null) {
            final vendorData = Map<String, dynamic>.from(vendorSnapshot.value as Map);
            vendorData['uid'] = id;
            try {
              users.add(Professional.fromMap({...vendorData, 'role': 'Vendor'}));
            } catch (e) {
              print('Error parsing vendor $id: $e');
            }
          }
        }
        return users;
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

/////
  Future<Map<String, List<Map<String, dynamic>>>> getAllReviews() async {
    try {
      final snapshot = await _database.child('reviews').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        Map<String, List<Map<String, dynamic>>> professionalReviews = {};

        data.forEach((reviewId, reviewData) {
          if (reviewData is Map) {
            final review = Map<String, dynamic>.from(reviewData);
            String professionalId = review['professionalId'] ?? '';

            if (professionalId.isNotEmpty) {
              if (!professionalReviews.containsKey(professionalId)) {
                professionalReviews[professionalId] = [];
              }
              review['id'] = reviewId; // Store the review ID as well
              professionalReviews[professionalId]!.add(review);
            }
          }
        });

        return professionalReviews;
      }
      return {};
    } catch (e) {
      print('Error fetching reviews: $e');
      throw Exception('Failed to fetch reviews: $e');
    }
  }
///////////
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
      final reviewId = _database.child('reviews/homeowner_reviews').push().key;
      if (reviewId == null) throw Exception('Failed to generate review ID');
      await _database.child('reviews/homeowner_reviews/$reviewId').set({
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

  Future<void> saveContractorReview(String projectId, String contractorId, String reviewedUserId, String userId, int rating, String review, String reviewedUserRole) async {
    try {
      final reviewId = _database.child('reviews/contractor_reviews/$contractorId').push().key;
      if (reviewId == null) throw Exception('Failed to generate review ID');
      await _database.child('reviews/contractor_reviews/$contractorId/$reviewId').set({
        'projectId': projectId,
        'contractorId': contractorId,
        'reviewedUserId': reviewedUserId,
        'userId': userId,
        'rating': rating,
        'review': review,
        'reviewedUserRole': reviewedUserRole,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _database.child('projects/$projectId').update({'reviewed': true});
    } catch (e) {
      print('Error saving contractor review: $e');
      throw Exception('Failed to save contractor review: $e');
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