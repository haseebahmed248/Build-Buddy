import 'package:cloud_firestore/cloud_firestore.dart';

class ContractorChatModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String timestamp;

  ContractorChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory ContractorChatModel.fromJson(Map<String, dynamic> json) {
    return ContractorChatModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }

  factory ContractorChatModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return ContractorChatModel(
      id: snapshot.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? '',
    );
  }

  ContractorChatModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    String? timestamp,
  }) {
    return ContractorChatModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ContractorChatModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              senderId == other.senderId &&
              receiverId == other.receiverId &&
              message == other.message &&
              timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      senderId.hashCode ^
      receiverId.hashCode ^
      message.hashCode ^
      timestamp.hashCode;
}