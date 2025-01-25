import 'package:cloud_firestore/cloud_firestore.dart';

// chat_user_model.dart
class ChatUser {
  final String id;
  final String displayName;
  final String role;
  final String? photoURL;
  final String email;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.id,
    required this.displayName,
    required this.role,
    this.photoURL,
    required this.email,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ChatUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatUser(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? '',
      photoURL: data['photoURL'],
      email: data['email'] ?? '',
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'role': role,
      'photoURL': photoURL,
      'email': email,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }
}
