import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controllers/chatControllers/contractor_chat_controller.dart';


class ContractorConversationScreen extends StatelessWidget {
  final String chatId;
  final ContractorChatController chatController = Get.put(ContractorChatController());
  final TextEditingController messageController = TextEditingController();

  ContractorConversationScreen({required this.chatId});

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
                      "contractor_1",
                      "homeowner_1", // Change this dynamically
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
