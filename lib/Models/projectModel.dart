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










///////////
/*

enum ProjectStatus { pending, inProgress, completed }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final String type;
  final bool? read;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.type,
    this.read,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'read': read,
  };

  factory Message.fromMap(Map<String, dynamic> map, {String? id}) {
    return Message(
      id: id ?? map['id'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      type: map['type'] as String,
      read: map['read'] as bool?,
    );
  }
}

class Project {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userType;
  final ProjectStatus status;
  final int progress;
  final DateTime? date;
  final String? icon;
  final String? assignedContractorId;
  final String? assignedArchitectId;
  final List<Message>? messages;
  final bool reviewed;
  final DateTime createdAt;
  final DateTime lastUpdated;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userType,
    required this.status,
    required this.progress,
    this.date,
    this.icon,
    this.assignedContractorId,
    this.assignedArchitectId,
    this.messages,
    required this.reviewed,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      userId: map['userId'] as String,
      userType: map['userType'] as String,
      status: ProjectStatus.values.firstWhere((e) => e.toString() == map['status']),
      progress: map['progress'] as int,
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : null,
      icon: map['icon'] as String?,
      assignedContractorId: map['assignedContractorId'] as String?,
      assignedArchitectId: map['assignedArchitectId'] as String?,
      messages: map['messages'] != null
          ? (map['messages'] as Map<dynamic, dynamic>)
          .entries
          .map((entry) => Message.fromMap(Map<String, dynamic>.from(entry.value as Map), id: entry.key))
          .toList()
          : null,
      reviewed: map['reviewed'] as bool? ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'userType': userType,
      'status': status.toString(),
      'progress': progress,
      'date': date?.toIso8601String(),
      'icon': icon,
      'assignedContractorId': assignedContractorId,
      'assignedArchitectId': assignedArchitectId,
      'messages': messages?.asMap().map((index, message) => MapEntry(index.toString(), message.toJson())),
      'reviewed': reviewed,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}*/
