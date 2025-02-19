// import 'package:buildbuddy/Services/chat/chat_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';

// final TextEditingController _searchController = TextEditingController();
// String _searchQuery = '';

// class MessagesDashboard extends StatefulWidget {
//   const MessagesDashboard({Key? key}) : super(key: key);

//   @override
//   _MessagesDashboardState createState() => _MessagesDashboardState();
// }

// class _MessagesDashboardState extends State<MessagesDashboard> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String? currentUserRole;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUserRole();
//   }

//   Future<void> _getCurrentUserRole() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       // Check all possible role collections
//       final roles = ['homeowner', 'contractor', 'vendor', 'architect', 'admin'];
//       for (String role in roles) {
//         // Correctly accessing nested collections in Firebase
//         final doc = await _firestore
//             .collection('user')
//             .doc(role)
//             .collection(user.uid)
//             .doc('profile')
//             .get();

//         if (doc.exists) {
//           setState(() {
//             currentUserRole = role;
//           });
//           break;
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       body: Stack(
//         children: [
//           // Background Decorative Circles
//           Positioned(
//             top: -100,
//             right: -50,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFFFF9800).withOpacity(0.1),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -80,
//             left: -60,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFFFF5722).withOpacity(0.1),
//               ),
//             ),
//           ),

//           // Main Content
//           SafeArea(
//             child: Column(
//               children: [
//                 // Custom AppBar
//                 buildCustomAppBar(),
//                 // Chat List
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search conversations...',
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value.toLowerCase();
//                       });
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: _getChatStream(),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.message_outlined,
//                                   size: 64, color: Colors.grey[400]),
//                               const SizedBox(height: 16),
//                               Text('No messages yet',
//                                   style: TextStyle(
//                                       color: Colors.grey[600], fontSize: 16)),
//                             ],
//                           ),
//                         );
//                       }

//                       return ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: snapshot.data!.docs.length,
//                         itemBuilder: (context, index) {
//                           final chatDoc = snapshot.data!.docs[index];
//                           return buildChatTile(chatDoc);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showNewChatDialog(),
//         backgroundColor: const Color(0xFFFF9800),
//         child: const Icon(Icons.message),
//       ),
//     );
//   }

//   Widget buildCustomAppBar() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.message_rounded,
//                 color: Colors.white,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 16),
//             const Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Messages',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'Your Conversations',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildChatTile(DocumentSnapshot chatDoc) {
//     final data = chatDoc.data() as Map<String, dynamic>;
//     final currentUserId = _auth.currentUser?.uid;
//     final participants = List<String>.from(data['participants'] ?? []);
//     final otherUserId = participants.firstWhere(
//       (id) => id != currentUserId,
//       orElse: () => '',
//     );

//     return FutureBuilder<DocumentSnapshot>(
//       future: _getUserData(otherUserId),
//       builder: (context, snapshot) {
//         final otherUserName = snapshot.data?.get('displayName') ?? 'Loading...';
//         final lastMessage = data['lastMessage'] ?? '';
//         final lastMessageTime = data['lastMessageTime'] as Timestamp?;

//         return Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ListTile(
//             onTap: () => Get.toNamed('/chat/${chatDoc.id}', arguments: {
//               'otherUserId': otherUserId,
//               'otherUserName': otherUserName,
//             }),
//             leading: CircleAvatar(
//               backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
//               child: Text(
//                 otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
//                 style: const TextStyle(
//                   color: Color(0xFFFF9800),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             title: Text(
//               otherUserName,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             subtitle: Text(
//               lastMessage,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//             trailing: Text(
//               _formatTimestamp(lastMessageTime),
//               style: TextStyle(
//                 color: Colors.grey[500],
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) return '';

//     final now = DateTime.now();
//     final date = timestamp.toDate();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }

//   Future<DocumentSnapshot> _getUserData(String userId) {
//     return _firestore.collection('users').doc(userId).get();
//   }

//   Stream<QuerySnapshot> _getChatStream() {
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId == null) return const Stream.empty();

//     return _firestore
//         .collection('chats')
//         .where('participants', arrayContains: currentUserId)
//         .orderBy('lastMessageTime', descending: true)
//         .snapshots();
//   }

//   // Update _showNewChatDialog in your MessagesDashboard
//   void _showNewChatDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Container(
//           width: double.maxFinite,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AppBar(
//                 title: Text('Start New Chat'),
//                 automaticallyImplyLeading: false,
//                 actions: [
//                   IconButton(
//                     icon: Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               Expanded(
//                 child: DefaultTabController(
//                   length: 3,
//                   child: Column(
//                     children: [
//                       TabBar(
//                         tabs: [
//                           Tab(text: 'Contractors'),
//                           Tab(text: 'Vendors'),
//                           Tab(text: 'Architects'),
//                         ],
//                       ),
//                       Expanded(
//                         child: TabBarView(
//                           children: [
//                             _buildUserList('contractor'),
//                             _buildUserList('vendor'),
//                             _buildUserList('architect'),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserList(String role) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('user')
//           .doc(role)
//           .collection('profiles')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         final users = snapshot.data!.docs;
//         if (users.isEmpty) {
//           return Center(
//             child: Text('No ${role}s available'),
//           );
//         }

