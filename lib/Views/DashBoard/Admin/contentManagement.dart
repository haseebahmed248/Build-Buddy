import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/AdminController.dart' as admin; // Use lowercase for consistency
import 'package:buildbuddy/Views/Shared/extensions.dart';

// Remove or rename the conflicting AdminController.dart if it’s not needed

class ContentManagement extends StatefulWidget {
  const ContentManagement({super.key});

  @override
  State<ContentManagement> createState() => _ContentManagementState();
}

class _ContentManagementState extends State<ContentManagement> {
  final TextEditingController _contentController = TextEditingController();
  String? _selectedContentType;
  String? _editingContentId;

  @override
  void initState() {
    super.initState();
    _selectedContentType = 'Announcement';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<admin.AdminController>(context, listen: false).loadContent();
    });
  }

  void _saveOrEditContent() {
    if (_contentController.text.isNotEmpty && _selectedContentType != null) {
      final controller = Provider.of<admin.AdminController>(context, listen: false);
      if (_editingContentId == null) {
        controller.updateContent(_selectedContentType!, _contentController.text);
      } else {
        controller.editContent(_editingContentId!, _selectedContentType!, _contentController.text);
        _editingContentId = null;
      }
      Get.snackbar('Success', _editingContentId == null ? 'Content saved successfully' : 'Content updated successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      _resetForm();
    } else {
      Get.snackbar('Error', 'Please enter content and select a type',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  void _deleteContent(String contentId) {
    Provider.of<admin.AdminController>(context, listen: false).deleteContent(contentId);
    Get.snackbar('Success', 'Content deleted successfully',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
  }

  void _startEditing(Map<String, dynamic> item) {
    setState(() {
      _contentController.text = item['content'] ?? '';
      _selectedContentType = item['type'];
      _editingContentId = item['id'];
    });
  }

  void _resetForm() {
    _contentController.clear();
    setState(() {
      _selectedContentType = 'Announcement';
      _editingContentId = null;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<admin.AdminController>(context, listen: false).loadContent();
              Get.snackbar('Info', 'Refreshing content...', snackPosition: SnackPosition.BOTTOM);
            },
            tooltip: 'Refresh Content',
          ),
        ],
      ),
      body: Consumer<admin.AdminController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage != null) {
            return Center(child: Text('Error: ${controller.errorMessage}', style: const TextStyle(color: Colors.red)));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedContentType,
                  decoration: const InputDecoration(
                    labelText: 'Content Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Announcement', 'Policy', 'Notification']
                      .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedContentType = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    hintText: 'Enter content here...',
                  ),
                  maxLines: 5,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveOrEditContent,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                  child: Text(_editingContentId == null ? 'Save Content' : 'Update Content'),
                ),
                if (_editingContentId != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _resetForm,
                    child: const Text('Cancel Edit', style: TextStyle(color: Colors.grey)),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Existing Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: controller.content.isEmpty
                      ? const Center(child: Text('No content available', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                    itemCount: controller.content.length,
                    itemBuilder: (context, index) {
                      final item = controller.content[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item['type'] ?? 'Unknown', semanticsLabel: 'Content Type: ${item['type']}'),
                          subtitle: Text(item['content'] ?? 'No content'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () => _startEditing(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () => _deleteContent(item['id']),
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
          );
        },
      ),
    );
  }
}