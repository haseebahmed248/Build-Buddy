import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/AdminController.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'package:buildbuddy/Views/Shared/extensions.dart'; // Import shared extension

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).loadUsers();
    });
  }

  Future<void> _showDeleteConfirmation(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final controller = Provider.of<AdminController>(context, listen: false);
      await controller.deleteUser(uid);
      Get.snackbar('Success', 'User deleted successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    }
  }

  Future<void> _showSuspendConfirmation(String uid, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${newStatus.capFirst}'),
        content: Text('Are you sure you want to $newStatus this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text(newStatus.capFirst, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final controller = Provider.of<AdminController>(context, listen: false);
      await controller.suspendUser(uid, newStatus);
      Get.snackbar('Success', 'User ${newStatus.capFirst} successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    }
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                items: UserRole.values
                    .map((role) => DropdownMenuItem<UserRole>(
                  value: role,
                  child: Text(role.name.capFirst),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedRole = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && _selectedRole != null) {
                final controller = Provider.of<AdminController>(context, listen: false);
                await controller.createUser(_emailController.text, _passwordController.text, _selectedRole!);
                Get.snackbar('Success', 'User created successfully',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
                _emailController.clear();
                _passwordController.clear();
                _selectedRole = null;
                Navigator.pop(context);
              } else {
                Get.snackbar('Error', 'Please fill all fields',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, controller, _) {
        if (!controller.isAdmin) {
          return const Scaffold(body: Center(child: Text('Access Denied: Admins Only', style: TextStyle(color: Colors.red))));
        }
        if (controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF2196F3))));
        }
        if (controller.errorMessage != null) {
          return Scaffold(body: Center(child: Text('Error: ${controller.errorMessage}', style: const TextStyle(color: Colors.red))));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('User Management'),
            backgroundColor: const Color(0xFF2196F3),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: _showCreateUserDialog,
                tooltip: 'Add User',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.loadUsers(),
                tooltip: 'Refresh Users',
              ),
            ],
          ),
          body: controller.users.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadUsers(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(user.email, semanticsLabel: 'User: ${user.email}'),
                  subtitle: Text('Role: ${user.role.name.capFirst}, Status: ${user.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          user.status == 'active' ? Icons.pause : Icons.play_arrow,
                          color: Colors.blue,
                        ),
                        tooltip: user.status == 'active' ? 'Suspend' : 'Activate',
                        onPressed: () => _showSuspendConfirmation(user.uid, user.status),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () => _showDeleteConfirmation(user.uid),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}