import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import '../viewmodels/homeowner_chat_controller.dart';
import 'package:buildbuddy/controllers/chatControllers/homeowner_chat_controller.dart';

class HomeownerConversationScreen extends StatelessWidget {
  final String chatId;
  final HomeownerChatController chatController = Get.put(HomeownerChatController());
  final TextEditingController messageController = TextEditingController();

  HomeownerConversationScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    chatController.fetchMessages(chatId);

    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  var message = chatController.messages[index];
                  return ListTile(
                    title: Text(message.message),
                    subtitle: Text("From: ${message.senderId}"),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    chatController.sendMessage(
                      chatId,
                      "homeowner_1",
                      "contractor_1", // Change this dynamically
                      messageController.text,
                    );
                    messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
