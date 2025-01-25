import 'package:flutter/material.dart';

class MessagesDashboard extends StatelessWidget {
  const MessagesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                color: const Color(0xFFFF9800).withOpacity(0.1),
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
                color: const Color(0xFFFF5722).withOpacity(0.1),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF9800),  // Orange
                        const Color(0xFFFF5722),  // Deep Orange
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
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
                          onPressed: () => Navigator.of(context).pop(),
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
                                  Icons.message_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Messages',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Your Conversations',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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

                // Messages List
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _dummyMessages.length,
                    itemBuilder: (context, index) {
                      final message = _dummyMessages[index];
                      return _MessageTile(
                        sender: message['sender']!,
                        message: message['message']!,
                        time: message['time']!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dummy messages data with more variety
  static final List<Map<String, String>> _dummyMessages = [
    {
      'sender': 'Alex Rodriguez',
      'message': 'Can we schedule a product demo?',
      'time': '3:45 PM'
    },
    {
      'sender': 'Emma Thompson',
      'message': 'Attached are the quarterly reports.',
      'time': '2:30 PM'
    },
    {
      'sender': 'Carlos Martinez',
      'message': 'Requesting feedback on the new design proposal.',
      'time': '1:15 PM'
    },
    {
      'sender': 'Sarah Kim',
      'message': 'Confirmed hotel bookings for the conference.',
      'time': '12:00 PM'
    },
    {
      'sender': 'Michael Chen',
      'message': 'Team lunch this Friday - venue suggestions?',
      'time': 'Yesterday'
    },
    {
      'sender': 'Lisa Wong',
      'message': 'Quick question about the marketing strategy.',
      'time': '11:30 AM'
    },
    {
      'sender': 'Robert Johnson',
      'message': 'Invoice for last month has been processed.',
      'time': '10:45 AM'
    },
  ];
}

class _MessageTile extends StatelessWidget {
  final String sender;
  final String message;
  final String time;

  const _MessageTile({
    required this.sender,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            color: const Color(0xFFFF9800).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.person_rounded,
            color: const Color(0xFFFF9800),
            size: 24,
          ),
        ),
        title: Text(
          sender,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFFFF5722),
          ),
        ),
        subtitle: Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}