//         return ListView.builder(
//           itemCount: users.length,
//           itemBuilder: (context, index) {
//             final userData = users[index].data() as Map<String, dynamic>;
//             final userId = users[index].id;

//             return ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: userData['photoURL'] != null
//                     ? NetworkImage(userData['photoURL'])
//                     : null,
//                 child: userData['photoURL'] == null
//                     ? Text(userData['displayName']?[0] ?? '?')
//                     : null,
//               ),
//               title: Text(userData['displayName'] ?? 'Unknown'),
//               subtitle: Text('USER'),
//               onTap: () => _startChat(userId, userData),
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _startChat(
//       String otherUserId, Map<String, dynamic> userData) async {
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId == null) return;

//     // Check if chat exists
//     final existingChats = await _firestore
//         .collection('chats')
//         .where('participants', arrayContains: currentUserId)
//         .get();

//     String? existingChatId;
//     for (var doc in existingChats.docs) {
//       final participants = List<String>.from(doc['participants']);
//       if (participants.contains(otherUserId)) {
//         existingChatId = doc.id;
//         break;
//       }
//     }

//     if (existingChatId != null) {
//       Navigator.pop(context);
//       Get.to(() => ChatScreen(
//             chatId: existingChatId!,
//             otherUserId: otherUserId,
//             otherUserName: userData['displayName'] ?? 'Unknown',
//           ));
//       return;
//     }

//     // Create new chat
//     final chatRef = await _firestore.collection('chats').add({
//       'participants': [currentUserId, otherUserId],
//       'createdAt': FieldValue.serverTimestamp(),
//       'lastMessage': '',
//       'lastMessageTime': FieldValue.serverTimestamp(),
//     });

//     // Create chat members
//     await Future.wait([
//       _firestore.collection('chat_members').add({
//         'chatId': chatRef.id,
//         'userId': currentUserId,
//         'unreadCount': 0,
//         'joinedAt': FieldValue.serverTimestamp(),
//       }),
//       _firestore.collection('chat_members').add({
//         'chatId': chatRef.id,
//         'userId': otherUserId,
//         'unreadCount': 0,
//         'joinedAt': FieldValue.serverTimestamp(),
//       }),
//     ]);

//     Navigator.pop(context);
//     Get.to(() => ChatScreen(
//           chatId: chatRef.id,
//           otherUserId: otherUserId,
//           otherUserName: userData['displayName'] ?? 'Unknown',
//         ));
//   }
// }

/*import 'package:flutter/material.dart';

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
                _buildCustomAppBar(),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search conversations...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                // Chat List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildChatTile(
                        context: context,
                        name: 'John Contractor',
                        lastMessage: 'Can we discuss the project details?',
                        time: '10:30',
                      ),
                      const SizedBox(height: 8),
                      _buildChatTile(
                        context: context,
                        name: 'Sarah Architect',
                        lastMessage: 'I\'ve uploaded the new blueprints.',
                        time: 'Yesterday',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF9800),
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
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
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your Conversations',
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
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String name,
    required String lastMessage,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(userName: name),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFFF9800),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
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

class ChatScreen extends StatefulWidget {
  final String userName;

  const ChatScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hi there! Can we discuss the project details?',
      isMe: false,
      sender: 'John Contractor',
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: _messageController.text.trim(),
          isMe: true,
          sender: 'You',
        ));

        _messageController.clear();
      });

      // Add a delay of 5 seconds before adding the dummy response
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Sounds good, let\'s schedule a meeting soon.',
            isMe: false,
            sender: widget.userName,
          ));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
            ),
          ),
        ),
        title: Text(widget.userName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isMe
              ? const Color(0xFFFF9800).withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isMe ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String sender;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.sender,
  });
}*/
/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Models/chatModel.dart';
import 'package:buildbuddy/Services/chat/chatService.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId; // ID of the other user in chat
  final String receiverName; // Name of the receiver

  const ChatScreen({super.key, required this.receiverId, required this.receiverName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late String senderId; // ID of the logged-in user
  late String userRole; // Role of the logged-in user

  @override
  void initState() {
    super.initState();
    _initializeUser(); // Fetch current user info
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      senderId = user.uid;
      userRole = await ChatService().getUserRoleFromFirebase() ?? 'Unknown';
      setState(() {}); // Refresh UI after fetching role
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    ChatMessage message = ChatMessage(
      senderId: senderId,
      receiverId: widget.receiverId,
      message: _messageController.text.trim(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await ChatService().sendMessage(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.receiverName}")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: ChatService().getMessages(senderId, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isMe = message.senderId == senderId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(message.message, style: const TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Field
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

