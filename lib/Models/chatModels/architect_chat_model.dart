class ArchitectChatModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String timestamp;

  ArchitectChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory ArchitectChatModel.fromJson(Map<String, dynamic> json) {
    return ArchitectChatModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
