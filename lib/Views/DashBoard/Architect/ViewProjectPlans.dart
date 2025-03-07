import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Shared/Messages/chatscreen.dart';

class ViewProjectPlansScreen extends StatefulWidget {
  const ViewProjectPlansScreen({Key? key}) : super(key: key);

  @override
  _ViewProjectPlansScreenState createState() => _ViewProjectPlansScreenState();
}

class _ViewProjectPlansScreenState extends State<ViewProjectPlansScreen> {
  late ProjectController _projectController;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Please log in to view projects',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    // Initialize ProjectController with 'architect' userType
    _projectController = ProjectController('architect');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _projectController.loadProjects();
      if (_projectController.projects.isEmpty) {
        Get.snackbar(
          'Info',
          'No projects assigned to you yet.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        );
      }
    });
  }

  @override
  void dispose() {
    _projectController.dispose();
    super.dispose();
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return const Color(0xFF2ECC71); // Green
      case ProjectStatus.inProgress:
        return const Color(0xFF3498DB); // Blue
      case ProjectStatus.completed:
        return const Color(0xFF95A5A6); // Gray
      default:
        return const Color(0xFF95A5A6); // Gray
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Plans'),
          content: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: ['All', 'Pending', 'In Progress', 'Completed']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filterProjects();
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _filterProjects() {
    final projects = _projectController.projects;
    if (_selectedFilter == 'All' || _selectedFilter == null) {
      // No filtering, show all projects
    } else {
      final statusMap = {
        'Pending': ProjectStatus.pending,
        'In Progress': ProjectStatus.inProgress,
        'Completed': ProjectStatus.completed,
      };
      final selectedStatus = statusMap[_selectedFilter];
      if (selectedStatus != null) {
        projects.retainWhere((project) => project.status == selectedStatus);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _projectController,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3799), // Deep Blue
                  Color(0xFF4834DF), // Royal Blue
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
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.architecture_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Project Plans',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Assigned by Homeowners',
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
                                icon: const Icon(Icons.filter_list,
                                    color: Colors.white),
                                onPressed: _showFilterDialog,
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
        backgroundColor: const Color(0xFFF5F6FA),
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
                  color: const Color(0xFF4834DF).withOpacity(0.1),
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
                  color: const Color(0xFF1E3799).withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<ProjectController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                      ),
                    );
                  }
                  final filteredProjects = _selectedFilter == null ||
                      _selectedFilter == 'All'
                      ? controller.projects
                      : controller.projects.where((project) {
                    final statusStr =
                        project.status.toString().split('.').last;
                    return statusStr ==
                        _selectedFilter!.toLowerCase().replaceAll(' ', '');
                  }).toList();

                  if (filteredProjects.isEmpty) {
                    return const Center(
                      child: Text(
                        'No projects assigned to you yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _showPlanDetails(context, project),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(project.status)
                                            .withOpacity(0.1),
                                        borderRadius:
                                        BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        _getIconForProject(project),
                                        color: _getStatusColor(project.status),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            project.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF1E3799),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            project.description,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Assigned by: ${project.userId}',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                project.status)
                                                .withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            GetStringUtils(project.status
                                                .toString()
                                                .split('.')
                                                .last)
                                                .capitalize!,
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                  project.status),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.grey[400],
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _showPlanDetails(context, project),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForProject(Project project) {
    // Simple logic to assign icons based on project status or description
    if (project.status == ProjectStatus.pending) {
      return Icons.pending_actions;
    } else if (project.status == ProjectStatus.inProgress) {
      return Icons.build;
    } else {
      return Icons.check_circle;
    }
  }

  void _showPlanDetails(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(project.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForProject(project),
                  color: _getStatusColor(project.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    color: Color(0xFF1E3799),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assigned by: ${project.userId}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(project.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  GetStringUtils(project.status.toString().split('.').last).capitalize!,
                  style: TextStyle(
                    color: _getStatusColor(project.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (project.messages != null && project.messages!.isNotEmpty)
                Text(
                  'Last Message: ${project.messages!.last.content}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.to(() => ChatScreen(
                projectId: project.id,
                projectTitle: project.title,
                userType: 'architect',
              )),
              child: const Text(
                'Chat',
                style: TextStyle(color: Color(0xFF4834DF)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF4834DF)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}




/*
import 'package:flutter/material.dart';

class ViewProjectPlansScreen extends StatefulWidget {
  const ViewProjectPlansScreen({Key? key}) : super(key: key);

  @override
  _ViewProjectPlansScreenState createState() => _ViewProjectPlansScreenState();
}

class _ViewProjectPlansScreenState extends State<ViewProjectPlansScreen> {
  // Dummy data to simulate project plans
  final List<Map<String, dynamic>> _allPlans = [
    {
      'title': 'House Construction',
      'type': 'Residential',
      'description': 'Modern 3BHK house with contemporary design',
      'status': 'Available',
      'icon': Icons.home_work_rounded,
    },
    {
      'title': 'Office Building',
      'type': 'Commercial',
      'description': 'Multi-story office complex with parking',
      'status': 'Premium',
      'icon': Icons.business_rounded,
    },
    {
      'title': 'Villa Renovation',
      'type': 'Residential',
      'description': 'Luxury villa renovation with pool',
      'status': 'Available',
      'icon': Icons.villa_rounded,
    },
    {
      'title': 'Commercial Complex',
      'type': 'Mixed Use',
      'description': 'Shopping complex with office spaces',
      'status': 'Premium',
      'icon': Icons.storefront_rounded,
    },
  ];

  List<Map<String, dynamic>> _filteredPlans = [];
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _filteredPlans = List.from(_allPlans);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Color(0xFF2ECC71); // Green
      case 'Premium':
        return Color(0xFF3498DB); // Blue
      default:
        return Color(0xFF95A5A6); // Gray
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Plans'),
          content: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Type',
              border: OutlineInputBorder(),
            ),
            items: ['All', 'Residential', 'Commercial', 'Mixed Use']
                .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedFilter == 'All' || _selectedFilter == null) {
                    _filteredPlans = List.from(_allPlans);
                  } else {
                    _filteredPlans = _allPlans
                        .where((plan) => plan['type'] == _selectedFilter)
                        .toList();
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
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
                Color(0xFF1E3799), // Deep Blue
                Color(0xFF4834DF), // Royal Blue
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
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
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
                                    Icons.architecture_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Project Plans',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Browse Available Designs',
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
                              onPressed: _showFilterDialog,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _filteredPlans.length,
              itemBuilder: (context, index) {
                final plan = _filteredPlans[index];
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _showPlanDetails(context, plan),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(plan['status'])
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  plan['icon'],
                                  color: _getStatusColor(plan['status']),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1E3799),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      plan['description'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        plan['type'],
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                      color: _getStatusColor(plan['status'])
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      plan['status'],
                                      style: TextStyle(
                                        color: _getStatusColor(plan['status']),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                    onPressed: () => _showPlanDetails(context, plan),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanDetails(BuildContext context, Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(plan['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  plan['icon'],
                  color: _getStatusColor(plan['status']),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  plan['title'],
                  style: TextStyle(
                    color: Color(0xFF1E3799),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type: ${plan['type']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                plan['description'],
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(plan['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan['status'],
                  style: TextStyle(
                    color: _getStatusColor(plan['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: Color(0xFF4834DF)),
              ),
            ),
          ],
        );
      },
    );
  }
}*/
