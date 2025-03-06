import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Models/orderModel.dart';
import 'package:buildbuddy/Models/messageModel.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'dart:async';

/// Manages vendor-specific functionality, including managing orders from Contractors,
/// messages with Contractors, and ensuring role-based access. Aligns with SRS 3.1.3 (Vendor Functionality),
/// 3.2.1 (Performance), 3.2.2 (Usability), 3.2.3 (Security), and 3.2.4 (Reliability).
class VendorController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController; // Reference to AuthController for user data

  List<Order> _orders = []; // Orders received from Contractors
  List<Message> _contractorMessages = []; // Messages with Contractors
  bool _isLoading = false;
  String? _errorMessage;

  /// Getters for vendor-managed data, ensuring real-time updates and usability (SRS 3.2.2).
  List<Order> get orders => _orders;
  List<Message> get contractorMessages => _contractorMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userType => 'vendor'; // Added for consistency

  StreamSubscription? _ordersSubscription;
  StreamSubscription? _contractorMessagesSubscription;

  /// Constructor initializes with AuthController for integrated functionality.
  VendorController(this._authController) {
    _checkVendorStatus();
    _authController.addListener(_onAuthStateChanged); // Listen to AuthController changes
  }

  /// Handles authentication state changes to update vendor status and listeners.
  void _onAuthStateChanged() {
    _checkVendorStatus();
  }

  /// Checks if the current user is a vendor, starting or stopping real-time listeners accordingly.
  /// Ensures security and role-based access (SRS 3.2.3).
  void _checkVendorStatus() {
    if (_authController.currentUser.value?.role == UserRole.vendor) {
      _startRealTimeListeners();
    } else {
      _stopRealTimeListeners();
      _errorMessage = 'User is not a vendor';
      notifyListeners();
    }
  }

  /// Starts real-time listeners for orders and messages, ensuring performance (SRS 3.2.1)
  /// and real-time updates (SRS 3.2.2).
  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    // Real-time listener for orders (received by Vendor)
    _ordersSubscription = _database.child('orders').orderByChild('vendorId').equalTo(user.uid).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _orders = data.entries.map((entry) {
            final map = Map<String, dynamic>.from(entry.value as Map);
            final id = entry.key as String; // Ensure id is a String
            return Order.fromMap(map,id: ''); // Pass map and id as separate arguments
          }).toList();
          notifyListeners();
        }
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load orders: $error';
      notifyListeners();
    });

    // Real-time listener for messages with Contractors
    _contractorMessagesSubscription = _database.child('messages/contractor_vendor').orderByChild('receiverId').equalTo(user.uid).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _contractorMessages = data.entries.map((entry) {
            final map = Map<String, dynamic>.from(entry.value as Map);
            final id = entry.key as String; // Ensure id is a String
            return Message.fromMap(map, id: ''); // Pass map and id as separate arguments
          }).toList();
          notifyListeners();
        }
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load contractor messages: $error';
      notifyListeners();
    });
  }

  /// Stops real-time listeners, ensuring resource cleanup and reliability (SRS 3.2.4).
  void _stopRealTimeListeners() {
    _ordersSubscription?.cancel();
    _contractorMessagesSubscription?.cancel();
    _orders.clear();
    _contractorMessages.clear();
    notifyListeners();
  }

  /// Checks if the current user is a vendor, ensuring security (SRS 3.2.3).
  bool get isVendor => _authController.currentUser.value?.role == UserRole.vendor ?? false;

  /// Updates the status of an order (e.g., from 'pending' to 'shipped'), ensuring usability
  /// and reliability (SRS 3.2.2, 3.2.4).
  Future<void> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!isVendor) {
        _errorMessage = 'Only vendors can update orders';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _database.child('orders').child(orderId).update({'status': status});
    } catch (e) {
      print('Error updating order status: $e');
      _errorMessage = 'Failed to update order status: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends a message to a Contractor, ensuring usability and reliability (SRS 3.2.2, 3.2.4).
  Future<void> sendMessageToContractor(String contractorId, String content) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!isVendor) {
        _errorMessage = 'Only vendors can send messages to contractors';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final message = Message(
        id: '', // Will be generated by Firebase
        senderId: user.uid,
        receiverId: contractorId,
        content: content,
        timestamp: DateTime.now(),
        type: 'contractor_vendor',
      );

      final messageRef = _database.child('messages/contractor_vendor').push();
      await messageRef.set(message.toJson());
    } catch (e) {
      print('Error sending message to contractor: $e');
      _errorMessage = 'Failed to send message to contractor: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cleans up resources, ensuring reliability (SRS 3.2.4).
  @override
  void dispose() {
    _stopRealTimeListeners();
    _authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}