import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/AdminController.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:buildbuddy/Models/contractorModel.dart';
import 'package:intl/intl.dart';
import 'package:buildbuddy/Views/Shared/extensions.dart';

//import '../../../Controllers/adminController.dart'; // Import shared extension

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
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
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${controller.errorMessage}', style: const TextStyle(color: Colors.red, fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadUsers(),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
            backgroundColor: const Color(0xFF2196F3),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  controller.loadUsers();
                  controller.loadProjects();
                  controller.loadContractors();
                  Get.snackbar('Info', 'Refreshing reports...', snackPosition: SnackPosition.BOTTOM);
                },
                tooltip: 'Refresh Reports',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportSection('User Statistics', _getUserStatistics(controller.users), 'Breakdown by Role'),
                  const SizedBox(height: 16),
                  _buildReportSection('Project Status', _getProjectStatus(controller.projects), 'Current Project Distribution'),
                  const SizedBox(height: 16),
                  _buildReportSection('Contractor Performance', '${_getContractorPerformance(controller.contractors).toStringAsFixed(1)}/5', 'Average Rating'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _generateDetailedReport(controller),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                    child: const Text('Generate Detailed Report'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportSection(String title, String value, String subtitle) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
            Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  String _getUserStatistics(List<UserData> users) {
    final roleCounts = <String, int>{};
    for (var user in users) {
      roleCounts[user.role.name] = (roleCounts[user.role.name] ?? 0) + 1;
    }
    return roleCounts.entries.map((e) => '${e.key.capFirst}: ${e.value}').join(', ');
  }

  String _getProjectStatus(List<Project> projects) {
    final statusCounts = <String, int>{};
    for (var project in projects) {
      statusCounts[project.status.toString().split('.').last] = (statusCounts[project.status.toString().split('.').last] ?? 0) + 1;
    }
    return statusCounts.entries.map((e) => '${e.key.capFirst}: ${e.value}').join(', ');
  }

  double _getContractorPerformance(List<Contractor> contractors) {
    if (contractors.isEmpty) return 0.0;
    double totalRating = 0.0;
    int count = 0;
    for (var contractor in contractors) {
      if (contractor.rating != null && contractor.rating! > 0) {
        totalRating += contractor.rating!;
        count++;
      }
    }
    return count > 0 ? totalRating / count : 0.0;
  }

  void _generateDetailedReport(AdminController controller) {
    final now = DateTime.now();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final report = '''
Build Buddy Admin Report - Generated on $timestamp

User Statistics:
${_getUserStatistics(controller.users)}

Project Status:
${_getProjectStatus(controller.projects)}

Contractor Performance:
Average Rating: ${_getContractorPerformance(controller.contractors).toStringAsFixed(1)}/5

Note: Export to PDF/CSV or email sharing can be added.
    ''';

    Get.snackbar('Report Generated', 'Detailed report ready:\n$report',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        maxWidth: MediaQuery.of(context).size.width * 0.9);
  }
}