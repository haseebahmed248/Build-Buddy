// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../Controllers/chat_controller.dart';
// import '../../../Models/chat_room_model.dart';
// import '../../../Models/chat_user_model.dart';

// class MessagesDashboard extends StatelessWidget {
//   final ChatController controller = Get.find<ChatController>();

//   MessagesDashboard({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F6FA),
//         body: Stack(
//           children: [
//             _buildBackgroundDecorations(),
//             SafeArea(
//               child: Column(
//                 children: [
//                   _buildCustomAppBar(),
//                   Expanded(
//                     child: _buildChatList(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: _buildFloatingActionButton(),
//       ),
//     );
//   }

//   Widget _buildBackgroundDecorations() {
//     return Stack(
//       children: [
//         Positioned(
//           top: -100,
//           right: -50,
//           child: Container(
//             width: 200,
//             height: 200,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: const Color(0xFFFF9800).withOpacity(0.1),
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: -80,
//           left: -60,
//           child: Container(
//             width: 200,
//             height: 200,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: const Color(0xFFFF5722).withOpacity(0.1),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCustomAppBar() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Get.back(),
//             ),
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

//   Widget _buildChatList() {
//     return Obx(() {
//       if (controller.isLoading) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       if (controller.error != null) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//               const SizedBox(height: 16),
//               Text(
//                 'Error: ${controller.error}',
//                 style: const TextStyle(color: Colors.red),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: controller.clearError,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF9800),
//                 ),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         );
//       }

//       if (controller.chatRooms.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
//               const SizedBox(height: 16),
//               Text(
//                 'No messages yet',
//                 style: TextStyle(color: Colors.grey[600], fontSize: 16),
//               ),
//               if (controller.currentUserRole != null)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Start a conversation with a ${_getAvailableUserTypes()}',
//                     style: TextStyle(color: Colors.grey[500], fontSize: 14),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//             ],
//           ),
//         );
//       }

//       return ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: controller.chatRooms.length,
//         itemBuilder: (context, index) {
//           return _buildChatTile(controller.chatRooms[index]);
//         },
//       );
//     });
//   }

//   String _getAvailableUserTypes() {
//     switch (controller.currentUserRole) {
//       case 'homeowner':
//         return 'Contractor, Architect, or Vendor';
//       case 'contractor':
//         return 'Homeowner or Vendor';
//       case 'architect':
//         return 'Homeowner or Contractor';
//       case 'vendor':
//         return 'Homeowner or Contractor';
//       default:
//         return 'professional';
//     }
//   }

//   Widget _buildChatTile(ChatRoom chatRoom) {
//     final otherParticipantName = controller.getOtherParticipantName(chatRoom);
//     final otherParticipantRole = controller.getOtherParticipantRole(chatRoom);

