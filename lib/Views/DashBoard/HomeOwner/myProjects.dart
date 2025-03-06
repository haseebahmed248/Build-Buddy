/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure you have this for date formatting

class MyProjectsDashboard extends StatefulWidget {
  const MyProjectsDashboard({Key? key}) : super(key: key);

  @override
  _MyProjectsDashboardState createState() => _MyProjectsDashboardState();
}

class _MyProjectsDashboardState extends State<MyProjectsDashboard> {
  final List<Map<String, dynamic>> _allProjects = [
    {
      'id': 'PRJ001',
      'title': 'Kitchen Renovation',
      'description': 'Updating kitchen layout and appliances',
      'icon': Icons.home_repair_service_rounded,
      'status': 'In Progress',
      'progress': 50,
      'date': '2024-11-15'
    },
    {
      'id': 'PRJ002',
      'title': 'Living Room Remodeling',
      'description': 'Complete interior redesign',
      'icon': Icons.weekend_rounded,
      'status': 'Completed',
      'progress': 100,
      'date': '2024-11-10'
    },
    {
      'id': 'PRJ003',
      'title': 'Garage Upgrade',
      'description': 'Storage and workspace improvements',
      'icon': Icons.garage_rounded,
      'status': 'Pending',
      'progress': 0,
      'date': '2024-11-05'
    },
  ];

  String? _selectedFilter;
  List<Map<String, dynamic>> _filteredProjects = [];

