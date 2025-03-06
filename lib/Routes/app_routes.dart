import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/adminController.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Controllers/chatController.dart'; // Main ChatController
import 'package:buildbuddy/Controllers/contractorController.dart';
import 'package:buildbuddy/Controllers/vendorController.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'package:provider/provider.dart';

// Core App Screens
import '../Views/DashBoard/HomeOwner/Help&SupportDashboard.dart';
import '../Views/DashBoard/HomeOwner/NotificationsDashboard.dart';
import '../Views/DashBoard/HomeOwner/Rate&ReviewDashboard.dart';
import '../Views/DashBoard/HomeOwner/chat_screen.dart' as ChatScreenImport;
import '../Views/DashBoard/HomeOwner/findProfessionals.dart';
import '../Views/DashBoard/HomeOwner/myProjects.dart';
import '../Views/DashBoard/HomeOwner/payments&InvoicesDashboard.dart';
import '../Views/DashBoard/HomeOwner/settings.dart';
import '../Views/Login/boardingScreen.dart';
import '../Views/Login/startedScreen.dart';
import '../Views/Login/welcomeScreen.dart';
import '../Views/Login/loginPage.dart';
import '../Views/Login/signUP.dart';
import '../Views/Login/forgotPassword.dart';
import '../Views/Login/splashScreen.dart';

// Stakeholder Selection
import '../Views/DashBoard/stakeHolderSelection.dart';

// Dashboard Screens
import '../Views/DashBoard/Admin.dart' as AdminDashboard; // Alias for Admin
import '../Views/DashBoard/HomeOwner.dart';
import '../Views/DashBoard/Constructor.dart' as ConstructorDashboard; // Alias for ContractorDashboard
import '../Views/DashBoard/Contractor/manageProjects.dart' as ContractorManageProjects;
import '../Views/DashBoard/Architect.dart';
import '../Views/DashBoard/Vendor.dart';

// Contractor Screens
import '../Views/DashBoard/Contractor/manageProjects.dart';
import '../Views/DashBoard/Contractor/materialOrders.dart';
import '../Views/DashBoard/Contractor/messages.dart';
import '../Views/DashBoard/Contractor/Payments.dart';
import '../Views/DashBoard/Contractor/RatingAndReviews.dart';
import '../Views/DashBoard/Contractor/chatContractor/contractor_chat_screen.dart';

// Vendor Screens
import '../Views/DashBoard/Vendor/ordersScreen.dart';
import '../Views/DashBoard/Vendor/invoicesScreen.dart';
import '../Views/DashBoard/Vendor/manageProductsScreen.dart';
import '../Views/DashBoard/Vendor/analytics.dart';
import '../Views/DashBoard/Vendor/notifications.dart';
import '../Views/DashBoard/Vendor/support.dart';
import '../Views/DashBoard/Vendor/messageScreen.dart';
import '../Views/DashBoard/Vendor/Ratings&ReviewsScreen.dart';

// Admin Screens
import '../Views/Login/AdminSignUp.dart';
import '../Views/DashBoard/Admin/userManagement.dart';
import '../Views/DashBoard/Admin/projectMonitoring.dart';
import '../Views/DashBoard/Admin/reports.dart';
import '../Views/DashBoard/Admin/contentManagement.dart';
import '../Views/DashBoard/Admin/settings.dart';
import '../Views/DashBoard/Admin/support.dart';

// Chat Screen with alias to avoid conflict
import '../Views/DashBoard/chatScreen.dart' as ChatScreenImport;

// Custom middleware for role-based access control
class RoleBasedMiddleware extends GetMiddleware {
  final UserRole requiredRole;

