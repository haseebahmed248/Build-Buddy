import 'package:firebase_database/firebase_database.dart';

class ChatUser {
  final String uid;
  final String name;
  final String role;

  ChatUser({
    required this.uid,
    required this.name,
    required this.role,
  });

  // Convert a JSON map into a ChatUser object
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  // Convert a ChatUser object into a map to be saved to Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'role': role,
    };
  }
}
