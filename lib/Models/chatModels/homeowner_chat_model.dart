class HomeownerChatModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String timestamp;

  HomeownerChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory HomeownerChatModel.fromJson(Map<String, dynamic> json) {
    return HomeownerChatModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
