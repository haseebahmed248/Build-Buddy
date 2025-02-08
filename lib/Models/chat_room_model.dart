import 'package:firebase_database/firebase_database.dart';

class ChatRoom {
  final String id;
  final List<String> participants;
  final List<String> participantNames;
  final List<String> participantRoles;
  final String lastMessage;
  final String lastMessageTime;
  final String lastMessageSenderId;
  final String createdAt;

  // Constructor with required named parameters
  ChatRoom({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantRoles,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.createdAt,
  });

  // Convert a JSON map into a ChatRoom object
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      participantNames: List<String>.from(json['participantNames'] ?? []),
      participantRoles: List<String>.from(json['participantRoles'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  // Convert a ChatRoom object into a map to be saved to Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'participantNames': participantNames,
      'participantRoles': participantRoles,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageSenderId': lastMessageSenderId,
      'createdAt': createdAt,
    };
  }
}
