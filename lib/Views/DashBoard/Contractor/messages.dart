import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: 5, // Replace with dynamic message count
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text('User ${index + 1}'),
              subtitle: Text('Last message preview...'),
              onTap: () {
                // Placeholder for opening chat
              },
            ),
          );
        },
      ),
    );
  }
}
