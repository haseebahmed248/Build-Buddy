// File: lib/Views/DashBoard/Contractor/materialOrders.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/contractorController.dart';
import 'package:buildbuddy/Models/orderModel.dart';

class MaterialOrdersScreen extends StatelessWidget {
  const MaterialOrdersScreen({super.key});

  void _showCancelOrderDialog(BuildContext context, ContractorController controller, Order order) {
    if (order.status == 'Cancelled') return; // Prevent cancelling already cancelled orders

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Order #${order.id}'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
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
      body: Consumer<ContractorController>(
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
                      if (order.status != 'Cancelled') // Show cancel button only if not cancelled
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _showCancelOrderDialog(context, controller, order),
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










/*import 'package:flutter/material.dart';

class MaterialOrdersScreen extends StatefulWidget {
  const MaterialOrdersScreen({Key? key}) : super(key: key);

  @override
  _MaterialOrdersScreenState createState() => _MaterialOrdersScreenState();
}

class _MaterialOrdersScreenState extends State<MaterialOrdersScreen> {
  final List<Map<String, dynamic>> _allOrders = [
    {
      'orderId': 'Order 1',
      'status': 'Delivered',
      'date': '2024-12-01',
      'materials': 'Cement, Steel',
      'quantity': 5,
      'icon': Icons.inventory_2_rounded
    },
    {
      'orderId': 'Order 2',
      'status': 'Pending',
      'date': '2024-12-02',
      'materials': 'Bricks, Paint',
      'quantity': 3,
      'icon': Icons.pending_rounded
    },
    {
      'orderId': 'Order 3',
      'status': 'Delivered',
      'date': '2024-11-25',
      'materials': 'Tiles, Cement',
      'quantity': 7,
      'icon': Icons.check_circle_rounded
    },
    {
      'orderId': 'Order 4',
      'status': 'In Progress',
      'date': '2024-12-03',
      'materials': 'Concrete, Steel',
      'quantity': 4,
      'icon': Icons.sync_rounded
    },
    {
      'orderId': 'Order 5',
      'status': 'Delivered',
      'date': '2024-11-28',
      'materials': 'Paint, Wood, Nails',
      'quantity': 6,
      'icon': Icons.inventory_rounded
    },
  ];

  String? _selectedFilter;
  List<Map<String, dynamic>> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _filteredOrders = List.from(_allOrders);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Orders'),
          content: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: ['All', 'In Progress', 'Delivered', 'Pending']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedFilter == 'All' || _selectedFilter == null) {
                    _filteredOrders = List.from(_allOrders);
                  } else {
                    _filteredOrders = _allOrders
                        .where((order) => order['status'] == _selectedFilter)
                        .toList();
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return const Color(0xFF3498DB); // Bright Blue
      case 'Delivered':
        return const Color(0xFF2ECC71); // Bright Green
      case 'Pending':
        return const Color(0xFFF1C40F); // Bright Yellow
      default:
        return const Color(0xFF95A5A6); // Gray
    }
  }

  void _navigateToOrderCreation() async {
    // Placeholder for order creation navigation
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
              colors: [
                Color(0xFF1E3799), // Deep Blue
                Color(0xFF4834DF), // Royal Blue
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
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
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
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
                                  child: const Icon(
                                    Icons.shopping_cart_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Material Orders',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Track and Manage Your Material Orders',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_list,
                                  color: Colors.white),
                              onPressed: _showFilterDialog,
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
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4834DF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E3799).withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status'])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              order['icon'],
                              color: _getStatusColor(order['status']),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['orderId'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1E3799),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Materials: ${order['materials']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order['date'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: 1.0,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getStatusColor(order['status']),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: ${order['quantity']} units',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 80),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(order['status'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    order['status'],
                                    style: TextStyle(
                                      color: _getStatusColor(order['status']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.grey, size: 20),
                                      onPressed: () {
                                        // Edit order logic
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _filteredOrders.removeAt(index);
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToOrderCreation,
        backgroundColor: const Color(0xFF4834DF),
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/





/*
import 'package:flutter/material.dart';

class MaterialOrdersScreen extends StatefulWidget {
  const MaterialOrdersScreen({Key? key}) : super(key: key);

  @override
  _MaterialOrdersScreenState createState() => _MaterialOrdersScreenState();
}

class _MaterialOrdersScreenState extends State<MaterialOrdersScreen> {
  final List<Map<String, dynamic>> _allOrders = [
    {
      'orderId': 'Order 1',
      'status': 'Delivered',
      'date': '2024-12-01',
      'materials': 'Cement, Steel',
      'quantity': 5,
      'icon': Icons.inventory_2_rounded
    },
    {
      'orderId': 'Order 2',
      'status': 'Pending',
      'date': '2024-12-02',
      'materials': 'Bricks, Paint',
      'quantity': 3,
      'icon': Icons.pending_rounded
    },
    {
      'orderId': 'Order 3',
      'status': 'Delivered',
      'date': '2024-11-25',
      'materials': 'Tiles, Cement',
      'quantity': 7,
      'icon': Icons.check_circle_rounded
    },
    {
      'orderId': 'Order 4',
      'status': 'In Progress',
      'date': '2024-12-03',
      'materials': 'Concrete, Steel',
      'quantity': 4,
      'icon': Icons.sync_rounded
    },
    {
      'orderId': 'Order 5',
      'status': 'Delivered',
      'date': '2024-11-28',
      'materials': 'Paint, Wood, Nails',
      'quantity': 6,
      'icon': Icons.inventory_rounded
    },
  ];

  String? _selectedFilter;
  List<Map<String, dynamic>> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _filteredOrders = List.from(_allOrders);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Orders'),
          content: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: ['All', 'In Progress', 'Delivered', 'Pending']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedFilter == 'All' || _selectedFilter == null) {
                    _filteredOrders = List.from(_allOrders);
                  } else {
                    _filteredOrders = _allOrders
                        .where((order) => order['status'] == _selectedFilter)
                        .toList();
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Color(0xFF3498DB); // Bright Blue
      case 'Delivered':
        return Color(0xFF2ECC71); // Bright Green
      case 'Pending':
        return Color(0xFFF1C40F); // Bright Yellow
      default:
        return Color(0xFF95A5A6); // Gray
    }
  }

  void _navigateToOrderCreation() async {
    // Placeholder for order creation navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3799),  // Deep Blue
                Color(0xFF4834DF),  // Royal Blue
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // Main AppBar Content
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.shopping_cart_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Material Orders',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Track and Manage Your Material Orders',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.filter_list, color: Colors.white),
                              onPressed: _showFilterDialog,
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
      backgroundColor: Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4834DF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E3799).withOpacity(0.1),
              ),
            ),
          ),

          // Orders List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              order['icon'],
                              color: _getStatusColor(order['status']),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['orderId'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1E3799),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Materials: ${order['materials']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  order['date'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: 1.0,  // Always full since this isn't a progress-based metric
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getStatusColor(order['status']),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Quantity: ${order['quantity']} units',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order['status']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order['status'],
                                  style: TextStyle(
                                    color: _getStatusColor(order['status']),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.grey),
                                onPressed: () {
                                  // Edit order logic
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _filteredOrders.removeAt(index);
                                  });
                                },
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToOrderCreation,
        backgroundColor: Color(0xFF4834DF),
        child: Icon(Icons.add),
      ),
    );
  }
}*/
