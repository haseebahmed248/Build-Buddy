import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/AdminController.dart';

//import '../../../Controllers/adminController.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final TextEditingController _ticketController = TextEditingController();
  String? _selectedTicketId;
  String? _selectedTicketStatus;

  @override
  void initState() {
    super.initState();
    _selectedTicketStatus = 'open';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).loadSupportTickets();
    });
  }

  void _updateTicket() {
    if (_ticketController.text.isNotEmpty && _selectedTicketStatus != null) {
      final controller = Provider.of<AdminController>(context, listen: false);
      if (_selectedTicketId == null) {
        Get.snackbar('Error', 'Select a ticket to update or clear form to create a new one',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        return;
      }
      controller.updateSupportTicket(_selectedTicketId!, _selectedTicketStatus!).then((_) {
        Get.snackbar('Success', 'Support ticket updated successfully',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
        _resetForm();
      }).catchError((e) {
        Get.snackbar('Error', 'Failed to update ticket: $e',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      });
    } else {
      Get.snackbar('Error', 'Please enter ticket details and select a status',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  void _startEditing(Map<String, dynamic> ticket) {
    setState(() {
      _ticketController.text = ticket['ticket'] ?? '';
      _selectedTicketStatus = ticket['status'];
      _selectedTicketId = ticket['id'];
    });
  }

  void _resetForm() {
    setState(() {
      _ticketController.clear();
      _selectedTicketStatus = 'open';
      _selectedTicketId = null;
    });
  }

  @override
  void dispose() {
    _ticketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, controller, _) {
        if (!controller.isAdmin) {
          return const Scaffold(
              body: Center(child: Text('Access Denied: Admins Only', style: TextStyle(color: Colors.red))));
        }
        if (controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF2196F3))));
        }
        if (controller.errorMessage != null) {
          return Scaffold(
              body: Center(child: Text('Error: ${controller.errorMessage}', style: const TextStyle(color: Colors.red))));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Support'),
            backgroundColor: const Color(0xFF2196F3),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.loadSupportTickets(),
                tooltip: 'Refresh Tickets',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedTicketStatus,
                  decoration: const InputDecoration(labelText: 'Ticket Status', border: OutlineInputBorder()),
                  items: ['open', 'inProgress', 'resolved']
                      .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedTicketStatus = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ticketController,
                  decoration: const InputDecoration(
                    labelText: 'Support Ticket',
                    border: OutlineInputBorder(),
                    hintText: 'Enter support issue or query...',
                  ),
                  maxLines: 5,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _updateTicket,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                      child: Text(_selectedTicketId == null ? 'Update Ticket (Select One)' : 'Update Ticket'),
                    ),
                    if (_selectedTicketId != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _resetForm,
                        child: const Text('Cancel Edit', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Existing Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: controller.supportTickets.isEmpty
                      ? const Center(child: Text('No tickets available', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                    itemCount: controller.supportTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = controller.supportTickets[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(ticket['ticket'] ?? 'Untitled Ticket',
                              semanticsLabel: 'Ticket: ${ticket['ticket']}'),
                          subtitle: Text('Status: ${ticket['status'] ?? 'Unknown'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () => _startEditing(ticket),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () {
                                  // Add delete functionality if implemented in AdminController
                                  Get.snackbar('Info', 'Delete functionality to be implemented',
                                      snackPosition: SnackPosition.BOTTOM);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}