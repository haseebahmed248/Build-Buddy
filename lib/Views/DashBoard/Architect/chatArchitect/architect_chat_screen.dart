import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'architect_conversation_screen.dart';

class ArchitectChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Architect Chat")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Chat with Homeowner"),
            onTap: () {
              Get.to(() => ArchitectConversationScreen(chatId: "architect_homeowner_chat"));
            },
          ),
          ListTile(
            title: Text("Chat with Contractor"),
            onTap: () {
              Get.to(() => ArchitectConversationScreen(chatId: "architect_contractor_chat"));
            },
          ),
        ],
      ),
    );
  }
}