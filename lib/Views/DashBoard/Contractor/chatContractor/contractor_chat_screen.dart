import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'contractor_conversation_screen.dart';

class ContractorChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildChatItem(
            title: "Chat with Homeowner",
            subtitle: "Discuss project requirements and updates",
            icon: Icons.home_outlined,
            onTap: () {
              Get.to(() => ContractorConversationScreen(
                chatId: "contractor_homeowner_chat",
              ));
            },
          ),
          const SizedBox(height: 12),
          _buildChatItem(
            title: "Chat with Architect",
            subtitle: "Collaborate on design and specifications",
            icon: Icons.architecture,
            onTap: () {
              Get.to(() => ContractorConversationScreen(
                chatId: "contractor_architect_chat",
              ));
            },
          ),
          const SizedBox(height: 12),
          _buildChatItem(
            title: "Chat with Vendor",
            subtitle: "Discuss material supplies and orders",
            icon: Icons.store_outlined,
            onTap: () {
              Get.to(() => ContractorConversationScreen(
                chatId: "contractor_vendor_chat",
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2196F3),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: Color(0xFF2196F3),
        ),
        onTap: onTap,
      ),
    );
  }
}


