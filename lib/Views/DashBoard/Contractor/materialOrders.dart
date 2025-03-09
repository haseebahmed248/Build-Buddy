import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/contractorController.dart';
import 'package:buildbuddy/Models/orderModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MaterialOrdersScreen extends StatelessWidget {
  const MaterialOrdersScreen({super.key});

  void _showCancelOrderDialog(BuildContext context, ContractorController controller, Order order) {
    if (order.status == 'Cancelled') return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Order #${order.id}'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              controller.cancelOrder(order.id);
              Navigator.pop(context);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPlaceOrderDialog(BuildContext context, ContractorController controller, Map<String, dynamic> material) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Place Order for ${material['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Price: \$${material['price']} per unit'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
              onChanged: (value) => quantity = int.tryParse(value) ?? 1,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              print('Placing order for material: ${material['name']} with quantity: $quantity');
              controller.placeOrder(material['vendorId'], material['materialId'], quantity);
              Navigator.pop(context);
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  void _showDedicatedPlaceOrderDialog(BuildContext context, ContractorController controller) {
    if (controller.vendorMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No materials available to order.')),
      );
      return;
    }

    Map<String, dynamic> selectedMaterial = controller.vendorMaterials.first;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Place Order for ${selectedMaterial['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Price: \$${selectedMaterial['price']} per unit'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
              onChanged: (value) => quantity = int.tryParse(value) ?? 1,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              print('Placing order for material: ${selectedMaterial['name']} with quantity: $quantity');
              controller.placeOrder(selectedMaterial['vendorId'], selectedMaterial['materialId'], quantity);
              Navigator.pop(context);
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not authenticated in MaterialOrdersScreen');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You are not signed in.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/stakeholder');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3799), Color(0xFF4834DF)],
            ),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'My Orders',
                                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Manage your material orders',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => _showDedicatedPlaceOrderDialog(context, context.read<ContractorController>()),
                                  child: const Text(
                                    'Place Order',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.filter_list, color: Colors.white),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Consumer<ContractorController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            print('Loading state active');
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage != null) {
            print('Error state: ${controller.errorMessage}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${controller.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/stakeholder');
                    },
                    child: const Text('Sign In Again to Retry'),
                  ),
                ],
              ),
            );
          }
          print('Rendering materials: ${controller.vendorMaterials.length} items');
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Available Materials',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (controller.vendorMaterials.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'No materials available.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              else
                ...controller.vendorMaterials.map((material) => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      material['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Price: \$${material['price']}, Available: ${material['quantity'] ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF4834DF)),
                      onPressed: () => _showPlaceOrderDialog(context, controller, material),
                    ),
                  ),
                )),
              const SizedBox(height: 20),
              const Text(
                'My Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (controller.orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'No orders found.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              else
                ...controller.orders.map((order) => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      'Order #${order.id} - ${order.material}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Quantity: ${order.quantity}, Status: ${order.status}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${order.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4834DF)),
                        ),
                        if (order.status != 'Cancelled')
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _showCancelOrderDialog(context, controller, order),
                          ),
                      ],
                    ),
                  ),
                )),
            ],
          );
        },
      ),
    );
  }
}