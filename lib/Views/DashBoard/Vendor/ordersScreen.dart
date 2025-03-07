import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/vendorController.dart';
import 'package:buildbuddy/Models/orderModel.dart';

class MaterialOrdersScreen extends StatelessWidget {
  const MaterialOrdersScreen({super.key});

  void _showUpdateStatusDialog(BuildContext context, VendorController controller, Order order) {
    String status = order.status;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Order #${order.id} Status'),
        content: DropdownButtonFormField<String>(
          value: status,
          items: ['Pending', 'Shipped', 'Delivered'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (value) => status = value!,
          decoration: const InputDecoration(labelText: 'Status'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.updateOrderStatus(order.id, status);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                                      'Material Orders',
                                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Manage contractor orders',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_list, color: Colors.white),
                              onPressed: () {
                                // Add filter logic here if needed
                              },
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
      body: Consumer<VendorController>(
        builder: (context, controller, child) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (controller.errorMessage != null) return Center(child: Text('Error: ${controller.errorMessage}'));
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return Card(
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
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF4834DF)),
                        onPressed: () => _showUpdateStatusDialog(context, controller, order),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}







///////////ui for vendor orders screen
/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/contractorController.dart';

class MaterialOrdersScreen extends StatelessWidget {
  const MaterialOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Orders'),
      ),
      body: Consumer<ContractorController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage != null) {
            return Center(child: Text('Error: ${controller.errorMessage}'));
          }
          return ListView.builder(
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return ListTile(
                title: Text('Order #${order.id} - ${order.material}'),
                subtitle: Text('Quantity: ${order.quantity}, Status: ${order.status}'),
                trailing: Text('\$${order.price}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlaceOrderDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPlaceOrderDialog(BuildContext context) {
    final contractorController = Provider.of<ContractorController>(context, listen: false);
    String vendorId = '';
    String material = '';
    int quantity = 1;
    double price = 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Place Material Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Vendor ID'),
              onChanged: (value) => vendorId = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Material'),
              onChanged: (value) => material = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) => quantity = int.tryParse(value) ?? 1,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Price (\$)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => price = double.tryParse(value) ?? 0.0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              contractorController.placeOrder(vendorId, material, quantity, price);
              Navigator.pop(context);
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
*/








/*
import 'package:flutter/material.dart';

class VendorOrdersScreen extends StatelessWidget {
  // Sample data for orders with additional details
  final List<Map<String, dynamic>> orders = [
    {
      'orderId': 'ORD-001',
      'customer': 'John Doe',
      'status': 'Pending',
      'date': '08 Dec 2024',
      'amount': '\$156.00'
    },
    {
      'orderId': 'ORD-002',
      'customer': 'Jane Smith',
      'status': 'Completed',
      'date': '08 Dec 2024',
      'amount': '\$230.50'
    },
    {
      'orderId': 'ORD-003',
      'customer': 'Michael Johnson',
      'status': 'Shipped',
      'date': '07 Dec 2024',
      'amount': '\$345.75'
    },
    {
      'orderId': 'ORD-004',
      'customer': 'Emily Davis',
      'status': 'Cancelled',
      'date': '07 Dec 2024',
      'amount': '\$89.99'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Order Management',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF6B46C1), // Deep purple color
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Add filter functionality here
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B46C1), // Deep purple
              Color(0xFF9F7AEA), // Medium purple
              Color(0xFFF7FAFC), // Light background
            ],
            stops: [0.0, 0.2, 0.4],
          ),
        ),
        child: Column(
          children: [
            // Order Summary Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard('Pending', '2', Icons.pending_actions),
                  _buildSummaryCard('Completed', '5', Icons.check_circle_outline),
                  _buildSummaryCard('Cancelled', '1', Icons.cancel_outlined),
                ],
              ),
            ),
            // Orders List
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFFF3E8FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      order['orderId'] ?? 'N/A', // Handle null values
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    _buildStatusBadge(order['status'] ?? 'Unknown'), // Handle null status
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order['customer'] ?? 'N/A', // Handle null customer
                                          style: TextStyle(
                                            color: Color(0xFF4A5568),
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          order['date'] ?? 'N/A', // Handle null date
                                          style: TextStyle(
                                            color: Color(0xFF718096),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      order['amount'] ?? 'N/A', // Handle null amount
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF6B46C1),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF6B46C1), size: 24),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Color(0xFFED8936); // Orange
      case 'Completed':
        return Color(0xFF48BB78); // Green
      case 'Shipped':
        return Color(0xFF4299E1); // Blue
      case 'Cancelled':
        return Color(0xFFE53E3E); // Red
      default:
        return Color(0xFF718096); // Gray
    }
  }
}
*/
