/*import 'package:flutter/material.dart';

enum ProjectStatus { inProgress, completed, pending }

class Project {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userType;
  final String? assignedContractorId;
  final String? assignedArchitectId;
  final ProjectStatus status;
  final int progress;
  final String date;
  final String icon;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userType,
    this.assignedContractorId, // ✅ Optional
    this.assignedArchitectId, // ✅ Optional
    required this.status,
    required this.progress,
    required this.date,
    required this.icon,
  });

  // Convert Project object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'userType': userType,
      'assignedContractorId': assignedContractorId ?? '',
      'assignedArchitectId': assignedArchitectId ?? '',
      'status': status.toString().split('.').last,
      'progress': progress,
      'date': date,
      'icon': icon,
    };
  }

  // Convert JSON to Project object
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      userType: json['userType'],
      assignedContractorId: json['assignedContractorId'] ?? '',
      assignedArchitectId: json['assignedArchitectId'] ?? '',
      status: ProjectStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      progress: json['progress'],
      date: json['date'],
      icon: json['icon'],
    );
  }
}*/













import 'package:flutter/material.dart';

enum ProjectStatus { inProgress, completed, pending }

class Project {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userType; // homeowner, contractor, architect
  final ProjectStatus status;
  final int progress; // 0-100%
  final String date;
  final String icon;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userType,
    required this.status,
    required this.progress,
    required this.date,
    required this.icon,
  });

  // Convert Project object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'userType': userType,
      'status': status.toString().split('.').last,
      'progress': progress,
      'date': date,
      'icon': icon,
    };
  }

  // Convert Map (Firebase data) to Project object
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'].toString(), // Convert to String
      title: map['title'].toString(),
      description: map['description'].toString(),
      userId: map['userId'].toString(),
      userType: map['userType'].toString(),
      status: ProjectStatus.values.firstWhere(
            (e) => e.toString().split('.').last == map['status'].toString(),
        orElse: () => ProjectStatus.pending, // Default if status is missing
      ),
      progress: map['progress'] is int ? map['progress'] : int.tryParse(map['progress'].toString()) ?? 0, // Convert to int
      date: map['date'].toString(),
      icon: map['icon'].toString(),
    );
  }

}








/*
import 'package:flutter/material.dart';

enum ProjectStatus { inProgress, completed, pending }

class Project {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userType; // homeowner, contractor, architect
  final ProjectStatus status;
  final int progress; // 0-100%
  final String date;
  final String icon;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userType,
    required this.status,
    required this.progress,
    required this.date,
    required this.icon,
  });
// Helper function to map stored string to an actual IconData
  static IconData _mapStringToIcon(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'construction':
        return Icons.construction;
      default:
        return Icons.work; // Default icon
    }
  }
  // Convert Project object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'userType': userType,
      'status': status.toString().split('.').last,
      'progress': progress,
      'date': date,
      'icon': icon,
    };
  }

  // Convert JSON to Project object
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      userType: json['userType'],
      status: ProjectStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      progress: json['progress'],
      date: json['date'],
      icon: json['icon'],);
  }
}
*/








/*
import 'package:flutter/cupertino.dart';

enum ProjectStatus {
  inProgress,
  completed,
  pending
}

class Project {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userType; // homeowner, contractor, architect
  final ProjectStatus status;
  final int progress;
  final String date;
  final IconData icon;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userType,
    required this.status,
    required this.progress,
    required this.date,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'userType': userType,
      'status': status.toString().split('.').last,
      'progress': progress,
      'date': date,
      'icon': icon.codePoint,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      userType: json['userType'],
      status: ProjectStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      progress: json['progress'],
      date: json['date'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    );
  }
}
*/
