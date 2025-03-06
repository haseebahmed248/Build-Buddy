/*import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatContractor/contractor_chat_screen.dart';

class ManageProjectsScreen extends StatefulWidget {
  final String userType;

  const ManageProjectsScreen({required this.userType, Key? key})
      : assert(userType == 'contractor', 'This screen is for contractors only'),
        super(key: key);

  @override
  _ManageProjectsScreenState createState() => _ManageProjectsScreenState();
}

class _ManageProjectsScreenState extends State<ManageProjectsScreen> {
  late ProjectController _controller; // Declare controller locally

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      print("Current user UID: ${user?.uid}, userType from widget: ${widget.userType}");
      if (user != null) {
        _controller = Provider.of<ProjectController>(context, listen: false);
        if (_controller.userType != 'contractor') {
          print("Creating new ProjectController with userType: contractor");
          _controller = ProjectController('contractor'); // Force contractor userType
        }
        print("Loading projects for contractor with UID: ${user.uid}, type: ${widget.userType}");
        _controller.loadProjects(); // Load projects for contractor
      } else {
        print("No user logged in, cannot load projects");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view projects')),
      );
    }

    final contractorId = user.uid;
    print("Contractor ID for filtering: $contractorId");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Projects'),
        backgroundColor: const Color(0xFF2196F3), // Match homeowner design
        elevation: 0,
      ),
      body: Consumer<ProjectController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Filter projects where the contractor is assigned
          final assignedProjects = controller.projects.where((project) {
            print("Checking project ${project.id}: assignedContractorId = ${project.assignedContractorId}, contractorId = $contractorId");
            return project.assignedContractorId == contractorId;
          }).toList();
          print("Assigned projects for contractor $contractorId, userType: ${widget.userType}: $assignedProjects");
          if (assignedProjects.isEmpty) {
            return const Center(child: Text('No assigned projects found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16), // Add padding for cleaner look
            itemCount: assignedProjects.length,
            itemBuilder: (context, index) {
              final project = assignedProjects[index];
              return ContractorProjectItem(
                project: project,
                onUpdate: () => _navigateToUpdateProject(project),
                onChat: () {
                  if (project.userId != null) {
                    _navigateToChat(project.userId!, project.id, project.title);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Cannot start chat: Homeowner ID is missing for this project.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _navigateToUpdateProject(Project project) async {
    final updatedProject = await Get.to<Project>(
          () => ContractorUpdateScreen(project: project),
    );

    if (updatedProject != null) {
      await Provider.of<ProjectController>(context, listen: false)
          .updateProject(updatedProject);
    }
  }

  Future<void> _navigateToChat(String homeownerId, String projectId, String projectTitle) async {
    await Get.to(() => ContractorChatScreen(
      homeownerId: homeownerId,
      projectId: projectId,
      projectTitle: projectTitle,
    ));
  }
}

class ContractorProjectItem extends StatelessWidget {
  final Project project;
  final VoidCallback onUpdate;
  final VoidCallback onChat;

  const ContractorProjectItem({
    required this.project,
    required this.onUpdate,
    required this.onChat,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12), // Space between cards
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          project.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            Text(
              'Status: ${GetStringUtils(project.status.toString().split('.').last).capitalize!}',
              style: TextStyle(color: Colors.blue, fontSize: 14),
            ),
            Text(
              'Progress: ${project.progress}%',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            if (project.userId != null && project.userId!.isNotEmpty)
              Text(
                'Homeowner: ${project.userId}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            if (project.assignedArchitectId != null && project.assignedArchitectId!.isNotEmpty)
              Text(
                'Architect: ${project.assignedArchitectId}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            if (project.messages != null && project.messages!.isNotEmpty)
              Text(
                'Last Message: ${project.messages!.last.content}',
                style: TextStyle(color: Colors.green, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.blue),
              tooltip: 'Chat',
              onPressed: onChat,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Update Progress',
              onPressed: onUpdate,
            ),
          ],
        ),
      ),
    );
  }
}

class ContractorUpdateScreen extends StatefulWidget {
  final Project project;

  const ContractorUpdateScreen({required this.project, Key? key})
      : super(key: key);

  @override
  _ContractorUpdateScreenState createState() => _ContractorUpdateScreenState();
}

class _ContractorUpdateScreenState extends State<ContractorUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _progressController;
  late ProjectStatus _status;

  @override
  void initState() {
    super.initState();
    _progressController = TextEditingController(text: widget.project.progress.toString());
    _status = widget.project.status;
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Project: ${widget.project.title}'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title: ${widget.project.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Description: ${widget.project.description}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _progressController,
                decoration: const InputDecoration(
                  labelText: 'Progress (%)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter progress (0-100)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Progress is required';
                  }
                  final progress = int.tryParse(value);
                  if (progress == null || progress < 0 || progress > 100) {
                    return 'Enter a valid number between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProjectStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ProjectStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(GetStringUtils(status.toString().split('.').last).capitalize!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveUpdates,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF2196F3),
                ),
                child: const Text('Update Project', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveUpdates() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure createdAt is available
    if (widget.project.createdAt == null) {
      print("Error: Project ${widget.project.id} has no createdAt timestamp. Using current time as fallback.");
      Get.snackbar(
        'Warning',
        'Project creation timestamp is missing. Contact support.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }

    final updatedProject = Project(
      id: widget.project.id,
      title: widget.project.title,
      description: widget.project.description,
      userId: widget.project.userId,
      userType: widget.project.userType,
      status: _status,
      progress: int.parse(_progressController.text),
      date: widget.project.date,
      icon: widget.project.icon,
      assignedContractorId: widget.project.assignedContractorId,
      assignedArchitectId: widget.project.assignedArchitectId,
      messages: widget.project.messages ?? [],
      reviewed: widget.project.reviewed,
      createdAt: widget.project.createdAt ?? DateTime.now(), // Use existing createdAt or fallback
      lastUpdated: DateTime.now(), // Set to current time for updates
    );

    print("Saving updated project: ${updatedProject.id}, status: ${updatedProject.status}, progress: ${updatedProject.progress}");
    Get.back(result: updatedProject);
  }
}

// Extension to capitalize strings for UI
extension StringExtension on String {
  String get capitalize => this.isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : this;
}*/

