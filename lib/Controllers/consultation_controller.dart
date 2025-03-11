import 'package:buildbuddy/Models/consultation_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ConsultationController with ChangeNotifier {
  final DatabaseReference _baseRef = FirebaseDatabase.instance.ref();
  List<Consultation> _consultations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Consultation> get consultations => _consultations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadConsultations({required bool isArchitect}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final path = isArchitect
          ? 'consultations/byArchitect/$uid'
          : 'consultations/byHomeowner/$uid';

      final snapshot = await _baseRef.child(path).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _consultations = [];

        data.forEach((key, value) {
          final consultationData = Map<String, dynamic>.from(value as Map);
          _consultations.add(Consultation.fromJson(key, consultationData));
        });
      } else {
        _consultations = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading consultations: $e';
      notifyListeners();
      print(_errorMessage);
    }
  }

  Future<void> scheduleConsultation(Consultation consultation) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Validate required fields
      if (consultation.homeownerId.isEmpty ||
          consultation.architectId.isEmpty ||
          consultation.projectId.isEmpty ||
          consultation.projectTitle.isEmpty ||
          consultation.status.isEmpty) {
        throw Exception('All required fields must be provided.');
      }

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final homeownerPath = 'consultations/byHomeowner/${consultation.homeownerId}';
      final architectPath = 'consultations/byArchitect/${consultation.architectId}';

      final consultationData = {
        'projectId': consultation.projectId,
        'projectTitle': consultation.projectTitle,
        'date': consultation.date.toIso8601String(),
        'status': consultation.status,
        'notes': consultation.notes,
        'homeownerId': consultation.homeownerId,
        'architectId': consultation.architectId,
      };

      final newRef = _baseRef.child(homeownerPath).push();
      final consultationId = newRef.key!;

      await Future.wait([
        newRef.set(consultationData),
        _baseRef.child('$architectPath/$consultationId').set(consultationData),
      ]);

      final newConsultation = consultation.copyWith(id: consultationId);
      _consultations.add(newConsultation);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error scheduling consultation: $e';
      notifyListeners();
      print(_errorMessage);
    }
  }

  Future<void> updateConsultationStatus(String consultationId, String newStatus) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final consultationIndex = _consultations.indexWhere((c) => c.id == consultationId);
      if (consultationIndex == -1) {
        throw Exception('Consultation not found');
      }

      final consultation = _consultations[consultationIndex];

      final homeownerPath = 'consultations/byHomeowner/${consultation.homeownerId}/$consultationId';
      final architectPath = 'consultations/byArchitect/${consultation.architectId}/$consultationId';

      await Future.wait([
        _baseRef.child(homeownerPath).update({'status': newStatus}),
        _baseRef.child(architectPath).update({'status': newStatus}),
      ]);

      _consultations[consultationIndex] = consultation.copyWith(status: newStatus);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error updating consultation status: $e';
      notifyListeners();
      print(_errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getAssignedArchitects() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final projectsRef = _baseRef.child('projects/$uid');
      final snapshot = await projectsRef.get();

      List<Map<String, dynamic>> architects = [];

      if (snapshot.exists) {
        final projects = snapshot.value as Map<dynamic, dynamic>;

        projects.forEach((projectId, projectData) {
          if (projectData is Map && projectData['assignedArchitectId'] != null) {
            final architectId = projectData['assignedArchitectId'];
            final projectTitle = projectData['title'] ?? 'Untitled Project';

            architects.add({
              'architectId': architectId,
              'projectId': projectId,
              'projectTitle': projectTitle,
            });
          }
        });
      }

      return architects;
    } catch (e) {
      print('Error getting assigned architects: $e');
      return [];
    }
  }
}