import 'package:cloud_firestore/cloud_firestore.dart';

// chat_room_model.dart
class ChatRoom {
  final String id;
  final List<String> participants;
  final List<String> participantNames;
  final List<String> participantRoles;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final DateTime createdAt;

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

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: List<String>.from(data['participantNames'] ?? []),
      participantRoles: List<String>.from(data['participantRoles'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'participantRoles': participantRoles,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSenderId': lastMessageSenderId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
