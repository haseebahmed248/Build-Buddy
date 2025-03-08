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
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  List<Map<String, dynamic>> get vendorMaterials => _vendorMaterials;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StreamSubscription<DatabaseEvent>? _ordersSubscription;
  StreamSubscription<DatabaseEvent>? _materialsSubscription;

  ContractorController(this._authController) {
    _checkContractorStatus();
    _authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() => _checkContractorStatus();

  void _checkContractorStatus() {
    final user = _authController.currentUser.value;
    print('Checking contractor status: user=${user?.email}, role=${user?.role}, authenticated=${user != null}');
    if (user != null && user.role == UserRole.contractor) {
      _startRealTimeListeners();
    } else {
      _stopRealTimeListeners();
      _errorMessage = 'User is not a contractor or not authenticated. Please sign in.';
      notifyListeners();
    }
  }

  Future<void> _startRealTimeListeners() async {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated. Attempting to wait for authentication...';
      print('Authentication failed: user is null');
      await Future.delayed(const Duration(seconds: 2));
      if (_auth.currentUser == null) {
        _errorMessage = 'Authentication failed after delay. Please sign in.';
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    _isLoading = true;
    notifyListeners();
    print('Starting real-time listeners for UID: ${user!.uid}');

    _ordersSubscription = _database.child('orders').orderByChild('contractorId').equalTo(user.uid).onValue.listen(
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
          _errorMessage = 'No orders found for this contractor';
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching orders: $error');
        _errorMessage = 'Failed to fetch orders: $error';
        notifyListeners();
      },
    );

    _materialsSubscription = _database.child('materials').onValue.listen(
          (event) {
        print('Received materials data at path: materials');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _vendorMaterials = [];
            data.forEach((materialId, materialData) {
              if (materialData is Map && materialData.containsKey('vendorId')) {
                _vendorMaterials.add(Map<String, dynamic>.from(materialData)..['materialId'] = materialId);
              }
            });
            print('Fetched materials: $_vendorMaterials');
          } else {
            _vendorMaterials = [];
          }
        } else {
          _vendorMaterials = [];
          print('No materials found');
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching materials: $error');
        _errorMessage = 'Failed to fetch materials: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _stopRealTimeListeners() {
    _ordersSubscription?.cancel();
    _materialsSubscription?.cancel();
    _orders.clear();
    _vendorMaterials.clear();
    notifyListeners();
  }

  Future<void> placeOrder(String vendorId, String materialId, int quantity) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_vendorMaterials.isEmpty) {
        _errorMessage = 'No materials available to order.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      final orderId = _database.child('orders').push().key;
      if (orderId != null) {
        final material = _vendorMaterials.firstWhere(
              (m) => m['materialId'] == materialId && m['vendorId'] == vendorId,
          orElse: () => throw Exception('Material not found'),
        );
        await _database.child('orders/$orderId').set({
          'contractorId': _auth.currentUser!.uid,
          'vendorId': vendorId,
          'materialId': materialId,
          'material': material['name'],
          'quantity': quantity,
          'amount': quantity * (material['price'] ?? 0.0),
          'status': 'Pending',
          'createdAt': DateTime.now().toIso8601String(),
        });
        _errorMessage = null;
      }
    } catch (e) {
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
      await _database.child('orders/$orderId/status').set('Cancelled');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to cancel order: $e';
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