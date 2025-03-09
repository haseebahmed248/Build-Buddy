import 'dart:async';
import 'package:buildbuddy/Models/userModels.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Models/orderModel.dart';
import 'package:buildbuddy/Models/messageModel.dart' as bbMessage;

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
    print('VendorController initialized at ${DateTime.now()}');
    _checkVendorStatus();
    _authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    print('Auth state changed at ${DateTime.now()}, checking vendor status');
    _checkVendorStatus();
  }

  void _checkVendorStatus() async {
    final authUser = _auth.currentUser;
    final user = _authController.currentUser.value;
    print(
        'Checking vendor status at ${DateTime.now()}: authUser=${authUser?.email}, authUID=${authUser?.uid}, user=${user?.email}, userUID=${user?.uid}, Role: ${user?.role}, Authenticated: ${user != null}');
    if (user == null || authUser == null) {
      _errorMessage = 'User not authenticated. Please log in again.';
      print('Authentication error at ${DateTime.now()}: $_errorMessage');
      _stopRealTimeListeners();
      notifyListeners();
      return;
    }
    if (user.uid != authUser.uid) {
      _errorMessage =
      'UID mismatch between auth and controller. authUID=${authUser.uid}, userUID=${user.uid}';
      print('Authentication error at ${DateTime.now()}: $_errorMessage');
      _stopRealTimeListeners();
      notifyListeners();
      return;
    }
    if (user.role != UserRole.vendor) {
      _errorMessage = 'User is not a vendor. Role: ${user.role}';
      print('Role error at ${DateTime.now()}: $_errorMessage');
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
      print('Authentication failed at ${DateTime.now()}: User is null');
      notifyListeners();
      return;
    }
    print('Starting real-time listeners for UID: ${user.uid} at ${DateTime.now()}');
    print('Current user UID: ${user.uid}');

    // Vendor Data Listener
    _vendorDataSubscription?.cancel();
    _vendorDataSubscription = _database
        .child('user/vendor/${user.uid}')
        .onValue
        .listen(
          (event) {
        print(
            'Vendor data event for UID: ${user.uid} at ${DateTime.now()}, exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          _vendorData = Map<String, dynamic>.from(event.snapshot.value as Map);
        } else {
          _vendorData = {};
          print(
              'No vendor data found for UID: ${user.uid} at ${DateTime.now()}. Please ensure vendor profile is set up.');
        }
        notifyListeners();
      },
      onError: (error) {
        print(
            'Error fetching vendor data at ${DateTime.now()}: $error, UID: ${user.uid}, Path: user/vendor/${user.uid}, Stack: ${StackTrace.current}');
      },
    );

    // Orders Listener with improved debugging
    _ordersSubscription?.cancel();
    print('Looking for orders with vendorId: ${user.uid}');

    // First, let's check all orders to see if any exist with our vendorId
    _database.child('orders').get().then((snapshot) {
      print('All orders (debug): ${snapshot.value}');
      if (snapshot.exists) {
        final allOrders = snapshot.value as Map<dynamic, dynamic>;
        allOrders.forEach((key, value) {
          final order = Map<String, dynamic>.from(value);
          print('Order $key vendorId: ${order['vendorId']}, current user uid: ${user.uid}');
        });
      }
    });

    _ordersSubscription = _database
        .child('orders')
        .onValue
        .listen(
          (event) {
        print('All orders snapshot at ${DateTime.now()}, exists: ${event.snapshot.exists}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            // Filter orders manually to ensure we catch any case sensitivity issues
            final List<Order> filteredOrders = [];
            data.forEach((key, value) {
              final orderData = Map<String, dynamic>.from(value);
              print('Checking order: $key, vendorId: ${orderData['vendorId']}, current user: ${user.uid}');

              // Check both lowercase versions to handle any case sensitivity issues
              if (orderData['vendorId']?.toString().toLowerCase() == user.uid.toLowerCase()) {
                print('Order matches current vendor: $key');
                filteredOrders.add(Order.fromMap(orderData, id: key as String));
              }
            });

            _orders = filteredOrders;
            print('Orders filtered for vendor - found ${_orders.length} orders: ${_orders.map((o) => o.id).toList()}');
          } else {
            _orders = [];
            print('No valid data in orders snapshot at ${DateTime.now()}');
          }
        } else {
          _orders = [];
          print('No orders found in database at ${DateTime.now()}');
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching orders at ${DateTime.now()}: $error, Path: orders, UID: ${user.uid}, Stack: ${StackTrace.current}');
        _orders = []; // Silent failure to prevent UI break
        notifyListeners();
      },
    );

    // Materials Listener
    _materialsSubscription?.cancel();
    _materialsSubscription = _database
        .child('materials')
        .orderByChild('vendorId')
        .equalTo(user.uid)
        .onValue
        .listen(
          (event) {
        print('=== Materials Listener Fired at ${DateTime.now()} ===');
        print('User UID: ${user.uid}');
        print('Snapshot exists: ${event.snapshot.exists}');
        print('Snapshot value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _materials = data.entries.map((e) {
              final material = Map<String, dynamic>.from(e.value)
                ..['materialId'] = e.key;
              print('Parsed material at ${DateTime.now()}: $material');
              return material;
            }).toList();
            print(
                'Materials list updated with ${_materials.length} items at ${DateTime.now()}: $_materials');
          } else {
            _materials = [];
            print('No valid data found in materials snapshot at ${DateTime.now()}');
          }
        } else {
          _materials = [];
          print('No materials found for vendorId: ${user.uid} at ${DateTime.now()}');
        }
        _errorMessage = null; // Clear error on successful fetch
        print('Notifying listeners with ${_materials.length} materials at ${DateTime.now()}');
        notifyListeners();
      },
      onError: (error) {
        print(
            'Error fetching materials at ${DateTime.now()}: $error, Path: materials, UID: ${user.uid}, Stack: ${StackTrace.current}');
        _errorMessage = 'Failed to fetch materials: $error';
        _materials = [];
        notifyListeners();
      },
    );

    // Messages Listener
    _messagesSubscription?.cancel();
    _messagesSubscription = _database
        .child('messages/contractor_vendor')
        .orderByChild('receiverId')
        .equalTo(user.uid)
        .onValue
        .listen(
          (event) {
        print(
            'Messages data event for UID: ${user.uid} at ${DateTime.now()}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _messages = data.entries
                .map((e) => bbMessage.Message.fromMap(
                Map<String, dynamic>.from(e.value), id: e.key as String))
                .toList();
          } else {
            _messages = [];
            print('No valid messages data found for receiverId: ${user.uid} at ${DateTime.now()}');
          }
        } else {
          _messages = [];
          print('No messages found for receiverId: ${user.uid} at ${DateTime.now()}');
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching messages at ${DateTime.now()}: $error, Stack: ${StackTrace.current}');
      },
    );

    // Invoices Listener
    _invoicesSubscription?.cancel();
    _invoicesSubscription = _database
        .child('invoices/${user.uid}')
        .onValue
        .listen(
          (event) {
        print(
            'Invoices data event for UID: ${user.uid} at ${DateTime.now()}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _invoices = data.entries
                .map((e) => Map<String, dynamic>.from(e.value)..['id'] = e.key)
                .toList();
          } else {
            _invoices = [];
          }
        } else {
          _invoices = [];
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching invoices at ${DateTime.now()}: $error, Stack: ${StackTrace.current}');
      },
    );

    // Notifications Listener
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _database
        .child('notifications/${user.uid}')
        .onValue
        .listen(
          (event) {
        print(
            'Notifications data event for UID: ${user.uid} at ${DateTime.now()}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _notifications = data.entries
                .map((e) => Map<String, dynamic>.from(e.value)..['id'] = e.key)
                .toList();
            print('Notifications parsed: ${_notifications.map((n) => n['id']).toList()}');
          } else {
            _notifications = [];
            print('No valid data in notifications snapshot at ${DateTime.now()}');
          }
        } else {
          _notifications = [];
          print('No notifications found for UID: ${user.uid} at ${DateTime.now()}');
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching notifications at ${DateTime.now()}: $error, Path: notifications/${user.uid}, UID: ${user.uid}, Stack: ${StackTrace.current}');
        _errorMessage = 'Failed to fetch notifications: $error';
        _notifications = [];
        notifyListeners();
      },
    );

    // Tasks Listener
    _tasksSubscription?.cancel();
    _tasksSubscription = _database
        .child('vendor_tasks/${user.uid}')
        .onValue
        .listen(
          (event) {
        print(
            'Tasks data event for UID: ${user.uid} at ${DateTime.now()}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _tasks = data.entries
                .map((e) => Map<String, dynamic>.from(e.value)..['id'] = e.key)
                .toList();
          } else {
            _tasks = [];
          }
        } else {
          _tasks = [];
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching tasks at ${DateTime.now()}: $error, Stack: ${StackTrace.current}');
      },
    );
  }

  void _stopRealTimeListeners() {
    print('Stopping real-time listeners at ${DateTime.now()}');
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
    print('Refreshing data at ${DateTime.now()}');
    _isLoading = true;
    notifyListeners();
    try {
      _stopRealTimeListeners();
      await Future.delayed(Duration(milliseconds: 100)); // Small delay to ensure listeners stop
      _startRealTimeListeners();
      _errorMessage = null;
      print('Refresh completed successfully at ${DateTime.now()}');
    } catch (e) {
      _errorMessage = 'Failed to refresh data: $e';
      print('Refresh data error at ${DateTime.now()}: $_errorMessage');
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
      await refreshData(); // Refresh data after update
      print('Order status updated successfully: $orderId at ${DateTime.now()}');
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
      print('Update order status error at ${DateTime.now()}: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final vendorId = user.uid;
      print('Adding product with vendorId: $vendorId at ${DateTime.now()}');

      final newRef = _database.child('materials').push();
      await newRef.set({
        ...product,
        'vendorId': vendorId, // Ensure vendorId is included
        'date': DateTime.now().toIso8601String(), // Add date if not provided
      });
      print('Product added successfully: ${product.toString()} with vendorId: $vendorId at ${DateTime.now()}');
      _errorMessage = null;
      await refreshData(); // Refresh data after adding
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      print('Add product error at ${DateTime.now()}: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(String materialId, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();
    try {
      print('Updating product with ID: $materialId at ${DateTime.now()}');
      await _database.child('materials/$materialId').update(updates);
      print('Product updated successfully: $materialId at ${DateTime.now()}');
      _errorMessage = null;
      await refreshData(); // Refresh data after update
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      print('Update product error at ${DateTime.now()}: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String materialId) async {
    _isLoading = true;
    notifyListeners();
    try {
      print('Deleting product with ID: $materialId at ${DateTime.now()}');
      await _database.child('materials/$materialId').remove();
      print('Product deleted successfully: $materialId at ${DateTime.now()}');
      _errorMessage = null;
      await refreshData(); // Refresh data after delete
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      print('Delete product error at ${DateTime.now()}: $_errorMessage');
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
        print('Invoice generated successfully: $invoiceId at ${DateTime.now()}');
        _errorMessage = null;
        await refreshData(); // Refresh data after generating invoice
      } else {
        _errorMessage = 'Failed to generate invoice ID';
        print('Error at ${DateTime.now()}: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Failed to generate invoice: $e';
      print('Generate invoice error at ${DateTime.now()}: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmPayment(String invoiceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _database
          .child('invoices/${_auth.currentUser!.uid}/$invoiceId/status')
          .set('Paid');
      print('Payment confirmed for invoice: $invoiceId at ${DateTime.now()}');
      _errorMessage = null;
      await refreshData(); // Refresh data after confirming payment
    } catch (e) {
      _errorMessage = 'Failed to confirm payment: $e';
      print('Confirm payment error at ${DateTime.now()}: $_errorMessage');
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
      print('Notifications cleared successfully at ${DateTime.now()}');
      _errorMessage = null;
      await refreshData(); // Refresh data after clearing notifications
    } catch (e) {
      _errorMessage = 'Failed to clear notifications: $e';
      print('Clear notifications error at ${DateTime.now()}: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print('Disposing VendorController at ${DateTime.now()}');
    _stopRealTimeListeners();
    _authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}