////////////////////////////////////////////
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buildbuddy/Views/Shared/Messages/chatscreen.dart';

class ManageProjectsScreen extends StatefulWidget {
  final String userType;

  const ManageProjectsScreen({required this.userType, Key? key})
      : assert(userType == 'contractor', 'This screen is for contractors only'),
        super(key: key);

  @override
  _ManageProjectsScreenState createState() => _ManageProjectsScreenState();
}

class _ManageProjectsScreenState extends State<ManageProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      print("Current user UID: ${user?.uid}, userType from widget: ${widget.userType}");
      if (user != null) {
        final controller = Provider.of<ProjectController>(context, listen: false);
        if (controller.userType != 'contractor') {
          print("Updating ProjectController userType to contractor");
          controller.updateUserType('contractor');
        }
        print("Loading projects for contractor with UID: ${user.uid}, type: ${widget.userType}");
        controller.loadProjects();
      } else {
        print("No user logged in, cannot load projects");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view projects')),
      );
    }

    final contractorId = user.uid;
    print("Contractor ID for filtering: $contractorId");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Projects'),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: Consumer<ProjectController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final assignedProjects = controller.projects.where((project) {
            print("Checking project ${project.id}: assignedContractorId = ${project.assignedContractorId}, contractorId = $contractorId");
            return project.assignedContractorId == contractorId;
          }).toList();
          print("Assigned projects for contractor $contractorId, userType: ${widget.userType}: $assignedProjects");
          if (assignedProjects.isEmpty) {
            return const Center(child: Text('No assigned projects found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignedProjects.length,
            itemBuilder: (context, index) {
              final project = assignedProjects[index];
              return ContractorProjectItem(
                project: project,
                onUpdate: () => _navigateToUpdateProject(project),
                onChat: () => _navigateToChat(project.id, project.title),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _navigateToUpdateProject(Project project) async {
    final updatedProject = await Get.to<Project>(
          () => ContractorUpdateScreen(project: project),
    );

    if (updatedProject != null) {
      await Provider.of<ProjectController>(context, listen: false).updateProject(updatedProject);
    }
  }

  Future<void> _navigateToChat(String projectId, String projectTitle) async {
    await Get.to(() => ChatScreen(
      projectId: projectId,
      projectTitle: projectTitle,
      userType: widget.userType, // Pass userType explicitly
    ));
  }
}

class ContractorProjectItem extends StatelessWidget {
  final Project project;
  final VoidCallback onUpdate;
  final VoidCallback onChat;

  const ContractorProjectItem({
    required this.project,
    required this.onUpdate,
    required this.onChat,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          project.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            Text(
              'Status: ${GetStringUtils(project.status.toString().split('.').last).capitalize!}',
              style: TextStyle(color: Colors.blue, fontSize: 14),
            ),
            Text(
              'Progress: ${project.progress}%',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            if (project.userId != null && project.userId!.isNotEmpty)
              Text(
                'Homeowner: ${project.userId}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            if (project.assignedArchitectId != null && project.assignedArchitectId!.isNotEmpty)
              Text(
                'Architect: ${project.assignedArchitectId}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            if (project.messages != null && project.messages!.isNotEmpty)
              Text(
                'Last Message: ${project.messages!.last.content}',
                style: TextStyle(color: Colors.green, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.blue),
              tooltip: 'Chat',
              onPressed: onChat,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Update Progress',
              onPressed: onUpdate,
            ),
          ],
        ),
      ),
    );
  }
}

class ContractorUpdateScreen extends StatefulWidget {
  final Project project;

  const ContractorUpdateScreen({required this.project, Key? key}) : super(key: key);

  @override
  _ContractorUpdateScreenState createState() => _ContractorUpdateScreenState();
}

class _ContractorUpdateScreenState extends State<ContractorUpdateScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Corrected to proper initialization
  late TextEditingController _progressController;
  late ProjectStatus _status;

  @override
  void initState() {
    super.initState();
    _progressController = TextEditingController(text: widget.project.progress.toString());
    _status = widget.project.status;
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Project: ${widget.project.title}'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Form(
        key: _formKey, // Assign the GlobalKey to the Form
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title: ${widget.project.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Description: ${widget.project.description}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _progressController,
                decoration: const InputDecoration(
                  labelText: 'Progress (%)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter progress (0-100)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Progress is required';
                  }
                  final progress = int.tryParse(value);
                  if (progress == null || progress < 0 || progress > 100) {
                    return 'Enter a valid number between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProjectStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ProjectStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(GetStringUtils(status.toString().split('.').last).capitalize!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveUpdates,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF2196F3),
                ),
                child: const Text('Update Project', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveUpdates() async {
    if (_formKey.currentState!.validate()) { // Corrected to use _formKey.currentState
      if (widget.project.createdAt == null) {
        print("Error: Project ${widget.project.id} has no createdAt timestamp. Using current time as fallback.");
        Get.snackbar(
          'Warning',
          'Project creation timestamp is missing. Contact support.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

      final updatedProject = Project(
        id: widget.project.id,
        title: widget.project.title,
        description: widget.project.description,
        userId: widget.project.userId,
        userType: widget.project.userType,
        status: _status,
        progress: int.parse(_progressController.text),
        date: widget.project.date,
        icon: widget.project.icon,
        assignedContractorId: widget.project.assignedContractorId,
        assignedArchitectId: widget.project.assignedArchitectId,
        messages: widget.project.messages ?? [],
        reviewed: widget.project.reviewed,
        createdAt: widget.project.createdAt ?? DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      print("Saving updated project: ${updatedProject.id}, status: ${updatedProject.status}, progress: ${updatedProject.progress}");
      Get.back(result: updatedProject);
    }
  }
}

// Extension to capitalize strings for UI
extension GetStringUtils on String {
  String? get capitalize => this.isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : this;
}
//////////////////////////////////////////











/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageProjectsScreen extends StatefulWidget {
  const ManageProjectsScreen({Key? key}) : super(key: key);

  @override
  _ManageProjectsScreenState createState() => _ManageProjectsScreenState();
}

class _ManageProjectsScreenState extends State<ManageProjectsScreen> {
  final List<Map<String, dynamic>> _allProjects = [
    {
      'id': 'PRJ001',
      'projectName': 'Build Villa A',
      'description': 'Construction of a 4-bedroom villa in the countryside',
      'status': 'In Progress',
      'progress': 50,
      'date': '2024-11-15',
      'icon': Icons.house_rounded
    },
    {
      'id': 'PRJ002',
      'projectName': 'Office Complex B',
      'description': 'Office complex with 5 floors',
      'status': 'Completed',
      'progress': 100,
      'date': '2024-11-10',
      'icon': Icons.business_rounded
    },
    {
      'id': 'PRJ003',
      'projectName': 'Mall C',
      'description': 'A large shopping mall under construction',
      'status': 'Pending',
      'progress': 0,
      'date': '2024-11-05',
      'icon': Icons.shopping_bag_rounded
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
                                      'Manage Projects',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'View and Manage Your Projects',
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
                                  project['projectName'],
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
}

/////////////////

class ProjectCreationScreen extends StatefulWidget {
  const ProjectCreationScreen({Key? key}) : super(key: key);

  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedStatus = 'In Progress';
  double _progress = 0;

  final List<String> _statusOptions = ['In Progress', 'Completed', 'Pending'];

  @override
  void dispose() {
    _projectNameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _saveProject() {
    final project = {
      'id': 'PRJ${DateTime.now().millisecondsSinceEpoch}',
      'projectName': _projectNameController.text,
      'description': _descriptionController.text,
      'status': _selectedStatus,
      'progress': _progress,
      'date': _dateController.text,
      'icon': Icons.house_rounded, // You can change this icon based on project type
    };

    Navigator.pop(context, project);
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
                                      'Create New Project',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Enter details for your project',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Project Name
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Project Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Project Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Project Date
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Start Date',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Status Dropdown
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions
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
            SizedBox(height: 16),
            // Progress Slider
            Text('Progress: ${_progress.toInt()}%'),
            Slider(
              value: _progress,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _progress = value;
                });
              },
            ),
            SizedBox(height: 16),
            // Save Button
            ElevatedButton(
              onPressed: _saveProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4834DF),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Save Project',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
