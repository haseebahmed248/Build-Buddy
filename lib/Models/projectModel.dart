class Project {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userType;
  final ProjectStatus status;
  final int progress;
  final DateTime? date;
  final String icon;
  final String? assignedContractorId;
  final String? assignedArchitectId;
  final List<Message>? messages;
  final bool reviewed;
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userType,
    this.status = ProjectStatus.pending,
    this.progress = 0,
    this.date,
    this.icon = 'work',
    this.assignedContractorId,
    this.assignedArchitectId,
    this.messages,
    this.reviewed = false,
    this.createdAt,
    this.lastUpdated,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('id') || map['id'] == null || map['id'].toString().isEmpty) {
      throw ArgumentError('Project ID is required');
    }
    if (!map.containsKey('userId') || map['userId'] == null || map['userId'].toString().isEmpty) {
      throw ArgumentError('User ID is required');
    }
    return Project(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userType: map['userType']?.toString() ?? '',
      status: map['status'] != null
          ? ProjectStatus.values.firstWhere(
            (e) => e.toString().split('.').last == map['status'],
        orElse: () => ProjectStatus.pending,
      )
          : ProjectStatus.pending,
      progress: int.tryParse(map['progress']?.toString() ?? '0') ?? 0,
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      icon: map['icon']?.toString() ?? 'work',
      assignedContractorId: map['assignedContractorId']?.toString(),
      assignedArchitectId: map['assignedArchitectId']?.toString(),
      messages: _parseMessages(map['messages']),
      reviewed: map['reviewed'] == true,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      lastUpdated: map['lastUpdated'] != null ? DateTime.tryParse(map['lastUpdated']) : null,
    );
  }

  static List<Message>? _parseMessages(dynamic messagesData) {
    if (messagesData == null) {
      return [];
    }
    if (messagesData is List) {
      return messagesData.map((msg) => Message.fromMap(Map<String, dynamic>.from(msg), id: '')).toList();
    }
    if (messagesData is Map) {
      final messagesMap = Map<String, dynamic>.from(messagesData);
      return messagesMap.entries.map((entry) {
        return Message.fromMap(Map<String, dynamic>.from(entry.value), id: entry.key);
      }).toList();
    }
    print('Unexpected messages data type: ${messagesData.runtimeType}');
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'userType': userType,
      'status': status.toString().split('.').last,
      'progress': progress,
      'date': date?.toIso8601String(),
      'icon': icon,
      'assignedContractorId': assignedContractorId,
      'assignedArchitectId': assignedArchitectId,
      'messages': messages?.map((msg) => msg.toMap()).toList(),
      'reviewed': reviewed,
      'createdAt': createdAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}

class Message {
  final String id;
  final String senderId;
  final String senderType;
  final String content;
  final DateTime timestamp;
  final bool read;

  Message({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.timestamp,
    this.read = false,
  });

  factory Message.fromMap(Map<String, dynamic> map, {required String id}) {
    return Message(
      id: id,
      senderId: map['senderId']?.toString() ?? '',
      senderType: map['senderType']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
      read: map['read'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderType': senderType,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
    };
  }
}

enum ProjectStatus {
  pending,
  inProgress,
  completed,
}










///////////////////////////////////////////

/*import 'package:flutter/material.dart';

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

}*/

///////////////////////////////


/*

class Project {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userType;
  final ProjectStatus status;
  final int progress;
  final DateTime? date;
  final String icon;
  final String? assignedContractorId;
  final String? assignedArchitectId;
  final List<Message>? messages;
  final bool reviewed;
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userType,
    this.status = ProjectStatus.pending,
    this.progress = 0,
    this.date,
    this.icon = 'work',
    this.assignedContractorId,
    this.assignedArchitectId,
    this.messages,
    this.reviewed = false,
    this.createdAt,
    this.lastUpdated,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userType: map['userType']?.toString() ?? '',
      status: map['status'] != null
          ? ProjectStatus.values.firstWhere(
            (e) => e.toString().split('.').last == map['status'],
        orElse: () => ProjectStatus.pending,
      )
          : ProjectStatus.pending,
      progress: int.tryParse(map['progress']?.toString() ?? '0') ?? 0,
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      icon: map['icon']?.toString() ?? 'work',
      assignedContractorId: map['assignedContractorId']?.toString(),
      assignedArchitectId: map['assignedArchitectId']?.toString(),
      messages: _parseMessages(map['messages']),
      reviewed: map['reviewed'] == true,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      lastUpdated: map['lastUpdated'] != null ? DateTime.tryParse(map['lastUpdated']) : null,
    );
  }

  static List<Message>? _parseMessages(dynamic messagesData) {
    if (messagesData == null) {
      return [];
    }
    if (messagesData is List) {
      return messagesData.map((msg) => Message.fromMap(Map<String, dynamic>.from(msg), id: '')).toList();
    }
    if (messagesData is Map) {
      final messagesMap = Map<String, dynamic>.from(messagesData);
      return messagesMap.entries.map((entry) {
        return Message.fromMap(Map<String, dynamic>.from(entry.value), id: entry.key);
      }).toList();
    }
    print('Unexpected messages data type: ${messagesData.runtimeType}');
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'userType': userType,
      'status': status.toString().split('.').last,
      'progress': progress,
      'date': date?.toIso8601String(),
      'icon': icon,
      'assignedContractorId': assignedContractorId,
      'assignedArchitectId': assignedArchitectId,
      'messages': messages?.map((msg) => msg.toMap()).toList(),
      'reviewed': reviewed,
      'createdAt': createdAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}

class Message {
  final String id;
  final String senderId;
  final String senderType;
  final String content;
  final DateTime timestamp;
  final bool read;

  Message({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.timestamp,
    this.read = false,
  });

  factory Message.fromMap(Map<String, dynamic> map, {required String id}) {
    return Message(
      id: id,
      senderId: map['senderId']?.toString() ?? '',
      senderType: map['senderType']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
      read: map['read'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderType': senderType,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
    };
  }
}

enum ProjectStatus {
  pending,
  inProgress,
  completed,
}
*/








