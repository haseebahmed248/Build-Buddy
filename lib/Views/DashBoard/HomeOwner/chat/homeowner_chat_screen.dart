import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'homeowner_conversation_screen.dart';

class HomeownerChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Homeowner Chat")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Chat with Contractor"),
            onTap: () {
              Get.to(() => HomeownerConversationScreen(chatId: "homeowner_contractor_chat"));
            },
          ),
          ListTile(
            title: Text("Chat with Architect"),
            onTap: () {
              Get.to(() => HomeownerConversationScreen(chatId: "homeowner_architect_chat"));
            },
          ),
        ],
      ),
    );
  }
}