  RoleBasedMiddleware(this.requiredRole, {super.priority = 1});

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final userData = authController.currentUser.value; // Use cached/reactive user data

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || userData == null) {
      Get.snackbar('Unauthorized', 'Please sign in as a ${requiredRole.name}');
      return const RouteSettings(name: '/stakeholder');
    }

    switch (requiredRole) {
      case UserRole.admin:
        if (userData.role != UserRole.admin) {
          Get.snackbar('Unauthorized', 'Only admins can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.homeowner:
        if (userData.role != UserRole.homeowner) {
          Get.snackbar('Unauthorized', 'Only homeowners can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.contractor:
        if (userData.role != UserRole.contractor) {
          Get.snackbar('Unauthorized', 'Only contractors can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.architect:
        if (userData.role != UserRole.architect) {
          Get.snackbar('Unauthorized', 'Only architects can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.vendor:
        if (userData.role != UserRole.vendor) {
          Get.snackbar('Unauthorized', 'Only vendors can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
    }
    return null; // Allow navigation if role matches
  }
}

class AppRoutes {
  static final getPages = [
    // Core App Screens
    GetPage(name: '/boarding', page: () => const BoardingScreen()),
    GetPage(name: '/', page: () => SplashScreen()),
    GetPage(name: '/welcome', page: () => const WelcomeScreen()),
    GetPage(
      name: '/get-started',
      page: () => const GetStartedScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: '/sign-in', page: () => const SignInScreen()),
    GetPage(name: '/sign-up', page: () => const SignUpScreen()),
    GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),

    // Stakeholder Selection
    GetPage(name: '/stakeholder', page: () => const StakeholderSelection()),

    // Admin Routes (Restricted to admin users)
    GetPage(
      name: '/adminSignIn',
      page: () => const AdminSignInScreen(),
    ),
    GetPage(
      name: '/adminDashboard',
      page: () => const AdminDashboard.AdminDashboard(),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/user-management',
      page: () => _buildAdminScreen<UserManagement>(UserManagement()),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/project-monitoring',
      page: () => _buildAdminScreen<ProjectMonitoring>(ProjectMonitoring()),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/reports',
      page: () => _buildAdminScreen<Reports>(Reports()),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/content-management',
      page: () => _buildAdminScreen<ContentManagement>(ContentManagement()),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/settings',
      page: () => _buildAdminScreen<Settings>(Settings()),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/support',
      page: () => _buildAdminScreen<Support>(Support()),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/admin-chat',
      page: () => _buildAdminScreen<ChatScreenImport.ChatScreen>(ChatScreenImport.ChatScreen(projectId: '', projectTitle: '',)),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),

    // HomeOwner Dashboard (Restricted to homeowners)
    GetPage(
      name: '/homeowner-dashboard',
      page: () => const HomeOwnerDashboard(),
      transition: Transition.fadeIn,
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),
    GetPage(
      name: '/find-professionals',
      page: () => const FindProfessionalsDashboard(),
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsDashboard(),
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),
    GetPage(
      name: '/my-projects',
      page: () {
        final userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId';
        return MyProjectsDashboard(userType: 'homeowner');
      },
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),
    GetPage(
      name: '/payments',
      page: () => const PaymentsDashboard(),
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),
    GetPage(
      name: '/rate-review',
      page: () => const RateReviewDashboard(),
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),
    GetPage(
      name: '/notifications',
      page: () => const NotificationsDashboard(),
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),
    GetPage(
      name: '/support',
      page: () => const SupportDashboard(),
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),
    GetPage(
      name: '/homeowner-chat',
      page: () => _buildHomeownerScreen<ChatScreenImport.ChatScreen>(ChatScreenImport.ChatScreen(projectId: '', projectTitle: '',)),
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),

    // Contractor Dashboard (Restricted to contractors)
    GetPage(
      name: '/contractor-dashboard',
      page: () => const ConstructorDashboard.ContractorDashboard(),
      transition: Transition.fadeIn,
      middlewares: [
        RoleBasedMiddleware(UserRole.contractor),
      ],
    ),
    GetPage(
      name: '/manage-projects',
      page: () => const ManageProjectsScreen(userType: 'contractor'),
      middlewares: [
        RoleBasedMiddleware(UserRole.contractor),
      ],
    ),
    /*GetPage(
      name: '/material-orders',
      page: () => const MaterialOrdersScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.contractor),
      ],
    ),*/
    GetPage(
      name: '/contractor-messages',
      page: () {
        // Redirect to ManageProjectsScreen for project selection
        return const ManageProjectsScreen(userType: 'contractor');
      },
      middlewares: [
        RoleBasedMiddleware(UserRole.contractor),
      ],
    ),
    GetPage(
      name: '/contractor-payments',
      page: () => const PaymentsScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.contractor),
      ],
    ),
    GetPage(
      name: '/contractor-reviews',
      page: () => RatingsReviewsScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.contractor),
      ],
    ),

    // Architect Dashboard (Restricted to architects)
    GetPage(
      name: '/architect-dashboard',
      page: () => const ArchitectDashboard(),
      transition: Transition.fadeIn,
      middlewares: [
        RoleBasedMiddleware(UserRole.architect),
      ],
    ),
    GetPage(
      name: '/architect-chat',
      page: () => _buildArchitectScreen<ChatScreenImport.ChatScreen>(ChatScreenImport.ChatScreen(projectId: '', projectTitle: '',)),
      middlewares: [
        RoleBasedMiddleware(UserRole.architect),
      ],
    ),

    // Vendor Dashboard (Restricted to vendors)
    GetPage(
      name: '/vendor-dashboard',
      page: () => const VendorDashboard(),
      transition: Transition.fadeIn,
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
    /*GetPage(
      name: '/vendor-orders',
      page: () => VendorOrdersScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),*/
    GetPage(
      name: '/vendor-payments',
      page: () => VendorInvoicesScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
    GetPage(
      name: '/manage-products',
      page: () => ManageProductsScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
    GetPage(
      name: '/vendor-messages',
      page: () => _buildVendorScreen<ChatScreenImport.ChatScreen>(ChatScreenImport.ChatScreen(projectId: '', projectTitle: '',)),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
    GetPage(
      name: '/vendor-reviews',
      page: () => ReviewVendorTasksScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
    GetPage(
      name: '/vendor-analytics',
      page: () => VendorAnalyticsScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
    GetPage(
      name: '/vendor-notifications',
      page: () => VendorNotificationsScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
    GetPage(
      name: '/vendor-support',
      page: () => VendorSupportScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
  ];

  // Helper method to build admin screens with AdminController provider
  static Widget _buildAdminScreen<T extends Widget>(T screen) {
    final context = Get.context;
    if (context == null) {
      throw Exception('Get.context is null. Ensure Get is initialized properly.');
    }
    return MultiProvider(
      providers: [
        Provider<AdminController>.value(
          value: Provider.of<AdminController>(context, listen: false) ?? AdminController(Get.find<AuthController>()),
        ),
        Provider<ChatController>.value(
          value: Provider.of<ChatController>(context, listen: false) ?? ChatController(),
        ),
      ],
      child: screen,
    );
  }

  // Helper method to build homeowner screens with ChatController provider
  static Widget _buildHomeownerScreen<T extends Widget>(T screen) {
    final context = Get.context;
    if (context == null) {
      throw Exception('Get.context is null. Ensure Get is initialized properly.');
    }
    return Provider<ChatController>.value(
      value: Provider.of<ChatController>(context, listen: false) ?? ChatController(),
      child: screen,
    );
  }

  // Helper method to build contractor screens with ContractorController and ChatController provider
  static Widget _buildContractorScreen<T extends Widget>(T screen) {
    final context = Get.context;
    if (context == null) {
      throw Exception('Get.context is null. Ensure Get is initialized properly.');
    }
    return MultiProvider(
      providers: [
        Provider<ContractorController>.value(
          value: Provider.of<ContractorController>(context, listen: false) ?? ContractorController(Get.find<AuthController>()),
        ),
        Provider<ChatController>.value(
          value: Provider.of<ChatController>(context, listen: false) ?? ChatController(),
        ),
      ],
      child: screen,
    );
  }

  // Helper method to build architect screens with ChatController provider
  static Widget _buildArchitectScreen<T extends Widget>(T screen) {
    final context = Get.context;
    if (context == null) {
      throw Exception('Get.context is null. Ensure Get is initialized properly.');
    }
    return Provider<ChatController>.value(
      value: Provider.of<ChatController>(context, listen: false) ?? ChatController(),
      child: screen,
    );
  }

  // Helper method to build vendor screens with VendorController and ChatController provider
  static Widget _buildVendorScreen<T extends Widget>(T screen) {
    final context = Get.context;
    if (context == null) {
      throw Exception('Get.context is null. Ensure Get is initialized properly.');
    }
    return MultiProvider(
      providers: [
        Provider<VendorController>.value(
          value: Provider.of<VendorController>(context, listen: false) ?? VendorController(Get.find<AuthController>()),
        ),
        Provider<ChatController>.value(
          value: Provider.of<ChatController>(context, listen: false) ?? ChatController(),
        ),
      ],
      child: screen,
    );
  }
}

















/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/adminController.dart'; // Correct import for AdminController
import 'package:buildbuddy/Controllers/authControllers.dart'; // Correct import for AuthController
import 'package:buildbuddy/Models/userModels.dart';

// Core App Screens
import '../Views/Login/boardingScreen.dart';
import '../Views/Login/startedScreen.dart';
import '../Views/Login/welcomeScreen.dart';
import '../Views/Login/loginPage.dart';
import '../Views/Login/signUP.dart';
import '../Views/Login/forgotPassword.dart';
import '../Views/Login/splashScreen.dart';

// Stakeholder Selection
import '../Views/DashBoard/stakeHolderSelection.dart';

// Dashboard Screens
import '../Views/DashBoard/Admin.dart' as AdminDashboard;
import '../Views/DashBoard/HomeOwner.dart';
import '../Views/DashBoard/Constructor.dart' as ConstructorDashboard;
import '../Views/DashBoard/Architect.dart';
import '../Views/DashBoard/Vendor.dart';

// HomeOwner Screens
import '../Views/DashBoard/HomeOwner/findProfessionals.dart';
import '../Views/DashBoard/HomeOwner/settings.dart' as HomeOwnerSettings;
import '../Views/DashBoard/HomeOwner/myProjects.dart';
import '../Views/DashBoard/HomeOwner/messages.dart';
import '../Views/DashBoard/HomeOwner/payments&InvoicesDashboard.dart';
import '../Views/DashBoard/HomeOwner/Rate&ReviewDashboard.dart';
import '../Views/DashBoard/HomeOwner/NotificationsDashboard.dart';
import '../Views/DashBoard/HomeOwner/Help&SupportDashboard.dart';

// Contractor Screens
import '../Views/DashBoard/Contractor/manageProjects.dart';
import '../Views/DashBoard/Contractor/materialOrders.dart';
import '../Views/DashBoard/Contractor/messages.dart';
import '../Views/DashBoard/Contractor/Payments.dart';
import '../Views/DashBoard/Contractor/RatingAndReviews.dart';

// Architect Screens
import '../Views/DashBoard/Architect/messages.dart';
import '../Views/DashBoard/Architect/ViewProjectPlans.dart';
import '../Views/DashBoard/Architect/ReviewContractorTasks.dart';
import '../Views/DashBoard/Architect/SendFeedback&Approvals.dart';
import '../Views/DashBoard/Architect/ConsultWithHomeowners.dart';

// Vendor Screens
import '../Views/DashBoard/Vendor/ordersScreen.dart';
import '../Views/DashBoard/Vendor/invoicesScreen.dart';
import '../Views/DashBoard/Vendor/manageProductsScreen.dart';
import '../Views/DashBoard/Vendor/analytics.dart';
import '../Views/DashBoard/Vendor/notifications.dart';
import '../Views/DashBoard/Vendor/support.dart';
import '../Views/DashBoard/Vendor/messageScreen.dart';
import '../Views/DashBoard/Vendor/Ratings&ReviewsScreen.dart';

// Admin Screens
import '../Views/Login/AdminSignUp.dart';
import '../Views/DashBoard/Admin/userManagement.dart';
import '../Views/DashBoard/Admin/projectMonitoring.dart';
import '../Views/DashBoard/Admin/reports.dart';
import '../Views/DashBoard/Admin/contentManagement.dart';
import '../Views/DashBoard/Admin/settings.dart' as AdminSettings;
import '../Views/DashBoard/Admin/support.dart' as AdminSupport;

// Custom middleware for role-based access control
class RoleBasedMiddleware extends GetMiddleware {
  final UserRole requiredRole;

  RoleBasedMiddleware(this.requiredRole, {super.priority = 1});

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final userData = authController.currentUser.value;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || userData == null) {
      Get.snackbar('Unauthorized', 'Please sign in as a ${requiredRole.name}');
      return const RouteSettings(name: '/stakeholder');
    }

    switch (requiredRole) {
      case UserRole.admin:
        if (!userData.isAdmin) {
          Get.snackbar('Unauthorized', 'Only admins can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.homeowner:
        if (!userData.isHomeowner) {
          Get.snackbar('Unauthorized', 'Only homeowners can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.contractor:
        if (!userData.isContractor) {
          Get.snackbar('Unauthorized', 'Only contractors can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.architect:
        if (!userData.isArchitect) {
          Get.snackbar('Unauthorized', 'Only architects can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.vendor:
        if (!userData.isVendor) {
          Get.snackbar('Unauthorized', 'Only vendors can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
    }
    return null; // Allow navigation if role matches
  }
}

class AppRoutes {
  static final getPages = [
    // Core App Screens
    GetPage(name: '/boarding', page: () => const BoardingScreen()),
    GetPage(name: '/', page: () => const SplashScreen()),
    GetPage(name: '/welcome', page: () => const WelcomeScreen()),
    GetPage(
      name: '/get-started',
      page: () => const GetStartedScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: '/sign-in', page: () => const SignInScreen()),
    GetPage(name: '/sign-up', page: () => const SignUpScreen()),
    GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),

    // Stakeholder Selection
    GetPage(name: '/stakeholder', page: () => const StakeholderSelection()),

    // Admin Routes (Restricted to admin users)
    GetPage(
      name: '/adminSignIn',
      page: () => const AdminSignInScreen(),
    ),
    GetPage(
      name: '/adminSignUp',
      page: () => const AdminSignInScreen(),
    ),
    GetPage(
      name: '/admin-dashboard',
      page: () => _buildAdminScreen(context: Get.context!, screen: const AdminDashboard.AdminDashboard()),
      middlewares: [RoleBasedMiddleware(UserRole.admin)],
    ),
    GetPage(
      name: '/user-management',
      page: () => _buildAdminScreen(context: Get.context!, screen: const UserManagement()),
      middlewares: [RoleBasedMiddleware(UserRole.admin)],
    ),
    GetPage(
      name: '/project-monitoring',
      page: () => _buildAdminScreen(context: Get.context!, screen: const ProjectMonitoring()),
      middlewares: [RoleBasedMiddleware(UserRole.admin)],
    ),
    GetPage(
      name: '/reports',
      page: () => _buildAdminScreen(context: Get.context!, screen: const Reports()),
      middlewares: [RoleBasedMiddleware(UserRole.admin)],
    ),
    GetPage(
      name: '/content-management',
      page: () => _buildAdminScreen(context: Get.context!, screen: const ContentManagement()),
      middlewares: [RoleBasedMiddleware(UserRole.admin)],
    ),
    GetPage(
      name: '/admin-settings',
      page: () => _buildAdminScreen(context: Get.context!, screen: const AdminSettings.Settings()),
      middlewares: [RoleBasedMiddleware(UserRole.admin)],
    ),
    GetPage(
      name: '/admin-support',
      page: () => _buildAdminScreen(context: Get.context!, screen: const AdminSupport.Support()),
      middlewares: [RoleBasedMiddleware(UserRole.admin)],
    ),

    // HomeOwner Dashboard (Restricted to homeowners)
    GetPage(
      name: '/homeowner-dashboard',
      page: () => const HomeOwnerDashboard(),
      transition: Transition.fadeIn,
      middlewares: [RoleBasedMiddleware(UserRole.homeowner)],
    ),
    GetPage(
      name: '/find-professionals',
      page: () => const FindProfessionalsDashboard(),
      middlewares: [RoleBasedMiddleware(UserRole.homeowner)],
    ),
    GetPage(
      name: '/homeowner-settings',
      page: () => const HomeOwnerSettings.SettingsDashboard(),
      middlewares: [RoleBasedMiddleware(UserRole.homeowner)],
    ),
    GetPage(
      name: '/my-projects',
      page: () {
        final userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId';
        return MyProjectsDashboard(userType: 'homeowner');
      },
      middlewares: [RoleBasedMiddleware(UserRole.homeowner)],
    ),
    GetPage(
      name: '/payments',
      page: () => const PaymentsDashboard(),
      middlewares: [RoleBasedMiddleware(UserRole.homeowner)],
    ),
    GetPage(
      name: '/rate-review',
      page: () => const RateReviewDashboard(),
      middlewares: [RoleBasedMiddleware(UserRole.homeowner)],
    ),
    GetPage(
      name: '/notifications',
      page: () => const NotificationsDashboard(),
      middlewares: [RoleBasedMiddleware(UserRole.homeowner)],
    ),
    GetPage(
      name: '/homeowner-support',
      page: () => const SupportDashboard(),
      middlewares: [RoleBasedMiddleware(UserRole.homeowner)],
    ),

    // Contractor Dashboard (Restricted to contractors)
    GetPage(
      name: '/contractor-dashboard',
      page: () => const ConstructorDashboard.ContractorDashboard(),
      transition: Transition.fadeIn,
      middlewares: [RoleBasedMiddleware(UserRole.contractor)],
    ),
    GetPage(
      name: '/manage-projects',
      page: () => const ManageProjectsScreen(userType: 'contractor'),
      middlewares: [RoleBasedMiddleware(UserRole.contractor)],
    ),
    GetPage(
      name: '/material-orders',
      page: () => const MaterialOrdersScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.contractor)],
    ),
    GetPage(
      name: '/contractor-messages',
      page: () => MessagesScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.contractor)],
    ),
    GetPage(
      name: '/contractor-payments',
      page: () => const PaymentsScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.contractor)],
    ),
    GetPage(
      name: '/contractor-reviews',
      page: () => RatingsReviewsScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.contractor)],
    ),

    // Architect Dashboard (Restricted to architects)
    GetPage(
      name: '/architect-dashboard',
      page: () => const ArchitectDashboard(),
      transition: Transition.fadeIn,
      middlewares: [RoleBasedMiddleware(UserRole.architect)],
    ),
    GetPage(
      name: '/architect-messages',
      page: () => ArchitectMessagesScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.architect)],
    ),
    GetPage(
      name: '/consult-homeowners',
      page: () => const ConsultHomeownersScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.architect)],
    ),
    GetPage(
      name: '/review-contractor-tasks',
      page: () => ReviewContractorTasksScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.architect)],
    ),
    GetPage(
      name: '/send-feedback',
      page: () => SendFeedbackScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.architect)],
    ),
    GetPage(
      name: '/view-project-plans',
      page: () => const ViewProjectPlansScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.architect)],
    ),

    // Vendor Dashboard (Restricted to vendors)
    GetPage(
      name: '/vendor-dashboard',
      page: () => const VendorDashboard(),
      transition: Transition.fadeIn,
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
    GetPage(
      name: '/vendor-orders',
      page: () => VendorOrdersScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
    GetPage(
      name: '/vendor-payments',
      page: () => VendorInvoicesScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
    GetPage(
      name: '/manage-products',
      page: () => ManageProductsScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
    GetPage(
      name: '/vendor-invoices',
      page: () => VendorInvoicesScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
    GetPage(
      name: '/vendor-messages',
      page: () => VendorMessages(),
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
    GetPage(
      name: '/vendor-reviews',
      page: () => ReviewVendorTasksScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
    GetPage(
      name: '/vendor-analytics',
      page: () => VendorAnalyticsScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
    GetPage(
      name: '/vendor-notifications',
      page: () => VendorNotificationsScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
    GetPage(
      name: '/vendor-support',
      page: () => VendorSupportScreen(),
      middlewares: [RoleBasedMiddleware(UserRole.vendor)],
    ),
  ];

  static Widget _buildAdminScreen<T extends Widget>({
    required BuildContext context,
    required T screen,
  }) {
    final adminController = Provider.of<AdminController?>(context, listen: false);
    print(
        'Building admin screen: adminController=${adminController != null ? "present" : "null"}, user=${FirebaseAuth.instance.currentUser?.email}, role=${Get.find<AuthController>().currentUser.value?.role}');
    if (adminController == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Access Denied: Admin privileges required',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }
    return Provider<AdminController>.value(
      value: adminController,
      child: screen,
    );
  }
}*/
