/*import 'package:buildbuddyfyp/Services/projects/projectService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Models/projectModel.dart';

class MyProjectsDashboard extends StatefulWidget {
  final String userId;
  const MyProjectsDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  _MyProjectsDashboardState createState() => _MyProjectsDashboardState();

}

class _MyProjectsDashboardState extends State<MyProjectsDashboard> {
  final ProjectService _projectService = ProjectService();
  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }
  Future<void> _fetchProjects() async {
    try {
      final projects = await _projectService.getProjectsForUser(widget.userId);
      setState(() {
        _allProjects = projects;
        _filteredProjects = projects;
      });
    } catch (e) {
      print("Error fetching projects: $e");
    }
  }

  void _filterProjects(String? filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == null || filter == 'All') {
        _filteredProjects = _allProjects;
      } else {
        _filteredProjects = _allProjects
            .where((project) =>
        project.status.toString().split('.').last == filter)
            .toList();
      }
    });
  }


 *//* final List<Map<String, dynamic>> _allProjects = [
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
  ];*//*

  *//*String? _selectedFilter;
  List<Map<String, dynamic>> _filteredProjects = [];

  @override
  void initState() {
    super.initState();
    _filteredProjects = List.from(_allProjects);
  }
*//*
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
                        .where((project) => project.status== _selectedFilter)
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
  *//*void _deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(projectId);
      _fetchProjects();
    } catch (e) {
      print('Error deleting project: $e');
    }
  }*//*

  *//*Color _getStatusColor(ProjectStatus status) {
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
  }*//*
  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.ongoing:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
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
                             // color: _getStatusColor(project['status']).withOpacity(0.1),
                              color: _getStatusColor((project.status?.toString() ?? 'default') as ProjectStatus).withOpacity(0.1),

                              borderRadius: BorderRadius.circular(15),
                            ),
                            *//*child: Icon(
                              //project['icon'],
                             // project.icon as IconData,
                              //color: _getStatusColor(project['status']),
                              color: _getStatusColor(project.status as String),
                              size: 24,
                            ),*//*
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  //project['title'],
                                 // project.status as String,
                                project.status.toString().split('.').last,

                            style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1E3799),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  //project['description'],
                                  project.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                 // project['date'],
                                  project.startDate.toString(),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(
                                 // value: project['progress'] / 100,
                                  //value: project.progress as double / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                   // _getStatusColor(project['status']),
                                   // _getStatusColor(project.status as String),
                                    _getStatusColor(project.status.toString()),
                                  //  color: _getStatusColor(project.status.toString()).withOpacity(0.1),

                                  ),
                                ),
                                SizedBox(height: 4),
                               *//* Text(
                                 // '${project['progress']}% Completed',
                                  //'${project.progress}% Completed',
                                  //'${project.progress}% Completed',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),*//*
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
                                 // color: _getStatusColor(project['status']).withOpacity(0.1),
                                 // color: _getStatusColor(project.status as String).withOpacity(0.1),
                                  color: _getStatusColor(project.status.toString()).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                 // project['status'],
                                 // project.status as String,
                                  project.status.toString().split('.').last,
                                  style: TextStyle(
                                   // color: _getStatusColor(project['status']),
                                  //  color: _getStatusColor(project.status as String),
                                    color: _getStatusColor(project.status.toString()),
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

  *//*void _navigateToProjectCreation() async {
    final newProject = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectCreationScreen(),
      ),
    );

    if (newProject != null) {
      setState(() {
        _allProjects.add(newProject as Project);
        _filteredProjects.add(newProject as Project);
      });
    }
  }*//*
  void _navigateToProjectCreation() async {
    final newProjectData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectCreationScreen(),
      ),
    );

    if (newProjectData != null) {
      // Debugging: Print the contents of newProjectData
      print("New Project Data: $newProjectData");

      // Check if 'id' exists and is not null
      final projectId = newProjectData['id'];

      if (projectId == null) {
        print("Error: Project ID is null.");
        return;  // Return early to avoid calling Project.fromJson() with null id.
      }

      // Proceed with creating the Project object
      try {
        final newProject = Project.fromJson(projectId, newProjectData);
        setState(() {
          _allProjects.add(newProject);
          _filteredProjects.add(newProject);
        });
      } catch (e) {
        print("Error creating project: $e");
      }
    }
  }

}*/

