import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buildbuddyfyp/Views/DashBoard/HomeOwner/payment_detail.dart';

class PaymentsDashboard extends StatefulWidget {
  const PaymentsDashboard({Key? key}) : super(key: key);

  @override
  _PaymentsDashboardState createState() => _PaymentsDashboardState();
}

class _PaymentsDashboardState extends State<PaymentsDashboard> {
  final List<Map<String, dynamic>> _allPayments = [
    {
      'id': 'INV001',
      'title': 'Kitchen Renovation Payment',
      'description': 'First installment for kitchen remodeling',
      'icon': Icons.home_repair_service_rounded,
      'status': 'Partially Paid',
      'progress': 50,
      'date': '2024-11-15',
      'amount': 5000.0
    },
    {
      'id': 'INV002',
      'title': 'Living Room Remodeling Payment',
      'description': 'Final payment for interior redesign',
      'icon': Icons.weekend_rounded,
      'status': 'Paid',
      'progress': 100,
      'date': '2024-11-10',
      'amount': 7500.0
    },
    {
      'id': 'INV003',
      'title': 'Garage Upgrade Payment',
      'description': 'Initial deposit for workspace improvements',
      'icon': Icons.garage_rounded,
      'status': 'Pending',
      'progress': 0,
      'date': '2024-11-05',
      'amount': 3000.0
    },
  ];

  String? _selectedFilter;
  List<Map<String, dynamic>> _filteredPayments = [];

  @override
  void initState() {
    super.initState();
    _filteredPayments = List.from(_allPayments);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Payments'),
          content: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: ['All', 'Paid', 'Partially Paid', 'Pending']
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
                    _filteredPayments = List.from(_allPayments);
                  } else {
                    _filteredPayments = _allPayments
                        .where((payment) => payment['status'] == _selectedFilter)
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
      case 'Partially Paid':
        return Color(0xFF3498DB);
      case 'Paid':
        return Color(0xFF2ECC71);
      case 'Pending':
        return Color(0xFFF1C40F);
      default:
        return Color(0xFF95A5A6);
    }
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
                Color(0xFF1E3799),
                Color(0xFF4834DF),
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
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.payment_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payments & Invoices',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Manage Your Payments',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _filteredPayments.length,
              itemBuilder: (context, index) {
                final payment = _filteredPayments[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            InvoiceDetailsScreen(payment: payment),
                      ),
                    );
                  },
                  child: AnimatedContainer(
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
                                color: _getStatusColor(payment['status'])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                payment['icon'],
                                color: _getStatusColor(payment['status']),
                                size: 24,
                              ),
                            ),
                            // ... (rest of the payment card code)
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
