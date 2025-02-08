import 'package:firebase_database/firebase_database.dart';

class ChatMessage {
  final String senderId;
  final String message;
  final String timestamp;

  ChatMessage({
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  // Convert a JSON map from Firebase Realtime Database into a ChatMessage object
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  // Convert a ChatMessage object into a map to be saved to Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
