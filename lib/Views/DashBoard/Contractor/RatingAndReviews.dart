import 'package:flutter/material.dart';

class RatingsReviewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ratings & Reviews'),
        backgroundColor: Colors.amber,
      ),
      body: ListView.builder(
        itemCount: 5, // Replace with dynamic review count
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.star, color: Colors.amber),
              title: Text('Review ${index + 1}'),
              subtitle: Text('Rating: ${index + 3}/5'),
              trailing: Icon(Icons.arrow_forward, color: Colors.amber),
              onTap: () {
                // Placeholder for detailed review
              },
            ),
          );
        },
      ),
    );
  }
}
