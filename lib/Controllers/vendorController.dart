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

  void _checkVendorStatus() async {
    final authUser = _auth.currentUser;
    final user = _authController.currentUser.value;
    print('Checking vendor status: authUser=${authUser?.email}, authUID=${authUser?.uid}, user=${user?.email}, userUID=${user?.uid}, Role: ${user?.role}, Authenticated: ${user != null}');
    if (user == null || authUser == null) {
      _errorMessage = 'User not authenticated. Please log in again.';
      _stopRealTimeListeners();
      notifyListeners();
      return;
    }
    if (user.uid != authUser.uid) {
      _errorMessage = 'UID mismatch between auth and controller. authUID=${authUser.uid}, userUID=${user.uid}';
      _stopRealTimeListeners();
      notifyListeners();
      return;
    }
    if (user.role != UserRole.vendor) {
      _errorMessage = 'User is not a vendor. Role: ${user.role}';
      _stopRealTimeListeners();
      notifyListeners();
      return;
    }
    _startRealTimeListeners();
  }

  void _startRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      print('Authentication failed: User is null');
      notifyListeners();
      return;
    }
    print('Starting real-time listeners for UID: ${user.uid}');

    // Vendor Data Listener
    _vendorDataSubscription?.cancel();
    _vendorDataSubscription = _database.child('user/vendor/${user.uid}').onValue.listen(
          (event) {
        print('Vendor data event for UID: ${user.uid}, exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          _vendorData = Map<String, dynamic>.from(event.snapshot.value as Map);
        } else {
          _vendorData = {};
          print('No vendor data found for UID: ${user.uid}. Please ensure vendor profile is set up.');
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching vendor data: $error, UID: ${user.uid}, Path: user/vendor/${user.uid}');
      },
    );

    // Orders Listener
    _ordersSubscription?.cancel();
    _ordersSubscription = _database.child('orders').orderByChild('vendorId').equalTo(user.uid).onValue.listen(
          (event) {
        print('Received orders data at path: orders for vendor ${user.uid}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _orders = data.entries.map((e) => Order.fromMap(Map<String, dynamic>.from(e.value), id: e.key as String)).toList();
          } else {
            _orders = [];
          }
        } else {
          _orders = [];
          print('No orders found for this vendor');
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching orders: $error');
      },
    );

    // Materials Listener (Temporary Debugging - Fetch all materials)
    // Materials Listener
    _materialsSubscription?.cancel();
    _materialsSubscription = _database.child('materials').orderByChild('vendorId').equalTo(user.uid).onValue.listen(
          (event) {
        print('Received materials data at path: materials for vendor ${user.uid}, snapshot exists: ${event.snapshot.exists}, snapshot value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _materials = data.entries.map((e) {
              final material = Map<String, dynamic>.from(e.value)..['materialId'] = e.key;
              print('Parsed material: $material');
              return material;
            }).toList();
            print('Materials list updated with ${_materials.length} items');
          } else {
            _materials = [];
            print('No valid data found in materials snapshot');
          }
        } else {
          _materials = [];
          print('No materials found for this vendor with vendorId: ${user.uid}');
        }
        notifyListeners(); // Ensure UI updates
      },
      onError: (error) {
        print('Error fetching materials: $error, UID: ${user.uid}, Path: materials');
        _materials = [];
        notifyListeners();
      },
    );
  /*  _materialsSubscription?.cancel();
    _materialsSubscription = _database.child('materials').onValue.listen(
          (event) {
        print('Received materials data at path: materials for vendor ${user.uid}, snapshot exists: ${event.snapshot.exists}, snapshot value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _materials = data.entries.map((e) {
              final material = Map<String, dynamic>.from(e.value)..['materialId'] = e.key;
              print('Parsed material: $material');
              return material;
            }).toList();
            print('Materials list updated with ${_materials.length} items');
            // Filter materials with matching vendorId
            _materials = _materials.where((material) => material['vendorId'] == user.uid).toList();
            print('Filtered materials for vendorId ${user.uid}: ${_materials.length} items');
          } else {
            _materials = [];
            print('No valid data found in materials snapshot');
          }
        } else {
          _materials = [];
          print('No materials found in the database');
        }
        notifyListeners(); // Ensure UI updates
      },
      onError: (error) {
        print('Error fetching materials: $error, UID: ${user.uid}, Path: materials');
        _materials = [];
        notifyListeners();
      },
    );*/

    // Messages Listener
    _messagesSubscription?.cancel();
    _messagesSubscription = _database
        .child('messages/contractor_vendor')
        .orderByChild('receiverId')
        .equalTo(user.uid)
        .onValue
        .listen(
          (event) {
        print('Messages data received for user ${user.uid} at path: messages/contractor_vendor, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _messages = data.entries
                .map((e) => bbMessage.Message.fromMap(Map<String, dynamic>.from(e.value), id: e.key as String))
                .toList();
          } else {
            _messages = [];
            print('No valid messages data found for receiverId: ${user.uid}');
          }
        } else {
          _messages = [];
          print('No messages found for receiverId: ${user.uid}');
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching messages: $error');
      },
    );

    // Invoices Listener
    _invoicesSubscription?.cancel();
    _invoicesSubscription = _database.child('invoices/${user.uid}').onValue.listen(
          (event) {
        print('Received invoices data for UID: ${user.uid}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
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
        print('Error fetching invoices: $error');
      },
    );

    // Notifications Listener
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _database.child('notifications/${user.uid}').onValue.listen(
          (event) {
        print('Received notifications data for UID: ${user.uid}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
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
        print('Error fetching notifications: $error');
      },
    );

    // Tasks Listener
    _tasksSubscription?.cancel();
    _tasksSubscription = _database.child('vendor_tasks/${user.uid}').onValue.listen(
          (event) {
        print('Received tasks data for UID: ${user.uid}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
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
        print('Error fetching tasks: $error');
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

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _stopRealTimeListeners();
      await Future.delayed(Duration(milliseconds: 100)); // Small delay to ensure listeners stop
      _startRealTimeListeners();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh data: $e';
      print('Refresh data error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _database.child('orders/$orderId/status').set(status);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
      print('Update order status error: $_errorMessage');
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
      _errorMessage = null;
      await refreshData(); // Refresh data after update
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      print('Update product error: $_errorMessage');
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
        final currentUserId = _auth.currentUser!.uid;
        print('Adding product with vendorId: $currentUserId');
        await _database.child('materials/$materialId').set({
          'vendorId': currentUserId,
          ...product,
        });
        _errorMessage = null;
        await refreshData(); // Refresh data after adding
      } else {
        _errorMessage = 'Failed to generate material ID';
      }
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      print('Add product error: $_errorMessage');
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
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to generate invoice ID';
      }
    } catch (e) {
      _errorMessage = 'Failed to generate invoice: $e';
      print('Generate invoice error: $_errorMessage');
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
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to confirm payment: $e';
      print('Confirm payment error: $_errorMessage');
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
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to clear notifications: $e';
      print('Clear notifications error: $_errorMessage');
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