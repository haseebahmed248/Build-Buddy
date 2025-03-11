
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
