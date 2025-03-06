import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/AdminController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:intl/intl.dart';
import 'package:buildbuddy/Views/Shared//extensions.dart'; // Import shared extension

class ProjectMonitoring extends StatefulWidget {
  const ProjectMonitoring({super.key});

  @override
  State<ProjectMonitoring> createState() => _ProjectMonitoringState();
}

class _ProjectMonitoringState extends State<ProjectMonitoring> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).loadProjects();
    });
  }

  void _showProjectDialog(Project project, AdminController controller) {
    final statusOptions = ProjectStatus.values;
    String? newStatus = project.status.toString().split('.').last;
    double? newProgress = project.progress.toDouble();
    final contractorController = TextEditingController(text: project.assignedContractorId);
    final architectController = TextEditingController(text: project.assignedArchitectId);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Manage ${project.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Owner: ${project.userId}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: newStatus,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: statusOptions
                      .map((status) => DropdownMenuItem<String>(
                    value: status.toString().split('.').last,
                    child: Text(status.toString().split('.').last.capFirst),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => newStatus = value),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Progress (%)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: newProgress?.toString()),
                  onChanged: (value) => newProgress = double.tryParse(value) ?? newProgress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contractorController,
                  decoration: const InputDecoration(labelText: 'Contractor ID', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: architectController,
                  decoration: const InputDecoration(labelText: 'Architect ID', border: OutlineInputBorder()),
                ),
                if (project.createdAt != null)
                  Text('Created: ${DateFormat('yyyy-MM-dd HH:mm').format(project.createdAt!)}',
                      style: TextStyle(color: Colors.grey[600])),
                if (project.lastUpdated != null)
                  Text('Last Updated: ${DateFormat('yyyy-MM-dd HH:mm').format(project.lastUpdated!)}',
                      style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newStatus != null && newProgress != null) {
                  final updatedProject = Project(
                    id: project.id,
                    title: project.title,
                    description: project.description,
                    userId: project.userId,
                    userType: project.userType,
                    status: ProjectStatus.values.firstWhere((s) => s.toString().split('.').last == newStatus),
                    progress: newProgress!.toInt(),
                    date: project.date,
                    icon: project.icon,
                    assignedContractorId: contractorController.text.isEmpty ? null : contractorController.text,
                    assignedArchitectId: architectController.text.isEmpty ? null : architectController.text,
                    createdAt: project.createdAt,
                    lastUpdated: DateTime.now(),
                    messages: project.messages,
                    reviewed: project.reviewed,
                  );
                  controller.updateProject(updatedProject);
                  Get.snackbar('Success', 'Project updated successfully',
                      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
                } else {
                  Get.snackbar('Error', 'Status and progress are required',
                      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                controller.deleteProject(project.id);
                Get.snackbar('Success', 'Project deleted successfully',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, controller, _) {
        if (!controller.isAdmin) {
          return const Scaffold(body: Center(child: Text('Access Denied: Admins Only', style: TextStyle(color: Colors.red))));
        }
        if (controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (controller.errorMessage != null) {
          return Scaffold(body: Center(child: Text('Error: ${controller.errorMessage}', style: const TextStyle(color: Colors.red))));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Project Monitoring'),
            backgroundColor: const Color(0xFF2196F3),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.loadProjects(),
                tooltip: 'Refresh Projects',
              ),
            ],
          ),
          body: controller.projects.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No projects found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadProjects(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.projects.length,
            itemBuilder: (context, index) {
              final project = controller.projects[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(project.title, semanticsLabel: 'Project: ${project.title}'),
                  subtitle: Text(
                    'Status: ${project.status.toString().split('.').last.capFirst}, '
                        'Progress: ${project.progress}%, Owner: ${project.userId}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (project.assignedContractorId?.isNotEmpty ?? false)
                        const Icon(Icons.build, color: Colors.blue),
                      if (project.assignedArchitectId?.isNotEmpty ?? false)
                        const Icon(Icons.architecture, color: Colors.green),
                      IconButton(
                        icon: const Icon(Icons.monitor_heart, color: Color(0xFF2196F3)),
                        tooltip: 'Manage Project',
                        onPressed: () => _showProjectDialog(project, controller),
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