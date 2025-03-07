// File: lib/Controllers/contractorController.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Models/orderModel.dart';

import '../Models/userModels.dart';

class ContractorController with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StreamSubscription<DatabaseEvent>? _ordersSubscription;

  ContractorController(this._authController) {
    _checkContractorStatus();
    _authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() => _checkContractorStatus();

  void _checkContractorStatus() {
    final user = _authController.currentUser.value;
    print('Checking contractor status: user=${user?.email}, role=${user?.role}');
    if (user != null && user.role == UserRole.contractor) {
      _startRealTimeListeners();
    } else {
      _stopRealTimeListeners();
      _errorMessage = 'User is not a contractor or not authenticated';
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
    print('Starting real-time listeners for UID: ${user.uid}');
    // Update path to match database structure: user/contractor/${uid}/orders
    _ordersSubscription = _database.child('user/contractor/${user.uid}/orders').onValue.listen(
          (event) {
        print('Received data for path: user/contractor/${user.uid}/orders');
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _orders = data.entries.map((e) => Order.fromMap(Map<String, dynamic>.from(e.value as Map), id: e.key as String)).toList();
            _errorMessage = null; // Clear error on success
          } else {
            _orders = [];
            _errorMessage = 'No orders found for this contractor';
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
  }

  void _stopRealTimeListeners() {
    _ordersSubscription?.cancel();
    _orders.clear();
    notifyListeners();
  }

  Future<void> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Update path for cancellation
      await _database.child('user/contractor/${_auth.currentUser!.uid}/orders/$orderId/status').set('Cancelled');
      final order = _orders.firstWhere((order) => order.id == orderId);
      // Update vendor's order status (adjust path based on your structure)
      await _database.child('user/vendor/${order.vendorId}/orders/$orderId/status').set('Cancelled');
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