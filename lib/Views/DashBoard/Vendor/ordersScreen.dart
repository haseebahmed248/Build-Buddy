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
            onPressed: () async {
              await controller.updateOrderStatus(order.id, status);
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