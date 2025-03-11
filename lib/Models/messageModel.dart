import 'package:firebase_database/firebase_database.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final String type; // e.g., 'homeowner_contractor'

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'receiverId': receiverId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
  };

  factory Message.fromMap(Map<String, dynamic> map, {required String id}) {
    return Message(
      id: id, // Use the id passed as a named parameter
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      type: map['type'] as String,
    );
  }
}