  @override
  void initState() {
    super.initState();
    _filteredProjects = List.from(_allProjects);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Projects'),
          content: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: ['All', 'In Progress', 'Completed', 'Pending']
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
                  if (_selectedFilter == 'All' || _selectedFilter == null) {
                    _filteredProjects = List.from(_allProjects);
                  } else {
                    _filteredProjects = _allProjects
                        .where((project) => project['status'] == _selectedFilter)
                        .toList();
                  }
                });
                Navigator.pop(context); // Close the dialog
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Color(0xFF3498DB); // Bright Blue
      case 'Completed':
        return Color(0xFF2ECC71); // Bright Green
      case 'Pending':
        return Color(0xFFF1C40F); // Bright Yellow
      default:
        return Color(0xFF95A5A6); // Gray
    }
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
                Color(0xFF1E3799),  // Deep Blue
                Color(0xFF4834DF),  // Royal Blue
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
                      // Back Button
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // Main AppBar Content
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
                                    Icons.design_services_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'My Projects',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Manage Your Work',
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

          // Projects List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _filteredProjects.length,
              itemBuilder: (context, index) {
                final project = _filteredProjects[index];
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(project['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              project['icon'],
                              color: _getStatusColor(project['status']),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1E3799),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  project['description'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  project['date'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: project['progress'] / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getStatusColor(project['status']),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${project['progress']}% Completed',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
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
                                  color: _getStatusColor(project['status']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  project['status'],
                                  style: TextStyle(
                                    color: _getStatusColor(project['status']),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.grey),
                                onPressed: () {
                                  // Edit project logic
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _allProjects.removeAt(index);
                                    _filteredProjects.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToProjectCreation,
        backgroundColor: Color(0xFF4834DF),
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToProjectCreation() async {
    final newProject = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectCreationScreen(),
      ),
    );

    if (newProject != null) {
      setState(() {
        _allProjects.add(newProject);
        _filteredProjects.add(newProject);
      });
    }
  }
}

class ProjectCreationScreen extends StatefulWidget {
  const ProjectCreationScreen({Key? key}) : super(key: key);

  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedStatus = 'In Progress';

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
                Color(0xFF1E3799),  // Deep Blue
                Color(0xFF4834DF),  // Royal Blue
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
                      // Back Button
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // Main AppBar Content
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.add_box_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Project',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Add New Project Details',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
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

          // Form Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Project Title',
                          prefixIcon: Icon(
                            Icons.title,
                            color: Color(0xFF4834DF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF4834DF),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Project Description',
                          prefixIcon: Icon(
                            Icons.description,
                            color: Color(0xFF4834DF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF4834DF),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Project Status',
                          prefixIcon: Icon(
                            Icons.info_outline,
                            color: Color(0xFF4834DF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF4834DF),
                              width: 2,
                            ),
                          ),
                        ),
                        items: ['In Progress', 'Completed', 'Pending']
                            .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_titleController.text.isNotEmpty &&
                              _descriptionController.text.isNotEmpty) {
                            Navigator.pop(context, {
                              'id': 'PRJ${DateTime.now().millisecondsSinceEpoch}',
                              'title': _titleController.text,
                              'description': _descriptionController.text,
                              'icon': Icons.design_services_rounded,
                              'status': _selectedStatus,
                              'progress': _selectedStatus == 'Completed' ? 100 : 0,
                              'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            });
                          } else {
                            // Show error or validation message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4834DF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Create Project',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/















/////////////////////////////////////
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buildbuddy/Views/Shared/Messages/chatscreen.dart';
import 'package:buildbuddy/Views/DashBoard/HomeOwner/findProfessionals.dart';

class MyProjectsDashboard extends StatefulWidget {
  final String userType;
  final String? selectedProfessionalId;
  final String? selectedProfessionalRole;

  const MyProjectsDashboard({
    required this.userType,
    this.selectedProfessionalId,
    this.selectedProfessionalRole,
    Key? key,
  }) : assert(userType == 'homeowner', 'This dashboard is for homeowners only'),
        super(key: key);

  @override
  _MyProjectsDashboardState createState() => _MyProjectsDashboardState();
}

class _MyProjectsDashboardState extends State<MyProjectsDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in, cannot load projects");
        Get.snackbar('Error', 'Please log in to view projects',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        return;
      }

      print("Authenticated user UID: ${user.uid}, userType=${widget.userType}");
      final controller = Provider.of<ProjectController>(context, listen: false);
      print("Current controller userType: ${controller.userType}");
      if (controller.userType != 'homeowner') {
        print("Updating ProjectController userType to homeowner");
        controller.updateUserType('homeowner');
      }
      print("Loading projects for homeowner with UID: ${user.uid}");
      await controller.loadProjects();
      print("Projects loaded: ${controller.projects.length} projects");
      if (controller.projects.isEmpty) {
        print("No projects loaded. Check if userId in database matches UID: ${user.uid}");
        Get.snackbar(
          'Info',
          'No projects found for UID: ${user.uid}. Ensure the userId in the database matches your UID or create a new project.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        );
      }

      if (widget.selectedProfessionalId != null) {
        _navigateToCreateProjectWithProfessional();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("UserType in Dashboard: ${widget.userType}");
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'My Projects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Create New Project',
            onPressed: _navigateToCreateProject,
          ),
          IconButton(
            icon: const Icon(Icons.person_search, color: Colors.white),
            tooltip: 'Find Professionals',
            onPressed: () => Get.to(() => const FindProfessionalsDashboard()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final controller = Provider.of<ProjectController>(context, listen: false);
          print("Refreshing projects for userType: ${widget.userType}");
          await controller.loadProjects();
          print("Projects after refresh: ${controller.projects.length} projects");
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ProjectController>(
            builder: (context, controller, _) {
              print("Consumer builder triggered: Rendering projects: ${controller.projects.length} projects found");
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                  ),
                );
              }
              controller.projects.forEach((project) {
                print("Project ID: ${project.id}, userId: ${project.userId}, userType: ${project.userType}");
              });
              if (controller.projects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home_work_outlined, color: Colors.grey, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'No projects found. Create one to get started!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.projects.length,
                itemBuilder: (context, index) {
                  final project = controller.projects[index];
                  return _buildProjectCard(project, context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      CustomStringExtension(project.status.toString().split('.').last).capitalizeFirst,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (project.assignedContractorId != null && project.assignedContractorId!.isNotEmpty)
                _buildProfessionalInfo(Icons.engineering, 'Contractor', project.assignedContractorId!),
              if (project.assignedArchitectId != null && project.assignedArchitectId!.isNotEmpty)
                _buildProfessionalInfo(Icons.architecture, 'Architect', project.assignedArchitectId!),
              if (project.assignedContractorId == null && project.assignedArchitectId == null)
                Text(
                  'No professionals assigned yet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              if (project.messages != null && project.messages!.isNotEmpty)
                Text(
                  'Last Message: ${project.messages!.last.content}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat, color: Color(0xFF2196F3)),
                    tooltip: 'Chat',
                    onPressed: () => _navigateToChat(project.id, project.title),
                  ),
                  if (widget.userType == 'homeowner')
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Color(0xFF2196F3)),
                      tooltip: 'Assign Professional',
                      onPressed: () => _assignProject(project.id),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                    tooltip: 'Edit',
                    onPressed: () => _navigateToEditProject(project),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () => _showDeleteConfirmation(project.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalInfo(IconData icon, String title, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$title: $id',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return Colors.orange.withOpacity(0.8);
      case ProjectStatus.inProgress:
        return Colors.blue.withOpacity(0.8);
      case ProjectStatus.completed:
        return Colors.green.withOpacity(0.8);
      default:
        return Colors.grey.withOpacity(0.5);
    }
  }

  Future<void> _navigateToCreateProject() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Please log in to create a project',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final newProject = await Get.to<Project>(() => ProjectCreationScreen(
      userType: widget.userType,
      userId: user.uid,
    ));

    if (newProject != null) {
      print('New project created: ${newProject.id}, title: ${newProject.title}');
      await Provider.of<ProjectController>(context, listen: false).addProject(newProject);
      // Force UI update by notifying listeners
      Provider.of<ProjectController>(context, listen: false).notifyListeners();
    }
  }

  Future<void> _navigateToCreateProjectWithProfessional() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Please log in to create a project',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final newProject = await Get.to<Project>(() => ProjectCreationScreen(
      userType: widget.userType,
      userId: user.uid,
      preFilledContractorId: widget.selectedProfessionalRole == 'Contractor'
          ? widget.selectedProfessionalId
          : null,
      preFilledArchitectId: widget.selectedProfessionalRole == 'Architect'
          ? widget.selectedProfessionalId
          : null,
    ));

    if (newProject != null) {
      print('New project created with professional: ${newProject.id}, title: ${newProject.title}');
      await Provider.of<ProjectController>(context, listen: false).addProject(newProject);
      if (widget.selectedProfessionalRole == 'Contractor' && widget.selectedProfessionalId != null) {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(newProject.id, widget.selectedProfessionalId, null);
      } else if (widget.selectedProfessionalRole == 'Architect' && widget.selectedProfessionalId != null) {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(newProject.id, null, widget.selectedProfessionalId);
      }
      Get.snackbar('Success', 'Project created with professional assigned',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      // Force UI update by notifying listeners
      Provider.of<ProjectController>(context, listen: false).notifyListeners();
    }
  }

  Future<void> _navigateToEditProject(Project project) async {
    final updatedProject = await Get.to<Project>(() => ProjectCreationScreen(
      userType: widget.userType,
      userId: project.userId,
      projectToEdit: project,
    ));

    if (updatedProject != null) {
      await Provider.of<ProjectController>(context, listen: false).updateProject(updatedProject);
      if (updatedProject.assignedContractorId != null && updatedProject.assignedContractorId!.isNotEmpty) {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(updatedProject.id, updatedProject.assignedContractorId, null);
      } else if (updatedProject.assignedArchitectId != null && updatedProject.assignedArchitectId!.isNotEmpty) {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(updatedProject.id, null, updatedProject.assignedArchitectId);
      }
      Get.snackbar('Success', 'Project updated successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      // Force UI update by notifying listeners
      Provider.of<ProjectController>(context, listen: false).notifyListeners();
    }
  }

  Future<void> _deleteProject(String projectId) async {
    await Provider.of<ProjectController>(context, listen: false).deleteProject(projectId);
    Get.snackbar('Success', 'Project deleted successfully',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
  }

  Future<void> _assignProject(String projectId) async {
    final result = await Get.to<Map<String, dynamic>>(() => const FindProfessionalsDashboard());
    if (result != null && result.containsKey('professionalId') && result.containsKey('professionalRole')) {
      final professionalId = result['professionalId'] as String;
      final professionalRole = result['professionalRole'] as String;
      if (professionalRole == 'Contractor') {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(projectId, professionalId, null);
      } else if (professionalRole == 'Architect') {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(projectId, null, professionalId);
      }
      Get.snackbar('Success', 'Professional assigned successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      await Provider.of<ProjectController>(context, listen: false).loadProjects();
    }
  }

  Future<void> _navigateToChat(String projectId, String projectTitle) async {
    await Get.to(() => ChatScreen(
      projectId: projectId,
      projectTitle: projectTitle,
    ));
  }

  Future<void> _showDeleteConfirmation(String projectId) async {
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this project?'),
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
    ) ??
        false;

    if (confirm) {
      _deleteProject(projectId);
    }
  }
}

class ProjectListItem extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAssign;
  final VoidCallback? onChat;

  const ProjectListItem({
    required this.project,
    required this.onEdit,
    required this.onDelete,
    this.onAssign,
    this.onChat,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      CustomStringExtension(project.status.toString().split('.').last).capitalizeFirst,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (project.assignedContractorId != null && project.assignedContractorId!.isNotEmpty)
                _buildProfessionalInfo(Icons.engineering, 'Contractor', project.assignedContractorId!),
              if (project.assignedArchitectId != null && project.assignedArchitectId!.isNotEmpty)
                _buildProfessionalInfo(Icons.architecture, 'Architect', project.assignedArchitectId!),
              if (project.messages != null && project.messages!.isNotEmpty)
                Text(
                  'Last Message: ${project.messages!.last.content}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onChat != null)
                    IconButton(
                      icon: const Icon(Icons.chat, color: Color(0xFF2196F3)),
                      tooltip: 'Chat',
                      onPressed: onChat,
                    ),
                  if (onAssign != null)
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Color(0xFF2196F3)),
                      tooltip: 'Assign Professional',
                      onPressed: onAssign,
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                    tooltip: 'Edit',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalInfo(IconData icon, String title, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$title: $id',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return Colors.orange.withOpacity(0.8);
      case ProjectStatus.inProgress:
        return Colors.blue.withOpacity(0.8);
      case ProjectStatus.completed:
        return Colors.green.withOpacity(0.8);
      default:
        return Colors.grey.withOpacity(0.5);
    }
  }
}

class ProjectCreationScreen extends StatefulWidget {
  final String userType;
  final String userId;
  final Project? projectToEdit;
  final String? preFilledContractorId;
  final String? preFilledArchitectId;

  const ProjectCreationScreen({
    required this.userType,
    required this.userId,
    this.projectToEdit,
    this.preFilledContractorId,
    this.preFilledArchitectId,
    Key? key,
  }) : super(key: key);

  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contractorIdController;
  late TextEditingController _architectIdController;
  late ProjectStatus _status;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.projectToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.projectToEdit?.description ?? '');
    _contractorIdController = TextEditingController(
        text: widget.projectToEdit?.assignedContractorId ?? widget.preFilledContractorId ?? '');
    _architectIdController = TextEditingController(
        text: widget.projectToEdit?.assignedArchitectId ?? widget.preFilledArchitectId ?? '');
    _status = widget.projectToEdit?.status ?? ProjectStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contractorIdController.dispose();
    _architectIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectToEdit != null ? 'Edit Project' : 'Create Project'),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Project Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) =>
                          value?.isEmpty ?? true ? 'Project title is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 3,
                          validator: (value) =>
                          value?.isEmpty ?? true ? 'Description is required' : null,
                        ),
                        const SizedBox(height: 16),
                        if (widget.userType == 'homeowner') ...[
                          TextFormField(
                            controller: _contractorIdController,
                            decoration: InputDecoration(
                              labelText: 'Contractor ID (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Enter contractor ID to assign',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _architectIdController,
                            decoration: InputDecoration(
                              labelText: 'Architect ID (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Enter architect ID to assign',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        DropdownButtonFormField<ProjectStatus>(
                          value: _status,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: ProjectStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(CustomStringExtension(status.toString().split('.').last).capitalizeFirst),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _status = value!),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveProject,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            widget.projectToEdit != null ? 'Update Project' : 'Create Project',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.projectToEdit != null && widget.projectToEdit!.createdAt == null) {
      print("Error: Project ${widget.projectToEdit!.id} has no createdAt timestamp. Using current time as fallback.");
      Get.snackbar(
        'Warning',
        'Project creation timestamp is missing. Contact support.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }

    final project = Project(
      id: widget.projectToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      userId: widget.userId,
      userType: widget.userType,
      status: _status,
      progress: widget.projectToEdit?.progress ?? 0,
      date: DateTime.now(),
      icon: 'work',
      assignedContractorId: _contractorIdController.text.isNotEmpty ? _contractorIdController.text : null,
      assignedArchitectId: _architectIdController.text.isNotEmpty ? _architectIdController.text : null,
      messages: widget.projectToEdit?.messages ?? [],
      reviewed: widget.projectToEdit?.reviewed ?? false,
      createdAt: widget.projectToEdit?.createdAt ?? DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    final controller = Provider.of<ProjectController>(context, listen: false);
    print("Saving project: ID=${project.id}, Title=${project.title}, userId=${project.userId}, userType=${project.userType}");
    Get.back(result: project);

    if (_contractorIdController.text.isNotEmpty) {
      await controller.assignProject(project.id, _contractorIdController.text, null);
    } else if (_architectIdController.text.isNotEmpty) {
      await controller.assignProject(project.id, null, _architectIdController.text);
    }
    Get.snackbar('Success', widget.projectToEdit != null ? 'Project updated successfully' : 'Project created successfully',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
  }
}

extension CustomStringExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}






/////////////////////////////////////
/*
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:buildbuddy/Views/DashBoard/HomeOwner/findProfessionals.dart';

class MyProjectsDashboard extends StatefulWidget {
  final String userType;
  final String? selectedProfessionalId;
  final String? selectedProfessionalRole;

  const MyProjectsDashboard({
    required this.userType,
    this.selectedProfessionalId,
    this.selectedProfessionalRole,
    Key? key,
  }) : assert(userType == 'homeowner', 'This dashboard is for homeowners only'),
        super(key: key);

  @override
  _MyProjectsDashboardState createState() => _MyProjectsDashboardState();
}

class _MyProjectsDashboardState extends State<MyProjectsDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in, cannot load projects");
        Get.snackbar('Error', 'Please log in to view projects',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        return;
      }

      print("Authenticated user UID: ${user.uid}, userType=${widget.userType}");
      final controller = Provider.of<ProjectController>(context, listen: false);
      print("Current controller userType: ${controller.userType}");
      if (controller.userType != 'homeowner') {
        print("Updating ProjectController userType to homeowner");
        controller.updateUserType('homeowner');
      }
      print("Loading projects for homeowner with UID: ${user.uid}");
      await controller.loadProjects();
      print("Projects loaded: ${controller.projects.length} projects");
      if (controller.projects.isEmpty) {
        print("No projects loaded. Check if userId in database matches UID: ${user.uid}");
        Get.snackbar(
          'Info',
          'No projects found for UID: ${user.uid}. Ensure the userId in the database matches your UID or create a new project.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        );
      }

      if (widget.selectedProfessionalId != null) {
        _navigateToCreateProjectWithProfessional();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("UserType in Dashboard: ${widget.userType}");
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'My Projects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Create New Project',
            onPressed: _navigateToCreateProject,
          ),
          IconButton(
            icon: const Icon(Icons.person_search, color: Colors.white),
            tooltip: 'Find Professionals',
            onPressed: () => Get.to(() => const FindProfessionalsDashboard()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final controller = Provider.of<ProjectController>(context, listen: false);
          print("Refreshing projects for userType: ${widget.userType}");
          await controller.loadProjects();
          print("Projects after refresh: ${controller.projects.length} projects");
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ProjectController>(
            builder: (context, controller, _) {
              print("Consumer builder triggered: Rendering projects: ${controller.projects.length} projects found");
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                  ),
                );
              }
              controller.projects.forEach((project) {
                print("Project ID: ${project.id}, userId: ${project.userId}, userType: ${project.userType}");
              });
              if (controller.projects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home_work_outlined, color: Colors.grey, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'No projects found. Create one to get started!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.projects.length,
                itemBuilder: (context, index) {
                  final project = controller.projects[index];
                  return _buildProjectCard(project, context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      CustomStringExtension(project.status.toString().split('.').last).capitalizeFirst,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (project.assignedContractorId != null && project.assignedContractorId!.isNotEmpty)
                _buildProfessionalInfo(Icons.engineering, 'Contractor', project.assignedContractorId!),
              if (project.assignedArchitectId != null && project.assignedArchitectId!.isNotEmpty)
                _buildProfessionalInfo(Icons.architecture, 'Architect', project.assignedArchitectId!),
              if (project.assignedContractorId == null && project.assignedArchitectId == null)
                Text(
                  'No professionals assigned yet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              if (project.messages != null && project.messages!.isNotEmpty)
                Text(
                  'Last Message: ${project.messages!.last.content}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat, color: Color(0xFF2196F3)),
                    tooltip: 'Chat',
                    onPressed: () => _navigateToChat(project.id, project.title),
                  ),
                  if (widget.userType == 'homeowner')
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Color(0xFF2196F3)),
                      tooltip: 'Assign Professional',
                      onPressed: () => _assignProject(project.id),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                    tooltip: 'Edit',
                    onPressed: () => _navigateToEditProject(project),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () => _showDeleteConfirmation(project.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalInfo(IconData icon, String title, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$title: $id',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return Colors.orange.withOpacity(0.8);
      case ProjectStatus.inProgress:
        return Colors.blue.withOpacity(0.8);
      case ProjectStatus.completed:
        return Colors.green.withOpacity(0.8);
      default:
        return Colors.grey.withOpacity(0.5);
    }
  }

  Future<void> _navigateToCreateProject() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Please log in to create a project',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final newProject = await Get.to<Project>(() => ProjectCreationScreen(
      userType: widget.userType,
      userId: user.uid,
    ));

    if (newProject != null) {
      print('New project created: ${newProject.id}, title: ${newProject.title}');
      await Provider.of<ProjectController>(context, listen: false).addProject(newProject);
      // Force UI update by notifying listeners
      Provider.of<ProjectController>(context, listen: false).notifyListeners();
    }
  }

  Future<void> _navigateToCreateProjectWithProfessional() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Please log in to create a project',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final newProject = await Get.to<Project>(() => ProjectCreationScreen(
      userType: widget.userType,
      userId: user.uid,
      preFilledContractorId: widget.selectedProfessionalRole == 'Contractor'
          ? widget.selectedProfessionalId
          : null,
      preFilledArchitectId: widget.selectedProfessionalRole == 'Architect'
          ? widget.selectedProfessionalId
          : null,
    ));

    if (newProject != null) {
      print('New project created with professional: ${newProject.id}, title: ${newProject.title}');
      await Provider.of<ProjectController>(context, listen: false).addProject(newProject);
      if (widget.selectedProfessionalRole == 'Contractor' && widget.selectedProfessionalId != null) {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(newProject.id, widget.selectedProfessionalId, null);
      } else if (widget.selectedProfessionalRole == 'Architect' && widget.selectedProfessionalId != null) {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(newProject.id, null, widget.selectedProfessionalId);
      }
      Get.snackbar('Success', 'Project created with professional assigned',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      // Force UI update by notifying listeners
      Provider.of<ProjectController>(context, listen: false).notifyListeners();
    }
  }

  Future<void> _navigateToEditProject(Project project) async {
    final updatedProject = await Get.to<Project>(() => ProjectCreationScreen(
      userType: widget.userType,
      userId: project.userId,
      projectToEdit: project,
    ));

    if (updatedProject != null) {
      await Provider.of<ProjectController>(context, listen: false).updateProject(updatedProject);
      if (updatedProject.assignedContractorId != null && updatedProject.assignedContractorId!.isNotEmpty) {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(updatedProject.id, updatedProject.assignedContractorId, null);
      } else if (updatedProject.assignedArchitectId != null && updatedProject.assignedArchitectId!.isNotEmpty) {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(updatedProject.id, null, updatedProject.assignedArchitectId);
      }
      Get.snackbar('Success', 'Project updated successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      // Force UI update by notifying listeners
      Provider.of<ProjectController>(context, listen: false).notifyListeners();
    }
  }

  Future<void> _deleteProject(String projectId) async {
    await Provider.of<ProjectController>(context, listen: false).deleteProject(projectId);
    Get.snackbar('Success', 'Project deleted successfully',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
  }

  Future<void> _assignProject(String projectId) async {
    final result = await Get.to<Map<String, dynamic>>(() => const FindProfessionalsDashboard());
    if (result != null && result.containsKey('professionalId') && result.containsKey('professionalRole')) {
      final professionalId = result['professionalId'] as String;
      final professionalRole = result['professionalRole'] as String;
      if (professionalRole == 'Contractor') {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(projectId, professionalId, null);
      } else if (professionalRole == 'Architect') {
        await Provider.of<ProjectController>(context, listen: false)
            .assignProject(projectId, null, professionalId);
      }
      Get.snackbar('Success', 'Professional assigned successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      await Provider.of<ProjectController>(context, listen: false).loadProjects();
    }
  }

  Future<void> _navigateToChat(String projectId, String projectTitle) async {
    await Get.to(() => ChatScreen(projectId: projectId, projectTitle: projectTitle));
  }

  Future<void> _showDeleteConfirmation(String projectId) async {
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this project?'),
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
      _deleteProject(projectId);
    }
  }
}

class ProjectListItem extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAssign;
  final VoidCallback? onChat;

  const ProjectListItem({
    required this.project,
    required this.onEdit,
    required this.onDelete,
    this.onAssign,
    this.onChat,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      CustomStringExtension(project.status.toString().split('.').last).capitalizeFirst,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (project.assignedContractorId != null && project.assignedContractorId!.isNotEmpty)
                _buildProfessionalInfo(Icons.engineering, 'Contractor', project.assignedContractorId!),
              if (project.assignedArchitectId != null && project.assignedArchitectId!.isNotEmpty)
                _buildProfessionalInfo(Icons.architecture, 'Architect', project.assignedArchitectId!),
              if (project.messages != null && project.messages!.isNotEmpty)
                Text(
                  'Last Message: ${project.messages!.last.content}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onChat != null)
                    IconButton(
                      icon: const Icon(Icons.chat, color: Color(0xFF2196F3)),
                      tooltip: 'Chat',
                      onPressed: onChat,
                    ),
                  if (onAssign != null)
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Color(0xFF2196F3)),
                      tooltip: 'Assign Professional',
                      onPressed: onAssign,
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                    tooltip: 'Edit',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalInfo(IconData icon, String title, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$title: $id',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return Colors.orange.withOpacity(0.8);
      case ProjectStatus.inProgress:
        return Colors.blue.withOpacity(0.8);
      case ProjectStatus.completed:
        return Colors.green.withOpacity(0.8);
      default:
        return Colors.grey.withOpacity(0.5);
    }
  }
}

class ProjectCreationScreen extends StatefulWidget {
  final String userType;
  final String userId;
  final Project? projectToEdit;
  final String? preFilledContractorId;
  final String? preFilledArchitectId;

  const ProjectCreationScreen({
    required this.userType,
    required this.userId,
    this.projectToEdit,
    this.preFilledContractorId,
    this.preFilledArchitectId,
    Key? key,
  }) : super(key: key);

  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contractorIdController;
  late TextEditingController _architectIdController;
  late ProjectStatus _status;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.projectToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.projectToEdit?.description ?? '');
    _contractorIdController = TextEditingController(
        text: widget.projectToEdit?.assignedContractorId ?? widget.preFilledContractorId ?? '');
    _architectIdController = TextEditingController(
        text: widget.projectToEdit?.assignedArchitectId ?? widget.preFilledArchitectId ?? '');
    _status = widget.projectToEdit?.status ?? ProjectStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contractorIdController.dispose();
    _architectIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectToEdit != null ? 'Edit Project' : 'Create Project'),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Project Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) =>
                          value?.isEmpty ?? true ? 'Project title is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 3,
                          validator: (value) =>
                          value?.isEmpty ?? true ? 'Description is required' : null,
                        ),
                        const SizedBox(height: 16),
                        if (widget.userType == 'homeowner') ...[
                          TextFormField(
                            controller: _contractorIdController,
                            decoration: InputDecoration(
                              labelText: 'Contractor ID (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Enter contractor ID to assign',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _architectIdController,
                            decoration: InputDecoration(
                              labelText: 'Architect ID (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Enter architect ID to assign',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        DropdownButtonFormField<ProjectStatus>(
                          value: _status,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: ProjectStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(CustomStringExtension(status.toString().split('.').last).capitalizeFirst),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _status = value!),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveProject,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            widget.projectToEdit != null ? 'Update Project' : 'Create Project',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.projectToEdit != null && widget.projectToEdit!.createdAt == null) {
      print("Error: Project ${widget.projectToEdit!.id} has no createdAt timestamp. Using current time as fallback.");
      Get.snackbar(
        'Warning',
        'Project creation timestamp is missing. Contact support.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }

    final project = Project(
      id: widget.projectToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      userId: widget.userId,
      userType: widget.userType,
      status: _status,
      progress: widget.projectToEdit?.progress ?? 0,
      date: DateTime.now(),
      icon: 'work',
      assignedContractorId: _contractorIdController.text.isNotEmpty ? _contractorIdController.text : null,
      assignedArchitectId: _architectIdController.text.isNotEmpty ? _architectIdController.text : null,
      messages: widget.projectToEdit?.messages ?? [],
      reviewed: widget.projectToEdit?.reviewed ?? false,
      createdAt: widget.projectToEdit?.createdAt ?? DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    final controller = Provider.of<ProjectController>(context, listen: false);
    print("Saving project: ID=${project.id}, Title=${project.title}, userId=${project.userId}, userType=${project.userType}");
    Get.back(result: project);

    if (_contractorIdController.text.isNotEmpty) {
      await controller.assignProject(project.id, _contractorIdController.text, null);
    } else if (_architectIdController.text.isNotEmpty) {
      await controller.assignProject(project.id, null, _architectIdController.text);
    }
    Get.snackbar('Success', widget.projectToEdit != null ? 'Project updated successfully' : 'Project created successfully',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
  }
}

extension CustomStringExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}*/