//     return Dismissible(
//       key: Key(chatRoom.id),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20.0),
//         color: Colors.red,
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       confirmDismiss: (direction) async {
//         return await Get.dialog<bool>(
//           AlertDialog(
//             title: const Text('Delete Conversation'),
//             content: const Text('Are you sure you want to delete this conversation?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(result: false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Get.back(result: true),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.red,
//                 ),
//                 child: const Text('Delete'),
//               ),
//             ],
//           ),
//         ) ?? false;
//       },
//       onDismissed: (direction) {
//         controller.deleteChat(chatRoom.id);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ListTile(
//           onTap: () => Get.toNamed(
//             '/chat/${chatRoom.id}',
//             arguments: {
//               'chatRoom': chatRoom,
//               'otherParticipantName': otherParticipantName,
//             },
//           ),
//           leading: Stack(
//             children: [
//               CircleAvatar(
//                 backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
//                 child: Text(
//                   otherParticipantName.isNotEmpty ? 
//                       otherParticipantName[0].toUpperCase() : '?',
//                   style: const TextStyle(
//                     color: Color(0xFFFF9800),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               if (chatRoom.unreadCount > 0)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFFF5722),
//                       shape: BoxShape.circle,
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 16,
//                       minHeight: 16,
//                     ),
//                     child: Text(
//                       chatRoom.unreadCount.toString(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           title: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   otherParticipantName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               Text(
//                 controller.formatTimestamp(chatRoom.lastMessageTime),
//                 style: TextStyle(
//                   color: Colors.grey[500],
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 otherParticipantRole.capitalizeFirst ?? '',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 chatRoom.lastMessage,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingActionButton() {
//     return Obx(() {
//       if (!_canInitiateChat()) return const SizedBox.shrink();

//       return FloatingActionButton(
//         onPressed: _showNewChatDialog,
//         backgroundColor: const Color(0xFFFF9800),
//         child: const Icon(Icons.message),
//       );
//     });
//   }

//   bool _canInitiateChat() {
//     final role = controller.currentUserRole;
//     return role == 'homeowner' || 
//            role == 'contractor' || 
//            role == 'architect';
//   }

//   void _showNewChatDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Start New Chat'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: _buildUserTypeSelection(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserTypeSelection() {
//     return Obx(() {
//       if (controller.isLoading) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       final options = _getUserTypeOptions();
      
//       return ListView.builder(
//         shrinkWrap: true,
//         itemCount: options.length,
//         itemBuilder: (context, index) {
//           final option = options[index];
//           return ListTile(
//             leading: CircleAvatar(
//               backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
//               child: Icon(
//                 option.icon,
//                 color: const Color(0xFFFF9800),
//               ),
//             ),
//             title: Text(option.title),
//             onTap: () {
//               Get.back();
//               _showUserListDialog(option.role);
//             },
//           );
//         },
//       );
//     });
//   }

//   List<UserTypeOption> _getUserTypeOptions() {
//     switch (controller.currentUserRole) {
//       case 'homeowner':
//         return [
//           UserTypeOption('Contractors', Icons.construction, 'contractor'),
//           UserTypeOption('Architects', Icons.architecture, 'architect'),
//           UserTypeOption('Vendors', Icons.store, 'vendor'),
//         ];
//       case 'contractor':
//         return [
//           UserTypeOption('Homeowners', Icons.home, 'homeowner'),
//           UserTypeOption('Vendors', Icons.store, 'vendor'),
//         ];
//       case 'architect':
//         return [
//           UserTypeOption('Homeowners', Icons.home, 'homeowner'),
//           UserTypeOption('Contractors', Icons.construction, 'contractor'),
//         ];
//       case 'vendor':
//         return [
//           UserTypeOption('Homeowners', Icons.home, 'homeowner'),
//           UserTypeOption('Contractors', Icons.construction, 'contractor'),
//         ];
//       default:
//         return [];
//     }
//   }

//   void _showUserListDialog(String userRole) {
//     Get.dialog(
//       AlertDialog(
//         title: Text('Select ${userRole.capitalizeFirst}'),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 300,
//           child: FutureBuilder<List<ChatUser>>(
//             future: controller.getUsersByRole(userRole),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return Center(
//                   child: Text(
//                     'Error: ${snapshot.error}',
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 );
//               }

//               final users = snapshot.data ?? [];
//               if (users.isEmpty) {
//                 return Center(
//                   child: Text(
//                     'No ${userRole}s found',
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 );
//               }

//               return ListView.builder(
//                 itemCount: users.length,
//                 itemBuilder: (context, index) {
//                   final user = users[index];
//                   return ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
//                       child: Text(
//                         user.displayName[0].toUpperCase(),
//                         style: const TextStyle(
//                           color: Color(0xFFFF9800),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     title: Text(user.displayName),
//                     subtitle: Text(user.email),
//                     onTap: () async {
//                       Get.back();
//                       final chatId = await controller.createNewChat(user.id);
//                       if (chatId != null) {
//                         Get.toNamed('/chat/$chatId');
//                       } else {
//                         Get.snackbar(
//                           'Error',
//                           'Failed to create chat',
//                           snackPosition: SnackPosition.BOTTOM,
//                           backgroundColor: Colors.red,
//                           colorText: Colors.white,
//                         );
//                       }
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class UserTypeOption {
//   final String title;
//   final IconData icon;
//   final String role;

//   UserTypeOption(this.title, this.icon, this.role);
// }

// // Extension to add unread count property to ChatRoom
// extension ChatRoomExtension on ChatRoom {
//   int get unreadCount {
//     return 0; // Implement this based on your chat message tracking logic
//   }
// }

// // Helper widgets
// class LoadingIndicator extends StatelessWidget {
//   const LoadingIndicator({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: CircularProgressIndicator(
//         valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
//       ),
//     );
//   }
// }

// class ErrorDisplay extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;

//   const ErrorDisplay({
//     Key? key,
//     required this.message,
//     required this.onRetry,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: const TextStyle(color: Colors.red),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: onRetry,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFF9800),
//             ),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class EmptyStateDisplay extends StatelessWidget {
//   final String message;
//   final String submessage;

//   const EmptyStateDisplay({
//     Key? key,
//     required this.message,
//     required this.submessage,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(color: Colors.grey[600], fontSize: 16),
//           ),
//           if (submessage.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 submessage,
//                 style: TextStyle(color: Colors.grey[500], fontSize: 14),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // Extension for date formatting
// extension DateFormatting on DateTime {
//   String toMessageTime() {
//     final now = DateTime.now();
//     final difference = now.difference(this);

//     if (difference.inDays == 0) {
//       return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year}';
//     }
//   }
// }