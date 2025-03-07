import 'package:flutter/material.dart';
import 'package:buildbuddy/Routes/app_routes.dart';
import 'package:buildbuddy/Core/Theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Controllers/chatController.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/adminController.dart' as admin;
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Controllers/vendorController.dart';
import 'package:buildbuddy/Controllers/contractorController.dart'; // Import ContractorController
import 'package:buildbuddy/Models/userModels.dart';
import 'package:buildbuddy/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Optionally, show an error screen or fallback UI
  }

  // Initialize global controllers with GetX
  final authController = Get.put(AuthController());
  Get.put(ChatController()); // Ensure ChatController is initialized globally

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProjectController>(
          create: (_) => ProjectController('homeowner'),
        ),
        ChangeNotifierProvider<VendorController>(
          create: (_) => VendorController(Get.find<AuthController>()), // Use Get.find to access AuthController
        ),
        ChangeNotifierProvider<ContractorController>(
          create: (_) => ContractorController(Get.find<AuthController>()), // Add ContractorController
        ),
        ProxyProvider<AuthController, admin.AdminController?>(
          create: (_) => null, // Initial value (nullable)
          update: (_, auth, previous) {
            final user = auth.currentUser.value;
            print(
                'ProxyProvider update: user=${user?.email}, role=${user?.role}, returning=${user?.role == UserRole.admin ? "admin.AdminController" : "null"}');
            if (user != null && user.role == UserRole.admin) {
              return previous ?? admin.AdminController(auth);
            }
            return null;
          },
          dispose: (_, controller) => controller?.dispose(),
        ),
      ],
      child: MyApp(authController: authController),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthController authController;

  const MyApp({super.key, required this.authController});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.authController.currentUser.listen((userData) async {
      if (userData != null) {
        print('User updated in main.dart: email=${userData.email}, role=${userData.role}');
        await _updateProjectController(userData.uid, userData.role);
      }
    });
    // Ensure initial user check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authController.checkCurrentUser();
    });
  }

  Future<void> _updateProjectController(String userId, UserRole role) async {
    print('Updating ProjectController in main.dart for userId: $userId, role: ${role.name}');
    final projectController = Provider.of<ProjectController>(context, listen: false);
    try {
      projectController.updateUserType(role.name);
      await projectController.loadProjects();
    } catch (e) {
      print('Failed to load projects for user $userId: $e');
      Get.snackbar('Error', 'Failed to load projects: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BuildBuddy',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: AppRoutes.getPages,
      navigatorObservers: [
        GetObserver((_) {
          print('Navigating to: ${Get.currentRoute}');
        }),
      ],
    );
  }
}










/*
import 'package:flutter/material.dart';
import 'package:buildbuddy/Routes/app_routes.dart';
import 'package:buildbuddy/Core/Theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart'; // Correct import for AuthController
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/adminController.dart' as admin; // Use prefix for AdminController
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'package:buildbuddy/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authController = Get.put(AuthController());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProjectController>(
          create: (_) => ProjectController('homeowner'),
        ),
        ProxyProvider<AuthController, admin.AdminController?>(
          create: (_) => null, // Initial value (nullable)
          update: (_, auth, previous) {
            final user = auth.currentUser.value;
            print(
                'ProxyProvider update: user=${user?.email}, role=${user?.role}, returning=${user?.role == UserRole.admin ? "admin.AdminController" : "null"}');
            if (user != null && user.role == UserRole.admin) {
              return previous ?? admin.AdminController(auth);
            }
            return null;
          },
          dispose: (_, controller) => controller?.dispose(),
        ),
      ],
      child: MyApp(authController: authController),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthController authController;

  const MyApp({super.key, required this.authController});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.authController.currentUser.listen((userData) async {
      if (userData != null) {
        print('User updated in main.dart: email=${userData.email}, role=${userData.role}');
        await _updateProjectController(userData.uid, userData.role);
      }
    });
    // Ensure initial user check with delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authController.checkCurrentUser();
    });
  }

  Future<void> _updateProjectController(String userId, UserRole role) async {
    print('Updating ProjectController in main.dart for userId: $userId, role: ${role.name}');
    await Future.delayed(const Duration(milliseconds: 100)); // Small delay to ensure state propagation
    final projectController = Provider.of<ProjectController>(context, listen: false);
    projectController.updateUserType(role.name);
    projectController.loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BuildBuddy',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: AppRoutes.getPages,
      navigatorObservers: [
        GetObserver((_) {
          print('Navigating to: ${Get.currentRoute}');
        }),
      ],
    );
  }
}*//*

///////////







import 'package:flutter/material.dart';
import 'package:buildbuddy/Routes/app_routes.dart';
import 'package:buildbuddy/Core/Theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Controllers/chatController.dart'; // Add ChatController
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/adminController.dart' as admin;
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'package:buildbuddy/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Optionally, show an error screen or fallback UI
  }

  // Initialize global controllers with GetX
  final authController = Get.put(AuthController());
  Get.put(ChatController()); // Ensure ChatController is initialized globally

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProjectController>(
          create: (_) => ProjectController('homeowner'),
        ),
        ProxyProvider<AuthController, admin.AdminController?>(
          create: (_) => null, // Initial value (nullable)
          update: (_, auth, previous) {
            final user = auth.currentUser.value;
            print(
                'ProxyProvider update: user=${user?.email}, role=${user?.role}, returning=${user?.role == UserRole.admin ? "admin.AdminController" : "null"}');
            if (user != null && user.role == UserRole.admin) {
              return previous ?? admin.AdminController(auth);
            }
            return null;
          },
          dispose: (_, controller) => controller?.dispose(),
        ),
      ],
      child: MyApp(authController: authController),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthController authController;

  const MyApp({super.key, required this.authController});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.authController.currentUser.listen((userData) async {
      if (userData != null) {
        print('User updated in main.dart: email=${userData.email}, role=${userData.role}');
        await _updateProjectController(userData.uid, userData.role);
      }
    });
    // Ensure initial user check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authController.checkCurrentUser();
    });
  }

  Future<void> _updateProjectController(String userId, UserRole role) async {
    print('Updating ProjectController in main.dart for userId: $userId, role: ${role.name}');
    final projectController = Provider.of<ProjectController>(context, listen: false);
    try {
      projectController.updateUserType(role.name);
      await projectController.loadProjects();
    } catch (e) {
      print('Failed to load projects for user $userId: $e');
      Get.snackbar('Error', 'Failed to load projects: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BuildBuddy',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: AppRoutes.getPages,
      navigatorObservers: [
        GetObserver((_) {
          print('Navigating to: ${Get.currentRoute}');
        }),
      ],
    );
  }
}*/