/*
class ProjectCreationScreen extends StatefulWidget {
  const ProjectCreationScreen({Key? key}) : super(key: key);

  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedStatus = 'In Progress';


  Future<void> _saveProject() async {
    try {
      // Validate the selected status, use default if invalid
      final status = ProjectStatus.values.firstWhere(
            (e) => e.toString().split('.').last == _selectedStatus,
        orElse: () => ProjectStatus.notStarted, // Default status if invalid
      );

      final project = Project(
        id: 'PRJ${DateTime.now().millisecondsSinceEpoch}',
        name: _titleController.text,
        description: _descriptionController.text,
        homeownerId: 'https://console.firebase.google.com/project/buildbuddy2025/database/buildbuddy2025-default-rtdb/data/~2Fuser~2Fhomeowner~2FhzJkCnhyH1dJ54gJAD8oodTmjsE3',
        contractorId: 'https://console.firebase.google.com/project/buildbuddy2025/database/buildbuddy2025-default-rtdb/data/~2Fuser~2Fcontractor~2F1U3Cl2VKJWNWSxHommyRopJ9HhQ2',
        architectId: 'https://console.firebase.google.com/project/buildbuddy2025/database/buildbuddy2025-default-rtdb/data/~2Fuser~2Farchitect~2FsK6FIZDS5ESU0XU4fHZXQl6Pqo22',
        status: status,
        startDate: DateTime.now(),
        endDate: null,
        //materialOrders: [],
        //payments: [],
      );

      // Save project to the database
      await ProjectService().addProject(project);

      // Return to the previous screen with the project data
      Navigator.pop(context, project);
    } catch (e) {
      print('Error saving project: $e');
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
}*/












////////////
import 'package:buildbuddyfyp/Controllers/projectController.dart';
import 'package:buildbuddyfyp/Models/projectModel.dart';

import 'package:buildbuddyfyp/Views/DashBoard/HomeOwner/projectListItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:firebase_auth/firebase_auth.dart';



class MyProjectsDashboard extends StatefulWidget {
  final String userType;

  const MyProjectsDashboard({required this.userType, Key? key}) : super(key: key);

  @override
  _MyProjectsDashboardState createState() => _MyProjectsDashboardState();
}

class _MyProjectsDashboardState extends State<MyProjectsDashboard> {
  String? _selectedFilter;
  late ProjectController _projectController;

  @override
  void initState() {
    super.initState();
    _projectController = ProjectController(widget.userType);
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await _projectController.loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _projectController,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AppBar(
              title: Text('My Projects'),
            ),
          ),
        body: Consumer<ProjectController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: controller.projects.length,
              itemBuilder: (context, index) {
                final project = controller.projects[index];
                return ProjectListItem(
                  project: project,
                  onEdit: () => _navigateToEditProject(project),
                  onDelete: () => _deleteProject(project.id),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToCreateProject,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _navigateToCreateProject() async
  {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectCreationScreen(
          userType: widget.userType,
          userId: user.uid,
        ),
      ),
    );

    if (newProject != null) {
      await _projectController.addProject(newProject);
    }
  }
  Future<void> _navigateToEditProject(Project project) async {
    final updatedProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectCreationScreen(
          userType: widget.userType,
          userId: project.userId,
          projectToEdit: project,
        ),
      ),
    );

    if (updatedProject != null) {
      await _projectController.updateProject(updatedProject);
    }
  }

  Future<void> _deleteProject(String projectId) async {
    await _projectController.deleteProject(projectId);
  }
}

// lib/screens/project_creation_screen.dart
class ProjectCreationScreen extends StatefulWidget {
  final String userType;
  final String userId;
  final Project? projectToEdit;

  const ProjectCreationScreen({
    required this.userType,
    required this.userId,
    this.projectToEdit,
    Key? key,
  }) : super(key: key);

  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late ProjectStatus _status;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.projectToEdit?.title);
    _descriptionController = TextEditingController(text: widget.projectToEdit?.description);
    _status = widget.projectToEdit?.status ?? ProjectStatus.inProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text('My Projects'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Project Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<ProjectStatus>(
                value: _status,
                items: ProjectStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProject,
                child: Text(widget.projectToEdit != null ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final project = Project(
      id: widget.projectToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      userId: widget.userId,
      userType: widget.userType,
      status: _status,
      progress: widget.projectToEdit?.progress ?? 0,
      date: DateTime.now().toIso8601String(),
      icon: Icons.work,
    );

    Navigator.pop(context, project);
  }
}


















