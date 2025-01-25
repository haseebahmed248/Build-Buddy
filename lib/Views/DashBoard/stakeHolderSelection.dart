import 'package:flutter/material.dart';
import 'package:buildbuddyfyp/Models/userModels.dart';
import 'package:buildbuddyfyp/Views/Login/startedScreen.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class StakeholderSelection extends StatefulWidget {
  final Function(UserRole)? onRoleSelected;

  const StakeholderSelection({
    super.key,
    this.onRoleSelected,
  });

  @override
  State<StakeholderSelection> createState() => _StakeholderSelectionState();
}

class _StakeholderSelectionState extends State<StakeholderSelection> {
  final List<Map<String, dynamic>> stakeholders = const [
    {
      'role': UserRole.homeowner,
      'title': 'Homeowner',
      'icon': Icons.home,
      'description': 'Manage and oversee your home construction project',
    },
    {
      'role': UserRole.contractor,
      'title': 'Contractor',
      'icon': Icons.construction,
      'description': 'Execute and manage construction work',
    },
    {
      'role': UserRole.architect,
      'title': 'Architect',
      'icon': Icons.architecture,
      'description': 'Provide plans and design consultation',
    },
    {
      'role': UserRole.vendor,
      'title': 'Vendor',
      'icon': Icons.local_shipping,
      'description': 'Supply construction materials and resources',
    },
    {
      'role': UserRole.admin,
      'title': 'Admin',
      'icon': Icons.admin_panel_settings,
      'description': 'Manage platform and maintain system operations',
    },
  ];

  // Controller for admin code input
  final TextEditingController _adminCodeController = TextEditingController();

  // Validate admin code from Firebase
  Future<bool> validateAdminCode(String enteredCode) async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('admin_code');
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        String storedCode = snapshot.value.toString().trim();
        String enteredTrimmedCode = enteredCode.trim();

        // Debugging output to check the values
        print("Stored Code: '$storedCode'");
        print("Entered Code: '$enteredTrimmedCode'");

        return storedCode == enteredTrimmedCode;
      } else {
        print("Admin code not found in database");
        return false;
      }
    } catch (error) {
      print("Error validating admin code: $error");
      return false;
    }
  }

  void _handleStakeholderTap(BuildContext context, UserRole role) async {
    if (widget.onRoleSelected != null) {
      widget.onRoleSelected!(role);
    }

    if (role == UserRole.admin) {
      final adminCode = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Enter Admin Code"),
            content: TextField(
              controller: _adminCodeController,
              decoration: const InputDecoration(hintText: "Admin Code"),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  String enteredCode = _adminCodeController.text;
                  Navigator.of(context).pop(enteredCode);
                },
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null); // Dismiss without action
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (adminCode != null && adminCode.isNotEmpty) {
        bool isValid = await validateAdminCode(adminCode);

        if (isValid) {
          Get.toNamed('/adminSignIn'); // Or navigate to Admin Dashboard
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid Admin Code")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin code cannot be empty")),
        );
      }
    } else {
      Get.toNamed(
        '/get-started',
        arguments: role.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.offAllNamed('/welcome');
          },
        ),
        title: const Text(
          'Select Your Role',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -55,
            right: -90,
            child: Container(
              width: 200,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            top: -55,
            right: 50,
            child: Container(
              width: 200,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            bottom: -270,
            right: -150,
            child: Container(
              width: 500,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1a237e),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Build Buddy',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your role to continue',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: stakeholders.length,
                      itemBuilder: (context, index) {
                        final stakeholder = stakeholders[index];
                        return _StakeholderCard(
                          icon: stakeholder['icon'] as IconData,
                          title: stakeholder['title'] as String,
                          description: stakeholder['description'] as String,
                          onTap: () => _handleStakeholderTap(
                            context,
                            stakeholder['role'] as UserRole,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StakeholderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _StakeholderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
