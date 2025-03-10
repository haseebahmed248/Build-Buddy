import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Core/Theme/theme.dart';
import 'package:buildbuddy/Models/userModels.dart'; // Assuming UserRole is defined here
import 'package:url_launcher/url_launcher.dart'; // For launching email and phone
import '../../../Views/Shared/widgets/gemini_service.dart'; // Assuming this is the same GeminiService

class HelpAndSupportScreen extends StatefulWidget {
  final UserRole stakeholderRole;

  const HelpAndSupportScreen({Key? key, required this.stakeholderRole}) : super(key: key);

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  bool _isChatOpen = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final _geminiService = GeminiService();

  // Map of stakeholder-specific FAQs
  Map<UserRole, List<Map<String, String>>> getFaqs() {
    return {
      UserRole.homeowner: [
        {'title': 'How to create a project?', 'subtitle': 'Go to the "My Projects" section and click "Create New Project".'},
        {'title': 'How to contact support?', 'subtitle': 'Email us at homeowner.support@buildbuddy.com or call 0312-7574084.'},
      ],
      UserRole.contractor: [
        {'title': 'How to place a material order?', 'subtitle': 'Navigate to "Material Orders" and select the materials you need.'},
        {'title': 'How to contact support?', 'subtitle': 'Email us at contractor.support@buildbuddy.com or call 0312-7574084.'},
      ],
      UserRole.architect: [
        {'title': 'How to submit a design?', 'subtitle': 'Upload your design files in the "Design Submissions" section.'},
        {'title': 'How to contact support?', 'subtitle': 'Email us at architect.support@buildbuddy.com or call 0312-7574084.'},
      ],
      UserRole.vendor: [
        {'title': 'How to update material prices?', 'subtitle': 'Go to your vendor dashboard and edit the material catalog.'},
        {'title': 'How to contact support?', 'subtitle': 'Email us at vendor.support@buildbuddy.com or call 0312-7574084.'},
      ],
    };
  }

  // Stakeholder-specific greeting
  String getGreeting() {
    switch (widget.stakeholderRole) {
      case UserRole.homeowner:
        return 'Welcome Homeowner!';
      case UserRole.contractor:
        return 'Welcome Contractor!';
      case UserRole.architect:
        return 'Welcome Architect!';
      case UserRole.vendor:
        return 'Welcome Vendor!';
      default:
        return 'Welcome!';
    }
  }

  // Stakeholder-specific email
  String getSupportEmail() {
    switch (widget.stakeholderRole) {
      case UserRole.homeowner:
        return 'homeowner.support@buildbuddy.com';
      case UserRole.contractor:
        return 'contractor.support@buildbuddy.com';
      case UserRole.architect:
        return 'architect.support@buildbuddy.com';
      case UserRole.vendor:
        return 'vendor.support@buildbuddy.com';
      default:
        return 'support@buildbuddy.com';
    }
  }

  // Stakeholder-specific phone number (can be customized further)
  String getSupportPhone() {
    return '0312-7574084'; // Keeping the same phone number for now
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
      ));
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await _geminiService.generateResponse(message);
      setState(() {
        _messages.add(ChatMessage(
          text: response ?? 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Launch email client
  Future<void> _launchEmail(String email) async {
    final url = 'mailto:$email?subject=Support%20Request&body=Hello,%20I%20need%20assistance%20with...';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar('Error', 'Could not launch email client.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  // Launch phone dialer
  Future<void> _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar('Error', 'Could not launch phone dialer.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final faqs = getFaqs()[widget.stakeholderRole] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // Background Decorative Circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4834DF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E3799).withOpacity(0.1),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom AppBar
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E3799),
                        Color(0xFF4834DF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.support_agent_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getGreeting(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'We\'re here to help',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Live Chat Section
                              _buildSectionHeader('Live Chat Support'),
                              _buildContactCard(
                                title: 'Start Live Chat',
                                subtitle: 'Chat with our AI assistant for immediate help',
                                icon: Icons.chat_bubble_rounded,
                                onTap: () {
                                  setState(() {
                                    _isChatOpen = true;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              // FAQs Section
                              _buildSectionHeader('FAQs'),
                              ...faqs.map((faq) => _buildFAQCard(
                                title: faq['title']!,
                                subtitle: faq['subtitle']!,
                                icon: Icons.create_new_folder_rounded,
                              )).toList(),

                              const SizedBox(height: 16),

                              // Contact Us Section
                              _buildSectionHeader('Contact Us'),
                              _buildContactCard(
                                title: 'Email',
                                subtitle: getSupportEmail(),
                                icon: Icons.email_rounded,
                                onTap: () => _launchEmail(getSupportEmail()),
                              ),
                              _buildContactCard(
                                title: 'Phone',
                                subtitle: getSupportPhone(),
                                icon: Icons.phone_rounded,
                                onTap: () => _launchPhone(getSupportPhone()),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Chat Support Overlay
                      if (_isChatOpen)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.all(16),
                                height: MediaQuery.of(context).size.height * 0.7,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    // Chat Header
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1E3799),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.support_agent,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'AI Support Assistant',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isChatOpen = false;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Chat Messages
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: ListView.builder(
                                          controller: _scrollController,
                                          itemCount: _messages.length,
                                          itemBuilder: (context, index) {
                                            final message = _messages[index];
                                            return _buildMessageBubble(message);
                                          },
                                        ),
                                      ),
                                    ),
                                    if (_isLoading)
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    // Chat Input
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _messageController,
                                              decoration: InputDecoration(
                                                hintText: 'Type your message...',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(24),
                                                  borderSide: BorderSide.none,
                                                ),
                                                filled: true,
                                                fillColor: Colors.grey[100],
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                              ),
                                              onSubmitted: _sendMessage,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.send, color: Color(0xFF1E3799)),
                                            onPressed: () => _sendMessage(_messageController.text),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for building UI components
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3799),
        ),
      ),
    );
  }

  Widget _buildFAQCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4834DF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4834DF),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E3799),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4834DF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4834DF),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E3799),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF1E3799),
              radius: 16,
              child: Icon(Icons.support_agent, color: Colors.white, size: 16),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF1E3799) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF1E3799),
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}