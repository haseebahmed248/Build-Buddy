import 'package:flutter/material.dart';

class NotificationsDashboard extends StatelessWidget {
  const NotificationsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF90CAF9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 8, // Placeholder for the number of notifications
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: const Icon(
                  Icons.notifications,
                  color: Color(0xFF90CAF9),
                ),
                title: Text(
                  'Notification #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Tap to view details.',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  // Navigate to the details screen
                  _navigateToNotificationDetail(context, index);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToNotificationDetail(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(notificationIndex: index),
      ),
    );
  }
}


class NotificationDetailScreen extends StatelessWidget {
  final int notificationIndex;

  const NotificationDetailScreen({Key? key, required this.notificationIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data for the notification
    final String timestamp = "2024-12-06 14:30:00"; // Placeholder timestamp
    final String description = "This is a detailed notification description that explains the event. You can replace this with the actual notification details based on your app's context.";
    final String notificationType = "New Project Update"; // Example of notification type

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        backgroundColor: const Color(0xFF90CAF9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification #${notificationIndex + 1}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Type: $notificationType',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Timestamp: $timestamp',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Description:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Notifications'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: const Color(0xFF90CAF9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

