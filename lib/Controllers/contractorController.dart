import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Models/orderModel.dart';
import 'package:buildbuddy/Models/userModels.dart';

class ContractorController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController;

  List<Order> _orders = [];
  List<Map<String, dynamic>> _vendorMaterials = [];
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  List<Map<String, dynamic>> get vendorMaterials => _vendorMaterials;
  List<Map<String, dynamic>> get projects => _projects;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _auth.currentUser?.uid;

  StreamSubscription<DatabaseEvent>? _ordersSubscription;
  StreamSubscription<DatabaseEvent>? _materialsSubscription;
  StreamSubscription<DatabaseEvent>? _projectsSubscription;
  StreamSubscription<DatabaseEvent>? _messagesSubscription;

  ContractorController(this._authController) {
    print('ContractorController initialized at ${DateTime.now()}');
    _checkContractorStatus();
    _authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    print('Auth state changed at ${DateTime.now()}');
    _checkContractorStatus();
  }

  void _checkContractorStatus() {
    final authUser = _auth.currentUser;
    final user = _authController.currentUser.value;
    print(
        'Checking contractor status at ${DateTime.now()}: authUser=${authUser?.email}, authUID=${authUser?.uid}, user=${user?.email}, userUID=${user?.uid}, Role: ${user?.role}, Authenticated: ${user != null}');
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
    if (user.role != UserRole.contractor) {
      _errorMessage = 'User is not a contractor. Role: ${user.role}';
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

    // Orders Listener
    _ordersSubscription?.cancel();
    _ordersSubscription = _database
        .child('orders')
        .orderByChild('contractorId')
        .equalTo(user.uid)
        .onValue
        .listen(
          (event) {
        print(
            'Orders data event for UID: ${user.uid} at ${DateTime.now()}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _orders = data.entries
                .map((e) => Order.fromMap(
                Map<String, dynamic>.from(e.value), id: e.key as String))
                .toList();
            print('Orders parsed successfully: ${_orders.map((o) => o.id).toList()}');
          } else {
            _orders = [];
            print('No valid data in orders snapshot at ${DateTime.now()}');
          }
        } else {
          _orders = [];
          print('No orders found for contractorId: ${user.uid} at ${DateTime.now()}');
        }
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        print(
            'Error fetching orders at ${DateTime.now()}: $error, Path: orders, UID: ${user.uid}, Stack: ${StackTrace.current}');
        _orders = [];
        notifyListeners();
      },
    );

    // Vendor Materials Listener
    _materialsSubscription?.cancel();
    _materialsSubscription = _database.child('materials').onValue.listen(
          (event) {
        print(
            'Vendor materials data event at ${DateTime.now()}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _vendorMaterials = [];
            data.forEach((materialId, materialData) {
              print('Processing materialId: $materialId, data: $materialData');
              if (materialData is Map && materialData.containsKey('vendorId')) {
                _vendorMaterials.add(Map<String, dynamic>.from(materialData as Map)
                  ..['materialId'] = materialId);
              } else {
                print('Skipping materialId: $materialId, invalid data or missing vendorId');
              }
            });
            print(
                'Vendor materials parsed: ${_vendorMaterials.length} items at ${DateTime.now()}: $_vendorMaterials');
          } else {
            _vendorMaterials = [];
            print('No valid data in vendor materials snapshot at ${DateTime.now()}');
          }
        } else {
          _vendorMaterials = [];
          print('No vendor materials found at ${DateTime.now()}');
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print(
            'Error fetching vendor materials at ${DateTime.now()}: $error, Path: materials, Stack: ${StackTrace.current}');
        _vendorMaterials = [];
        _isLoading = false;
        notifyListeners();
      },
    );

    // Projects Listener
    _projectsSubscription?.cancel();
    _projectsSubscription = _database
        .child('projects')
        .orderByChild('contractorId')
        .equalTo(user.uid)
        .onValue
        .listen(
          (event) {
        print(
            'Projects data event for UID: ${user.uid} at ${DateTime.now()}, snapshot exists: ${event.snapshot.exists}, value: ${event.snapshot.value}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _projects = data.entries
                .where((e) => (e.value as Map?)?.containsKey('status') ?? false)
                .where((e) => (e.value as Map)['status'] == 'active')
                .map((e) => Map<String, dynamic>.from(e.value)
              ..['projectId'] = e.key as String)
                .toList();
            print('Projects parsed successfully: ${_projects.map((p) => p['projectId']).toList()}');
          } else {
            _projects = [];
            print('No valid data in projects snapshot at ${DateTime.now()}');
          }
        } else {
          _projects = [];
          print('No projects found for contractorId: ${user.uid} at ${DateTime.now()}');
        }
        notifyListeners();
      },
      onError: (error) {
        print(
            'Error fetching projects at ${DateTime.now()}: $error, Path: projects, UID: ${user.uid}, Stack: ${StackTrace.current}');
        _projects = [];
        notifyListeners();
      },
    );

    // Messages Listener
    _messagesSubscription?.cancel();
    _messagesSubscription = _database
        .child('messages')
        .orderByChild('contractorId')
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
                .where((e) => (e.value as Map?)?.containsKey('read') ?? false)
                .where((e) => (e.value as Map)['read'] == false)
                .map((e) => Map<String, dynamic>.from(e.value)
              ..['messageId'] = e.key as String)
                .toList();
            print('Messages parsed successfully: ${_messages.map((m) => m['messageId']).toList()}');
          } else {
            _messages = [];
            print('No valid data in messages snapshot at ${DateTime.now()}');
          }
        } else {
          _messages = [];
          print('No messages found for contractorId: ${user.uid} at ${DateTime.now()}');
        }
        notifyListeners();
      },
      onError: (error) {
        print(
            'Error fetching messages at ${DateTime.now()}: $error, Path: messages, UID: ${user.uid}, Stack: ${StackTrace.current}');
        _messages = [];
        notifyListeners();
      },
    );
  }

  void _stopRealTimeListeners() {
    print('Stopping real-time listeners at ${DateTime.now()}');
    _ordersSubscription?.cancel();
    _materialsSubscription?.cancel();
    _projectsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _orders.clear();
    _vendorMaterials.clear();
    _projects.clear();
    _messages.clear();
    notifyListeners();
  }

  Future<void> refreshData() async {
    print('Refreshing data at ${DateTime.now()}');
    _isLoading = true;
    notifyListeners();
    try {
      _stopRealTimeListeners();
      await Future.delayed(Duration(milliseconds: 100));
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

  Future<void> placeOrder(String vendorId, String materialId, int quantity) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';
      print('Attempting to place order with UID: ${user.uid} at ${DateTime.now()}');

      if (_vendorMaterials.isEmpty) {
        _errorMessage = 'No materials available to order.';
        print('No materials available at ${DateTime.now()}');
        _isLoading = false;
        notifyListeners();
        return;
      }

      final material = _vendorMaterials.firstWhere(
            (m) => m['materialId'] == materialId && m['vendorId'] == vendorId,
        orElse: () => throw Exception('Material not found'),
      );
      final amount = quantity * (material['price'] as num? ?? 0.0).toDouble();

      final orderRef = _database.child('orders').push();
      await orderRef.set({
        'contractorId': user.uid,
        'vendorId': vendorId,
        'materialId': materialId,
        'material': material['name'],
        'quantity': quantity,
        'amount': amount,
        'status': 'Pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
      print('Order placed successfully: ${orderRef.key} at ${DateTime.now()}');
      _errorMessage = null;
      await refreshData();
    } catch (e) {
      print('Place order error at ${DateTime.now()}: $e');
      _errorMessage = 'Failed to place order: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      print('Cancelling order: $orderId at ${DateTime.now()}');
      await _database.child('orders/$orderId').update({
        'status': 'Cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('Order cancelled successfully: $orderId at ${DateTime.now()}');
      _errorMessage = null;
      await refreshData();
    } catch (e) {
      print('Cancel order error at ${DateTime.now()}: $e');
      _errorMessage = 'Failed to cancel order: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print('Disposing ContractorController at ${DateTime.now()}');
    _stopRealTimeListeners();
    _authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}