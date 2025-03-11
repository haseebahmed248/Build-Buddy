import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Models/userModels.dart';

// Core App Screens
import '../Views/DashBoard/Architect/ConsultWithHomeowners.dart';
import '../Views/DashBoard/Architect/ReviewContractorTasks.dart';
import '../Views/DashBoard/HomeOwner/Help&SupportDashboard.dart';
import '../Views/DashBoard/HomeOwner/HomeOwnerConsultationScreen.dart';
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
import '../Views/DashBoard/Admin.dart' as AdminDashboard;
import '../Views/DashBoard/HomeOwner.dart';
import '../Views/DashBoard/Constructor.dart' as ConstructorDashboard;
import '../Views/DashBoard/Architect.dart';
import '../Views/DashBoard/Vendor.dart';

// Contractor Screens
import '../Views/DashBoard/Contractor/manageProjects.dart';
import '../Views/DashBoard/Contractor/materialOrders.dart';
import '../Views/DashBoard/Contractor/messages.dart';
import '../Views/DashBoard/Contractor/Payments.dart';
import '../Views/DashBoard/Contractor/RatingAndReviews.dart';
import '../Views/DashBoard/Contractor/chatContractor/contractor_chat_screen.dart';
import 'package:buildbuddy/Views/DashBoard/Contractor/materialOrders.dart' as contractor;

// Vendor Screens
import '../Views/DashBoard/Vendor/ordersScreen.dart';
import '../Views/DashBoard/Vendor/invoicesScreen.dart';
import '../Views/DashBoard/Vendor/manageProductsScreen.dart';
import '../Views/DashBoard/Vendor/analytics.dart';
import '../Views/DashBoard/Vendor/notifications.dart';
import '../Views/DashBoard/Vendor/support.dart';
import '../Views/DashBoard/Vendor/messageScreen.dart';
import '../Views/DashBoard/Vendor/Ratings&ReviewsScreen.dart';
import 'package:buildbuddy/Views/DashBoard/Vendor/ordersScreen.dart' as vendor;

// Admin Screens
import '../Views/Login/AdminSignUp.dart';
import '../Views/DashBoard/Admin/userManagement.dart';
import '../Views/DashBoard/Admin/projectMonitoring.dart';
import '../Views/DashBoard/Admin/reports.dart';
import '../Views/DashBoard/Admin/contentManagement.dart';
import '../Views/DashBoard/Admin/settings.dart';
import '../Views/DashBoard/Admin/support.dart';

// Architect Screens
import '../Views/DashBoard/Architect/viewProjectPlans.dart';

// Chat Screen with alias to avoid conflict
import '../Views/DashBoard/chatScreen.dart' as ChatScreenImport;
import '../Views/Shared/HelpandSupport.dart';

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
      print('User not authenticated: redirecting to /stakeholder');
      Get.snackbar('Unauthorized', 'Please sign in as a ${requiredRole.name}');
      return const RouteSettings(name: '/stakeholder');
    }

    switch (requiredRole) {
      case UserRole.admin:
        print('Checking role for admin: userData.role=${userData.role}');
        if (userData.role != UserRole.admin) {
          print('Unauthorized admin access: redirecting to /stakeholder');
          Get.snackbar('Unauthorized', 'Only admins can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.homeowner:
        print('Checking role for homeowner: userData.role=${userData.role}');
        if (userData.role != UserRole.homeowner) {
          print('Unauthorized homeowner access: redirecting to /stakeholder');
          Get.snackbar('Unauthorized', 'Only homeowners can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.contractor:
        print('Checking role for contractor: userData.role=${userData.role}');
        if (userData.role != UserRole.contractor) {
          print('Unauthorized contractor access: redirecting to /stakeholder');
          Get.snackbar('Unauthorized', 'Only contractors can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.architect:
        print('Checking role for architect: userData.role=${userData.role}');
        if (userData.role != UserRole.architect) {
          print('Unauthorized architect access: redirecting to /stakeholder');
          Get.snackbar('Unauthorized', 'Only architects can access this page');
          return const RouteSettings(name: '/stakeholder');
        }
        break;
      case UserRole.vendor:
        print('Checking role for vendor: userData.role=${userData.role}');
        if (userData.role != UserRole.vendor) {
          print('Unauthorized vendor access: redirecting to /stakeholder');
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
      page: () => UserManagement(),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/project-monitoring',
      page: () => ProjectMonitoring(),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/reports',
      page: () => Reports(),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/content-management',
      page: () => ContentManagement(),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/settings',
      page: () => Settings(),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/support',
      page: () => Support(),
      middlewares: [
        RoleBasedMiddleware(UserRole.admin),
      ],
    ),
    GetPage(
      name: '/admin-chat',
      page: () => ChatScreenImport.ChatScreen(projectId: '', projectTitle: ''),
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
      name: '/homeowner-consultations',
      page: () => const HomeOwnerConsultationScreen(),
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
      name: '/homeowner-help',
      page: () => const HelpAndSupportScreen(stakeholderRole: UserRole.homeowner),
      middlewares: [
        RoleBasedMiddleware(UserRole.homeowner),
      ],
    ),
    GetPage(
      name: '/homeowner-chat',
      page: () => ChatScreenImport.ChatScreen(projectId: '', projectTitle: ''),
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
    GetPage(
      name: '/vendor-orders',
      page: () => vendor.MaterialOrdersScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
    GetPage(
      name: '/contractor-messages',
      page: () {
        return const ManageProjectsScreen(userType: 'contractor');
      },
      middlewares: [
        RoleBasedMiddleware(UserRole.contractor),
      ],
    ),
    GetPage(
      name: '/material-orders',
      page: () => const contractor.MaterialOrdersScreen(),
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
      page: () => ContractorRateReviewDashboard(),
      middlewares: [
        RoleBasedMiddleware(UserRole.contractor),
      ],
    ),
    GetPage(
      name: '/contractor-help',
      page: () => const HelpAndSupportScreen(stakeholderRole: UserRole.contractor),
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
      page: () => ChatScreenImport.ChatScreen(projectId: '', projectTitle: ''),
      middlewares: [
        RoleBasedMiddleware(UserRole.architect),
      ],
    ),
    GetPage(
      name: '/view-project-plans',
      page: () => const ViewProjectPlansScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.architect),
      ],
    ),
    GetPage(
      name: '/consult-homeowners',
      page: () => const ConsultArchitectScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.architect),
      ],
    ),
    GetPage(
      name: '/review-contractor-tasks',
      page: () => ReviewContractorTasksScreen(),
      middlewares: [
        RoleBasedMiddleware(UserRole.architect),
      ],
    ),
    GetPage(
      name: '/architect-help',
      page: () => const HelpAndSupportScreen(stakeholderRole: UserRole.architect),
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
    GetPage(
      name: '/vendor-invoices',
      page: () => VendorInvoicesScreen(),
      transition: Transition.fadeIn,
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
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
      page: () => VendorMessages(),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
    GetPage(
      name: '/vendor-reviews',
      page: () => VendorRateReviewDashboard(),
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
    GetPage(
      name: '/vendor-help',
      page: () => const HelpAndSupportScreen(stakeholderRole: UserRole.vendor),
      middlewares: [
        RoleBasedMiddleware(UserRole.vendor),
      ],
    ),
  ];
}















