import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controllers/chatControllers/architect_chat_controller.dart';


class ArchitectConversationScreen extends StatelessWidget {
  final String chatId;
  final ArchitectChatController chatController = Get.put(ArchitectChatController());
  final TextEditingController messageController = TextEditingController();

  ArchitectConversationScreen({required this.chatId});

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
          TextField(
            controller: messageController,
            decoration: InputDecoration(hintText: "Type a message"),
          ),
          ElevatedButton(
            onPressed: () {
              chatController.sendMessage(chatId, "architect", "homeowner", messageController.text);
              messageController.clear();
            },
            child: Text("Send"),
          ),
        ],
      ),
    );
  }
}