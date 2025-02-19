import 'package:firebase_database/firebase_database.dart';
import 'package:buildbuddy/models/chatModels/contractor_chat_model.dart';

class ContractorChatService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("contractor_messages");

  Future<void> sendMessage(String chatId, String senderId, String receiverId, String message) async {
    await _dbRef.child(chatId).push().set({
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  Stream<List<ContractorChatModel>> getMessages(String chatId) {
    return _dbRef.child(chatId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) => ContractorChatModel.fromJson(Map<String, dynamic>.from(entry.value))).toList();
    });
  }
}



/*
import 'package:firebase_database/firebase_database.dart';
import '../models/homeowner_chat_model.dart';

class HomeownerChatService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("homeowner_messages");

  Future<void> sendMessage(String chatId, String senderId, String receiverId, String message) async {
    await _dbRef.child(chatId).push().set({
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  Stream<List<HomeownerChatModel>> getMessages(String chatId) {
    return _dbRef.child(chatId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) => HomeownerChatModel.fromJson(Map<String, dynamic>.from(entry.value))).toList();
    });
  }
}
*/
