import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Controllers/chatController.dart';
import 'package:buildbuddy/Models/orderModel.dart';
import 'package:buildbuddy/Models/messageModel.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'dart:async';

/// Manages contractor-specific functionality, including material orders, messages with Vendors/Homeowners,
/// and chat interactions. Aligns with SRS 3.1.2 (Contractor Functionality), 3.2.1 (Performance),
/// 3.2.2 (Usability), 3.2.3 (Security), and 3.2.4 (Reliability).
class ContractorController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController; // Reference to AuthController for user data
  final ChatController _chatController; // Reference to ChatController for chat access

  List<Order> _orders = [];
  List<Message> _vendorMessages = []; // Messages with Vendors (legacy, can be removed if using ChatController)
  List<Message> _homeownerMessages = []; // Messages with Homeowners (legacy, can be removed if using ChatController)
  bool _isLoading = false;
  String? _errorMessage;

  /// Getters for contractor-managed data, ensuring real-time updates and usability (SRS 3.2.2).
  List<Order> get orders => _orders;
  List<Message> get vendorMessages => _vendorMessages;
  List<Message> get homeownerMessages => _homeownerMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userType => 'contractor'; // Added for consistency

  StreamSubscription? _ordersSubscription;
  StreamSubscription? _vendorMessagesSubscription;
  StreamSubscription? _homeownerMessagesSubscription;

  /// Constructor initializes with AuthController and ChatController for integrated functionality.
  ContractorController(this._authController)
      : _chatController = ChatController() { // Remove the _authController parameter
    _checkContractorStatus();
    _authController.addListener(_onAuthStateChanged); // Listen to AuthController changes
  }

  /// Handles authentication state changes to update contractor status and listeners.
  void _onAuthStateChanged() {
    _checkContractorStatus();
  }

  /// Checks if the current user is a contractor, starting or stopping real-time listeners accordingly.
  /// Ensures security and role-based access (SRS 3.2.3).
  void _checkContractorStatus() {
    if (_authController.currentUser.value?.role == UserRole.contractor) {
      _startRealTimeListeners();
    } else {
      _stopRealTimeListeners();
      _errorMessage = 'User is not a contractor';
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

    // Real-time listener for orders (placed by Contractor)
    _ordersSubscription = _database.child('orders').orderByChild('contractorId').equalTo(user.uid).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _orders = data.entries.map((entry) {
            final map = Map<String, dynamic>.from(entry.value as Map);
            final id = entry.key as String; // Ensure id is a String
            return Order.fromMap(map, id: id); // Pass id as a named parameter
          }).toList();
          notifyListeners();
        }
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load orders: $error';
      notifyListeners();
    });

    // Real-time listener for messages with Vendors (legacy, can be removed)
    _vendorMessagesSubscription = _database.child('messages/contractor_vendor').orderByChild('contractorId').equalTo(user.uid).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _vendorMessages = data.entries.map((entry) {
            final map = Map<String, dynamic>.from(entry.value as Map);
            final id = entry.key as String; // Ensure id is a String
            return Message.fromMap(map, id: id); // Pass id as a named parameter
          }).toList();
          notifyListeners();
        }
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load vendor messages: $error';
      notifyListeners();
    });

    // Real-time listener for messages with Homeowners (legacy, can be removed)
    _homeownerMessagesSubscription = _database.child('messages/contractor_homeowner').orderByChild('contractorId').equalTo(user.uid).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _homeownerMessages = data.entries.map((entry) {
            final map = Map<String, dynamic>.from(entry.value as Map);
            final id = entry.key as String; // Ensure id is a String
            return Message.fromMap(map, id: id); // Pass id as a named parameter
          }).toList();
          notifyListeners();
        }
      }
    }, onError: (error) {
      _errorMessage = 'Failed to load homeowner messages: $error';
      notifyListeners();
    });
  }

  /// Stops real-time listeners, ensuring resource cleanup and reliability (SRS 3.2.4).
  void _stopRealTimeListeners() {
    _ordersSubscription?.cancel();
    _vendorMessagesSubscription?.cancel();
    _homeownerMessagesSubscription?.cancel();
    _orders.clear();
    _vendorMessages.clear();
    _homeownerMessages.clear();
    notifyListeners();
  }

  /// Checks if the current user is a contractor, ensuring security (SRS 3.2.3).
  bool get isContractor => _authController.currentUser.value?.role == UserRole.contractor ?? false;

  /// Places a material order with a Vendor, ensuring usability and reliability (SRS 3.2.2, 3.2.4).
  Future<void> placeOrder(String vendorId, String material, int quantity, double price) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!isContractor) {
        _errorMessage = 'Only contractors can place orders';
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

      final order = Order(
        id: '', // Will be generated by Firebase
        contractorId: user.uid,
        vendorId: vendorId,
        material: material,
        quantity: quantity,
        price: price,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final orderRef = _database.child('orders').push();
      await orderRef.set(order.toJson());
    } catch (e) {
      print('Error placing order: $e');
      _errorMessage = 'Failed to place order: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Provides access to chat functionality for contractors, ensuring usability (SRS 3.2.2)
  /// and integration with the chat system across stakeholders.
  ChatController get chat => _chatController;

  /// Cleans up resources, ensuring reliability (SRS 3.2.4).
  @override
  void dispose() {
    _stopRealTimeListeners();
    _authController.removeListener(_onAuthStateChanged);
    _chatController.dispose(); // Clean up ChatController
    super.dispose();
  }
}