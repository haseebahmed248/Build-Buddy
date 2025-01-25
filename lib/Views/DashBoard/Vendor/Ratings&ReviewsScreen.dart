import 'package:flutter/material.dart';

class ReviewVendorTasksScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tasks = [
    {
      'id': 'TSK001',
      'title': 'Review Vendor Performance',
      'description': 'Check if the vendor has delivered the materials on time and met the quality standards.',
      'icon': Icons.assignment_outlined,
      'status': 'Completed',
      'date': '2024-11-15',
      'rating': 4
    },
    {
      'id': 'TSK002',
      'title': 'Quality Assessment',
      'description': 'Evaluate the quality of delivered goods against specified requirements.',
      'icon': Icons.high_quality_rounded,
      'status': 'Pending',
      'date': '2024-11-10',
      'rating': 0
    },
    {
      'id': 'TSK003',
      'title': 'Delivery Timeline Review',
      'description': 'Assess if deliveries are being made according to agreed schedule.',
      'icon': Icons.timelapse_rounded,
      'status': 'Overdue',
      'date': '2024-10-25',
      'rating': 0
    },
    {
      'id': 'TSK004',
      'title': 'Communication Assessment',
      'description': 'Review vendor responsiveness and communication effectiveness.',
      'icon': Icons.chat_rounded,
      'status': 'Completed',
      'date': '2024-11-01',
      'rating': 5
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
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
                                    Icons.assignment_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vendor Reviews',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Manage vendor performance',
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
                                // Add filter functionality
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

          // Tasks List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
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
                              color: _getStatusColor(task['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              task['icon'],
                              color: _getStatusColor(task['status']),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1E3799),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  task['description'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  task['date'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
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
                                  color: _getStatusColor(task['status']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  task['status'],
                                  style: TextStyle(
                                    color: _getStatusColor(task['status']),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < (task['rating'] ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: Color(0xFFF1C40F),
                                  );
                                }),
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
        onPressed: () {
          // Add new review task functionality
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF4834DF),
      ),
    );
  }
}