// chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Models/chat_message_model.dart';
import '../../Models/chat_room_model.dart';
import '../../Models/chat_user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's role
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final roles = ['homeowner', 'contractor', 'vendor', 'architect', 'admin'];
      for (String role in roles) {
        final doc = await _firestore
            .collection('user')
            .doc(role)
            .collection(user.uid)
            .doc('profile')
            .get();

        if (doc.exists) {
          return role;
        }
      }
    }
    return null;
  }

  // Get all chat rooms for current user
  Stream<List<ChatRoom>> getChatRooms() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }

  // Get messages for a specific chat room
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // Send a message
  Future<void> sendMessage(String chatId, String message) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _getUserDoc(user.uid);
    if (!userDoc.exists) return;

    final userData = userDoc.data() as Map<String, dynamic>;
    final chatMessage = ChatMessage(
      id: '', // Firestore will generate this
      senderId: user.uid,
      senderName: userData['displayName'] ?? 'Unknown',
      message: message,
      timestamp: DateTime.now(),
    );

    final messageRef = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(chatMessage.toMap());

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': Timestamp.now(),
      'lastMessageSenderId': user.uid,
    });
  }

  // Create a new chat room
  Future<String> createChatRoom(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No authenticated user');

    final currentUserDoc = await _getUserDoc(currentUser.uid);
    final otherUserDoc = await _getUserDoc(otherUserId);

    if (!currentUserDoc.exists || !otherUserDoc.exists) {
      throw Exception('One or more users not found');
    }

    final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
    final otherUserData = otherUserDoc.data() as Map<String, dynamic>;

    final chatRoom = ChatRoom(
      id: '', // Firestore will generate this
      participants: [currentUser.uid, otherUserId],
      participantNames: [
        currentUserData['displayName'] ?? 'Unknown',
        otherUserData['displayName'] ?? 'Unknown'
      ],
      participantRoles: [
        currentUserData['role'] ?? 'unknown',
        otherUserData['role'] ?? 'unknown'
      ],
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      lastMessageSenderId: '',
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore.collection('chats').add(chatRoom.toMap());
    return docRef.id;
  }

  // Get user data
  Future<ChatUser?> getUserData(String userId) async {
    final doc = await _getUserDoc(userId);
    if (!doc.exists) return null;
    return ChatUser.fromFirestore(doc);
  }

  // Helper method to get user document
  Future<DocumentSnapshot> _getUserDoc(String userId) async {
    final roles = ['homeowner', 'contractor', 'vendor', 'architect', 'admin'];
    for (String role in roles) {
      final doc = await _firestore
          .collection('user')
          .doc(role)
          .collection(userId)
          .doc('profile')
          .get();

      if (doc.exists) return doc;
    }
    throw Exception('User not found');
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
