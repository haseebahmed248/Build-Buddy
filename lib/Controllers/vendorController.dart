import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Models/orderModel.dart';
import 'package:buildbuddy/Models/messageModel.dart';

import '../Models/userModels.dart';

class VendorController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController;

  List<Order> _orders = [];
  List<Message> _messages = [];
  Map<String, dynamic> _vendorData = {};
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  List<Message> get messages => _messages;
  Map<String, dynamic> get vendorData => _vendorData;
  List<Map<String, dynamic>> get invoices => _invoices;
  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _auth.currentUser?.uid;

  StreamSubscription<DatabaseEvent>? _ordersSubscription;
  StreamSubscription<DatabaseEvent>? _messagesSubscription;
  StreamSubscription<DatabaseEvent>? _vendorDataSubscription;
  StreamSubscription<DatabaseEvent>? _invoicesSubscription;
  StreamSubscription<DatabaseEvent>? _notificationsSubscription;
  StreamSubscription<DatabaseEvent>? _tasksSubscription;

  VendorController(this._authController) {
    _checkVendorStatus();
    _authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() => _checkVendorStatus();

  void _checkVendorStatus() {
    if (_authController.currentUser.value?.role == UserRole.vendor) {
      _startRealTimeListeners();
    } else {
      _stopRealTimeListeners();
      _errorMessage = 'User is not a vendor';
      notifyListeners();
    }
  }

/*  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    // Vendor Data Listener
    _vendorDataSubscription = _database.child('vendors/${user.uid}').onValue.listen(
          (event) {
        if (event.snapshot.exists) {
          _vendorData = Map<String, dynamic>.from(event.snapshot.value as Map);
          notifyListeners();
        } else {
          _vendorData = {};
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Failed to fetch vendor data: $error';
        notifyListeners();
      },
    );

    // Orders Listener
    _ordersSubscription = _database.child('vendors/${user.uid}/orders').onValue.listen(
          (event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _orders = data.entries.map((e) => Order.fromMap(Map<String, dynamic>.from(e.value as Map), id: e.key as String)).toList();
            notifyListeners();
          } else {
            _orders = [];
            notifyListeners();
          }
        } else {
          _orders = [];
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Failed to fetch orders: $error';
        notifyListeners();
      },
    );

    // Messages Listener
    _messagesSubscription = _database
        .child('messages/contractor_vendor')
        .orderByChild('receiverId')
        .equalTo(user.uid)
        .onValue
        .listen(
          (event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _messages = data.entries.map((e) => Message.fromMap(Map<String, dynamic>.from(e.value as Map), id: e.key as String)).toList();
            notifyListeners();
          } else {
            _messages = [];
            notifyListeners();
          }
        } else {
          _messages = [];
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Failed to fetch messages: $error';
        notifyListeners();
      },
    );

    // Invoices Listener
    _invoicesSubscription = _database.child('invoices/${user.uid}').onValue.listen(
          (event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _invoices = data.entries.map((e) => Map<String, dynamic>.from(e.value as Map)..['id'] = e.key).toList();
            notifyListeners();
          } else {
            _invoices = [];
            notifyListeners();
          }
        } else {
          _invoices = [];
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Failed to fetch invoices: $error';
        notifyListeners();
      },
    );

    // Notifications Listener
    _notificationsSubscription = _database.child('notifications/${user.uid}').onValue.listen(
          (event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _notifications = data.entries.map((e) => Map<String, dynamic>.from(e.value as Map)..['id'] = e.key).toList();
            notifyListeners();
          } else {
            _notifications = [];
            notifyListeners();
          }
        } else {
          _notifications = [];
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Failed to fetch notifications: $error';
        notifyListeners();
      },
    );

    // Tasks Listener
    _tasksSubscription = _database.child('vendor_tasks/${user.uid}').onValue.listen(
          (event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _tasks = data.entries.map((e) => Map<String, dynamic>.from(e.value as Map)..['id'] = e.key).toList();
            notifyListeners();
          } else {
            _tasks = [];
            notifyListeners();
          }
        } else {
          _tasks = [];
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Failed to fetch tasks: $error';
        notifyListeners();
      },
    );
  }*/
  // Example snippet for VendorController
  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }
    _ordersSubscription = _database.child('user/vendor/${user.uid}/orders').onValue.listen(
          (event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _orders = data.entries.map((e) => Order.fromMap(Map<String, dynamic>.from(e.value as Map), id: e.key as String)).toList();
            _errorMessage = null;
          } else {
            _orders = [];
          }
        } else {
          _orders = [];
          _errorMessage = 'No orders found for this vendor';
        }
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to fetch orders: $error';
        notifyListeners();
      },
    );
  }

  void _stopRealTimeListeners() {
    _ordersSubscription?.cancel();
    _messagesSubscription?.cancel();
    _vendorDataSubscription?.cancel();
    _invoicesSubscription?.cancel();
    _notificationsSubscription?.cancel();
    _tasksSubscription?.cancel();
    _orders.clear();
    _messages.clear();
    _vendorData.clear();
    _invoices.clear();
    _notifications.clear();
    _tasks.clear();
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _database.child('vendors/${_auth.currentUser!.uid}/orders/$orderId/status').set(status);
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _database.child('vendors/${_auth.currentUser!.uid}/products/$productId').update(data);
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _database.child('vendors/${_auth.currentUser!.uid}/products').push().set(product);
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _database.child('notifications/${_auth.currentUser!.uid}').remove();
    } catch (e) {
      _errorMessage = 'Failed to clear notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopRealTimeListeners();
    _authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}