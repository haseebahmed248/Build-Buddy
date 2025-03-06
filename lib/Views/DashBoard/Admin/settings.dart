import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/AdminController.dart';

//import '../../../Controllers/adminController.da';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _notificationsEnabled = true;
  bool _twoFactorAuthEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final controller = Provider.of<AdminController>(context, listen: false);
    await controller.loadSettings();
    setState(() {
      _notificationsEnabled = controller.settings['notificationsEnabled'] ?? true;
      _twoFactorAuthEnabled = controller.settings['twoFactorAuthEnabled'] ?? false;
    });
  }

  void _saveSettings() {
    final controller = Provider.of<AdminController>(context, listen: false);
    controller.updateSettings({
      'notificationsEnabled': _notificationsEnabled,
      'twoFactorAuthEnabled': _twoFactorAuthEnabled,
    }).then((_) {
      Get.snackbar('Success', 'Settings saved successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    }).catchError((e) {
      Get.snackbar('Error', 'Failed to save settings: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, controller, _) {
        if (!controller.isAdmin) {
          return const Scaffold(
              body: Center(child: Text('Access Denied: Admins Only', style: TextStyle(color: Colors.red))));
        }
        if (controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF2196F3))));
        }
        if (controller.errorMessage != null) {
          return Scaffold(
              body: Center(child: Text('Error: ${controller.errorMessage}', style: const TextStyle(color: Colors.red))));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: const Color(0xFF2196F3),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadSettings,
                tooltip: 'Refresh Settings',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                  secondary: const Icon(Icons.notifications),
                ),
                SwitchListTile(
                  title: const Text('Enable Two-Factor Authentication'),
                  value: _twoFactorAuthEnabled,
                  onChanged: (value) => setState(() => _twoFactorAuthEnabled = value),
                  secondary: const Icon(Icons.security),
                ),
                const SizedBox(height: 16),
                const Text('Admin Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'These settings control global app behavior. Ensure changes align with security and usability requirements.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                  child: const Text('Save Settings'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}