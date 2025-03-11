import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/vendorController.dart';

class VendorInvoicesScreen extends StatelessWidget {
  const VendorInvoicesScreen({Key? key}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Color(0xFF2ECC71); // Bright Green
      case 'Pending':
        return Color(0xFFF1C40F); // Bright Yellow
      case 'Overdue':
        return Color(0xFFE74C3C); // Bright Red
      default:
        return Color(0xFF95A5A6); // Gray
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
                                    Icons.receipt_long,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Invoices',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Manage your billing',
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
                              onPressed: () {
                                // Add filter functionality (e.g., by status or date)
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
          // Invoices List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<VendorController>(
              builder: (context, controller, child) {
                if (controller.isLoading) return Center(child: CircularProgressIndicator());
                if (controller.errorMessage != null)
                  return Center(child: Text('Error: ${controller.errorMessage}'));
                return controller.invoices.isEmpty
                    ? Center(child: Text('No invoices available.'))
                    : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: controller.invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = controller.invoices[index];
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(invoice['status']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: _getStatusColor(invoice['status']),
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Invoice ${invoice['invoiceNumber'] ?? invoice['id']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF1E3799),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Date: ${invoice['date']}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Due Date: ${invoice['dueDate'] ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Terms: ${invoice['paymentTerms'] ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Description: ${invoice['description'] ?? 'No description'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${invoice['amount'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF1E3799),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(invoice['status']).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          invoice['status'],
                                          style: TextStyle(
                                            color: _getStatusColor(invoice['status']),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}