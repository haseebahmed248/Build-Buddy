import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Core App Screens
import '../Views/DashBoard/Constructor.dart';
import '../Views/DashBoard/Vendor/Ratings&ReviewsScreen.dart';
import '../Views/DashBoard/Vendor/messageScreen.dart';
import '../Views/Login/boardingscreen.dart';


import '../views/Login/startedScreen.dart';
import '../views/Login/welcomeScreen.dart';
import '../views/Login/loginPage.dart';
import '../views/Login/signUp.dart';
import '../views/Login/forgotPassword.dart';
import '../views/Login/splashScreen.dart';

// Dashboard Screens
import '../views/DashBoard/Admin.dart';
import '../views/DashBoard/HomeOwner.dart';
//import '../views/DashBoard/Contractor.dart';
import '../views/DashBoard/Architect.dart';
import '../views/DashBoard/Vendor.dart';

// Stakeholder Selection
import '../views/DashBoard/stakeholderSelection.dart';

// HomeOwner Screens
import '../views/DashBoard/HomeOwner/findProfessionals.dart';
import '../views/DashBoard/HomeOwner/settings.dart';
import '../views/DashBoard/HomeOwner/myProjects.dart';
import '../views/DashBoard/HomeOwner/messages.dart';
import '../views/DashBoard/HomeOwner/payments&InvoicesDashboard.dart';
import '../views/DashBoard/HomeOwner/Rate&ReviewDashboard.dart';
import '../views/DashBoard/HomeOwner/NotificationsDashboard.dart';
import '../views/DashBoard/HomeOwner/Help&SupportDashboard.dart';

// Contractor Screens
import '../views/DashBoard/Contractor/manageProjects.dart';
import '../views/DashBoard/Contractor/materialOrders.dart';
import '../views/DashBoard/Contractor/messages.dart';
import '../views/DashBoard/Contractor/payments.dart';
import '../views/DashBoard/Contractor/RatingAndReviews.dart';

// Architect Screens
import '../views/DashBoard/Architect/messages.dart';
import '../views/DashBoard/Architect/viewProjectPlans.dart';
import '../views/DashBoard/Architect/reviewContractorTasks.dart';
import '../views/DashBoard/Architect/SendFeedback&Approvals.dart';
import '../views/DashBoard/Architect/ConsultWithHomeowners.dart';


// Vendor Screens
import '../views/DashBoard/Vendor/ordersScreen.dart';
import '../views/DashBoard/Vendor/invoicesScreen.dart';
import '../views/DashBoard/Vendor/manageProductsScreen.dart';
import '../views/DashBoard/Vendor/analytics.dart';
import '../views/DashBoard/Vendor/notifications.dart';
import '../views/DashBoard/Vendor/support.dart';

//Admin Screens
import '../Views/DashBoard/Admin.dart';
import '../views/Login/AdminSignUp.dart';


class AppRoutes {
  static final getPages = [
    // Core App Screens
    GetPage(name: '/boarding', page: () => const BoardingScreen()),
    GetPage(name: '/', page: () => SplashScreen()),
    GetPage(name: '/welcome', page: () => const WelcomeScreen()),

    GetPage(name: '/get-started', page: () => const GetStartedScreen(), transition: Transition.fadeIn),
    GetPage(name: '/sign-in', page: () => const SignInScreen()),
    GetPage(name: '/sign-up', page: () => const SignUpScreen()),
    GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),

    // Stakeholder Selection
    GetPage(name: '/stakeholder', page: () => const StakeholderSelection()),

    ///
    /// Admin Routes
    GetPage(name: '/adminSignIn', page: () => const AdminSignInScreen()),
   // GetPage(name: '/adminDashboard', page: () => const AdminDashboard()),
    ///


    // HomeOwner Dashboard
    GetPage(name: '/homeowner-dashboard', page: () => const HomeOwnerDashboard(), transition: Transition.fadeIn),
    GetPage(name: '/find-professionals', page: () => const FindProfessionalsDashboard()),
    GetPage(name: '/settings', page: () => const SettingsDashboard()),
  GetPage(name: '/my-projects',page: () {
  // Fetch the userId dynamically from Firebase Authentication
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId'; // Get current userId from Firebase Auth
  return MyProjectsDashboard( userType: '',);},),

    //GetPage(name: '/my-projects', page: () => const MyProjectsDashboard()),
    GetPage(name: '/messages', page: () => const MessagesDashboard()),
    GetPage(name: '/payments', page: () => const PaymentsDashboard()),
    GetPage(name: '/rate-review', page: () => const RateReviewDashboard()),
    GetPage(name: '/notifications', page: () => const NotificationsDashboard()),
    GetPage(name: '/support', page: () => const SupportDashboard()),

    // Contractor Dashboard
    GetPage(name: '/contractor-dashboard', page: () => ContractorDashboard(), transition: Transition.fadeIn),
    GetPage(name: '/manage-projects', page: () => ManageProjectsScreen()),
    GetPage(name: '/material-orders', page: () => MaterialOrdersScreen()),
    GetPage(name: '/contractor-messages', page: () => MessagesScreen()),
    GetPage(name: '/contractor-payments', page: () => PaymentsScreen()),
    GetPage(name: '/contractor-reviews', page: () => RatingsReviewsScreen()),

    // Architect Dashboard
    GetPage(name: '/architect-dashboard', page: () => ArchitectDashboard(), transition: Transition.fadeIn),
    GetPage(name: '/architect-messages', page: () => ArchitectMessagesScreen()),
    GetPage(name: '/consult-homeowners', page: () => ConsultHomeownersScreen()),
    GetPage(name: '/review-contractor-tasks', page: () => ReviewContractorTasksScreen()),
    GetPage(name: '/send-feedback', page: () => SendFeedbackScreen()),
    GetPage(name: '/view-project-plans', page: () => ViewProjectPlansScreen()),

    // Vendor Dashboard
    GetPage(name: '/vendor-dashboard', page: () => VendorDashboard(), transition: Transition.fadeIn),
    GetPage(name: '/vendor-orders', page: () => VendorOrdersScreen()),
    GetPage(name: '/vendor-payments', page: () => VendorInvoicesScreen()),
    GetPage(name: '/manage-products', page: () => ManageProductsScreen()),
    GetPage(name: '/vendor-invoices', page: () => VendorInvoicesScreen()),
    GetPage(name: '/vendor-messages', page: () => VendorMessages()),
    GetPage(name: '/vendor-reviews', page: () => ReviewVendorTasksScreen()),

    // New Vendor Screens
    GetPage(name: '/vendor-analytics', page: () => VendorAnalyticsScreen()),
    GetPage(name: '/vendor-notifications', page: () => VendorNotificationsScreen()),
    GetPage(name: '/vendor-support', page: () => VendorSupportScreen()),
  ];
}



















