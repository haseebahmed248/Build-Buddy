
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Models/orderModel.dart';
import 'package:buildbuddy/Models/messageModel.dart' as bbMessage;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../Models/userModels.dart';

class VendorController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController;

  List<Order> _orders = [];
  List<bbMessage.Message> _messages = [];
  Map<String, dynamic> _vendorData = {};
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _materials = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  List<bbMessage.Message> get messages => _messages;
  Map<String, dynamic> get vendorData => _vendorData;
  List<Map<String, dynamic>> get invoices => _invoices;
  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get tasks => _tasks;
  List<Map<String, dynamic>> get materials => _materials;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _auth.currentUser?.uid;

  StreamSubscription<DatabaseEvent>? _ordersSubscription;
  StreamSubscription<DatabaseEvent>? _messagesSubscription;
  StreamSubscription<DatabaseEvent>? _vendorDataSubscription;
  StreamSubscription<DatabaseEvent>? _invoicesSubscription;
  StreamSubscription<DatabaseEvent>? _notificationsSubscription;
  StreamSubscription<DatabaseEvent>? _tasksSubscription;
  StreamSubscription<DatabaseEvent>? _materialsSubscription;

  VendorController(this._authController) {
    _checkVendorStatus();
    _authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() => _checkVendorStatus();

  void _checkVendorStatus() {
    final user = _authController.currentUser.value;
    print('Checking vendor status: user=${user?.email}, role=${user?.role}');
    if (user != null && user.role == UserRole.vendor) {
      _startRealTimeListeners();
    } else {
      _stopRealTimeListeners();
      _errorMessage = 'User is not a vendor or not authenticated';
      notifyListeners();
    }
  }

  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    // Vendor Data Listener
    _vendorDataSubscription = _database.child('user/vendor/${user.uid}').onValue.listen(
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
    _ordersSubscription = _database.child('orders').orderByChild('vendorId').equalTo(user.uid).onValue.listen(
          (event) {
        print('Received orders data at path: orders');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _orders = data.entries.map((e) => Order.fromMap(Map<String, dynamic>.from(e.value), id: e.key as String)).toList();
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
        print('Error fetching orders: $error');
        _errorMessage = 'Failed to fetch orders: $error';
        notifyListeners();
      },
    );

    // Materials Listener (from centralized materials node)
    _materialsSubscription = _database.child('materials').orderByChild('vendorId').equalTo(user.uid).onValue.listen(
          (event) {
        print('Received materials data at path: materials for vendor ${user.uid}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _materials = data.entries.map((e) => Map<String, dynamic>.from(e.value)..['materialId'] = e.key).toList();
          } else {
            _materials = [];
          }
        } else {
          _materials = [];
          print('No materials found for this vendor');
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching materials: $error');
        _errorMessage = 'Failed to fetch materials: $error';
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
            _messages = data.entries.map((e) => bbMessage.Message.fromMap(Map<String, dynamic>.from(e.value), id: e.key as String)).toList();
          } else {
            _messages = [];
          }
        } else {
          _messages = [];
        }
        notifyListeners();
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
            _invoices = data.entries.map((e) => Map<String, dynamic>.from(e.value)..['id'] = e.key).toList();
          } else {
            _invoices = [];
          }
        } else {
          _invoices = [];
        }
        notifyListeners();
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
            _notifications = data.entries.map((e) => Map<String, dynamic>.from(e.value)..['id'] = e.key).toList();
          } else {
            _notifications = [];
          }
        } else {
          _notifications = [];
        }
        notifyListeners();
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
            _tasks = data.entries.map((e) => Map<String, dynamic>.from(e.value)..['id'] = e.key).toList();
          } else {
            _tasks = [];
          }
        } else {
          _tasks = [];
        }
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to fetch tasks: $error';
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
    _materialsSubscription?.cancel();
    _orders.clear();
    _messages.clear();
    _vendorData.clear();
    _invoices.clear();
    _notifications.clear();
    _tasks.clear();
    _materials.clear();
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _database.child('orders/$orderId/status').set(status);
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(String materialId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _database.child('materials/$materialId').update(data);
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
      final materialId = _database.child('materials').push().key;
      if (materialId != null) {
        await _database.child('materials/$materialId').set({
          'vendorId': _auth.currentUser!.uid,
          ...product,
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateInvoice(String orderId, double amount) async {
    _isLoading = true;
    notifyListeners();
    try {
      final invoiceId = _database.child('invoices/${_auth.currentUser!.uid}').push().key;
      if (invoiceId != null) {
        await _database.child('invoices/${_auth.currentUser!.uid}/$invoiceId').set({
          'orderId': orderId,
          'amount': amount,
          'status': 'Pending',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to generate invoice: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmPayment(String invoiceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _database.child('invoices/${_auth.currentUser!.uid}/$invoiceId/status').set('Paid');
    } catch (e) {
      _errorMessage = 'Failed to confirm payment: $e';
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