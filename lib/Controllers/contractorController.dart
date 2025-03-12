import 'dart:async';
import 'package:buildbuddy/Models/orderModel.dart';
import 'package:buildbuddy/Models/messageModel.dart' as bbMessage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';

import '../Models/userModels.dart';

class ContractorController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController;

  List<Order> _orders = [];
  List<Map<String, dynamic>> _vendorMaterials = [];
  List<Map<String, dynamic>> _projects = [];
  List<bbMessage.Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  int _activeProjects = 0;
  int _pendingOrders = 0;
  int _newMessages = 0;

  List<Order> get orders => _orders;
  List<Map<String, dynamic>> get vendorMaterials => _vendorMaterials;
  List<Map<String, dynamic>> get projects => _projects;
  List<bbMessage.Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  set isInitialized(bool value) {
    _isInitialized = value;
    notifyListeners();
  }

  int get activeProjects => _activeProjects;
  int get pendingOrders => _pendingOrders;
  int get newMessages => _newMessages;

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
    print('Auth state changed at ${DateTime.now()}, checking contractor status');
    _checkContractorStatus();
  }

  void _checkContractorStatus() async {
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
        print('Orders snapshot at ${DateTime.now()}, exists: ${event.snapshot.exists}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _orders = data.entries
                .map((e) => Order.fromMap(
                Map<String, dynamic>.from(e.value), id: e.key as String))
                .toList();
            _pendingOrders = _orders.where((order) => order.status == 'Pending').length;
          } else {
            _orders = [];
            _pendingOrders = 0;
          }
        } else {
          _orders = [];
          _pendingOrders = 0;
        }
        print('Orders updated - Total: ${_orders.length}, Pending: $_pendingOrders');
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching orders: $error');
        _errorMessage = 'Failed to fetch orders: $error';
        _orders = [];
        _pendingOrders = 0;
        notifyListeners();
      },
    );

    // Materials Listener
    _materialsSubscription?.cancel();
    _materialsSubscription = _database
        .child('materials')
        .onValue
        .listen(
          (event) {
        print('Materials snapshot at ${DateTime.now()}, exists: ${event.snapshot.exists}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _vendorMaterials = data.entries.map((e) {
              final material = Map<String, dynamic>.from(e.value)
                ..['materialId'] = e.key;
              return material;
            }).toList();
          } else {
            _vendorMaterials = [];
          }
        } else {
          _vendorMaterials = [];
        }
        print('Materials updated: ${_vendorMaterials.length}');
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching materials: $error');
        _errorMessage = 'Failed to fetch materials: $error';
        _vendorMaterials = [];
        notifyListeners();
      },
    );

    // Projects Listener
    _projectsSubscription?.cancel();
    _projectsSubscription = _database
        .child('projects/${user.uid}')
        .onValue
        .listen(
          (event) {
        print('Projects snapshot at ${DateTime.now()}, exists: ${event.snapshot.exists}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _projects = data.entries
                .map((e) => Map<String, dynamic>.from(e.value)..['id'] = e.key)
                .toList();
            _activeProjects = _projects
                .where((project) => project['status'] == 'Active')
                .length;
          } else {
            _projects = [];
            _activeProjects = 0;
          }
        } else {
          _projects = [];
          _activeProjects = 0;
        }
        print('Active Projects updated to: $_activeProjects');
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching projects: $error');
        _errorMessage = 'Failed to fetch projects: $error';
        _projects = [];
        _activeProjects = 0;
        notifyListeners();
      },
    );

    // Messages Listener
    _messagesSubscription?.cancel();
    _messagesSubscription = _database
        .child('messages/contractor_vendor')
        .orderByChild('senderId')
        .equalTo(user.uid)
        .onValue
        .listen(
          (event) {
        print('Messages snapshot at ${DateTime.now()}, exists: ${event.snapshot.exists}');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _messages = data.entries
                .map((e) => bbMessage.Message.fromMap(
                Map<String, dynamic>.from(e.value), id: e.key as String))
                .toList();
            _newMessages = _messages
                .where((message) => message.read == false)
                .length;
          } else {
            _messages = [];
            _newMessages = 0;
          }
        } else {
          _messages = [];
          _newMessages = 0;
        }
        print('New Messages updated to: $_newMessages');
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching messages: $error');
        _errorMessage = 'Failed to fetch messages: $error';
        _messages = [];
        _newMessages = 0;
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
    _activeProjects = 0;
    _pendingOrders = 0;
    _newMessages = 0;
    notifyListeners();
  }

  Future<void> fetchMaterials() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.child('materials').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _vendorMaterials = data.entries.map((e) {
            final material = Map<String, dynamic>.from(e.value)
              ..['materialId'] = e.key;
            return material;
          }).toList();
        } else {
          _vendorMaterials = [];
        }
      } else {
        _vendorMaterials = [];
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch materials: $e';
      print('Fetch materials error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';
      final snapshot = await _database
          .child('orders')
          .orderByChild('contractorId')
          .equalTo(user.uid)
          .get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _orders = data.entries
              .map((e) => Order.fromMap(
              Map<String, dynamic>.from(e.value), id: e.key as String))
              .toList();
          _pendingOrders = _orders.where((order) => order.status == 'Pending').length;
        } else {
          _orders = [];
          _pendingOrders = 0;
        }
      } else {
        _orders = [];
        _pendingOrders = 0;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch orders: $e';
      print('Fetch orders error: $_errorMessage');
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

      final materialSnapshot = await _database.child('materials/$materialId').get();
      if (!materialSnapshot.exists) throw 'Material not found';
      final materialData = Map<String, dynamic>.from(materialSnapshot.value as Map);
      final price = materialData['price'] ?? 0;

      final orderRef = _database.child('orders').push();
      final orderId = orderRef.key;
      if (orderId == null) throw 'Failed to generate order ID';

      final orderData = {
        'id': orderId,
        'vendorId': vendorId,
        'contractorId': user.uid,
        'materialId': materialId,
        'material': materialData['name'],
        'quantity': quantity,
        'amount': price * quantity,
        'status': 'Pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await orderRef.set(orderData);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to place order: $e';
      print('Place order error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void cancelOrder(String orderId) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    order.status = 'Cancelled';
    _database.child('orders/$orderId').update({'status': 'Cancelled'});
    _pendingOrders = _orders.where((order) => order.status == 'Pending').length;
    notifyListeners();
  }

  @override
  void dispose() {
    print('Disposing ContractorController at ${DateTime.now()}');
    _stopRealTimeListeners();
    _authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}