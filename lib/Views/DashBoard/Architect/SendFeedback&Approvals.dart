import 'package:flutter/material.dart';

class SendFeedbackScreen extends StatelessWidget {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback & Approvals'),
        backgroundColor: Colors.purple[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provide Feedback or Approve Tasks for Contractors:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Enter your feedback or approval',
                hintText: 'Write your detailed feedback here...',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple, width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              maxLines: 5,
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle feedback submission logic here
                if (_feedbackController.text.isNotEmpty) {
                  // Submit the feedback or approval
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Feedback Submitted'),
                      content: const Text('Your feedback has been successfully submitted.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show an error message if the feedback is empty
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please enter your feedback before submitting.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text(
                'Submit Feedback',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700], // Button color
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
