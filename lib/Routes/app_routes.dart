import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

// Core App Screens
import '../Views/DashBoard/Constructor.dart';
import '../Views/DashBoard/Vendor/Ratings&ReviewsScreen.dart';
import '../Views/DashBoard/Vendor/messageScreen.dart';
import '../Views/Login/boardingScreen.dart';

import '../Views/Login/startedScreen.dart';
import '../Views/Login/welcomeScreen.dart';
import '../Views/Login/loginPage.dart';
import '../Views/Login/signUP.dart';
import '../Views/Login/forgotPassword.dart';
import '../Views/Login/splashScreen.dart';

// Dashboard Screens
import '../Views/DashBoard/Admin.dart';
import '../Views/DashBoard/HomeOwner.dart';
//import '../views/DashBoard/Contractor.dart';
import '../Views/DashBoard/Architect.dart';
import '../Views/DashBoard/Vendor.dart';

// Stakeholder Selection
import '../Views/DashBoard/stakeHolderSelection.dart';

// HomeOwner Screens
import '../Views/DashBoard/HomeOwner/findProfessionals.dart';
import '../Views/DashBoard/HomeOwner/settings.dart';
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

//Admin Screens
import '../Views/DashBoard/Admin.dart';
import '../Views/Login/AdminSignUp.dart';

class AppRoutes {
  static final getPages = [
    // Core App Screens
    GetPage(name: '/boarding', page: () => const BoardingScreen()),
    GetPage(name: '/', page: () => SplashScreen()),
    GetPage(name: '/welcome', page: () => const WelcomeScreen()),

    GetPage(
        name: '/get-started',
        page: () => const GetStartedScreen(),
        transition: Transition.fadeIn),
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
    GetPage(
        name: '/homeowner-dashboard',
        page: () => const HomeOwnerDashboard(),
        transition: Transition.fadeIn),
    GetPage(
        name: '/find-professionals',
        page: () => const FindProfessionalsDashboard()),
    GetPage(name: '/settings', page: () => const SettingsDashboard()),
    /*GetPage(
      name: '/my-projects',
      page: () {
        // Fetch the userId dynamically from Firebase Authentication
        final userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId';

        // Define userType based on some logic, for example, from Firestore or another source
        final userType = "homeowner"; // Example, you can replace this with dynamic logic

        // Pass the userId and userType to the route
        Get.toNamed('/my-projects', arguments: {'userId': userId, 'userType': userType});
        return Container(); // return an empty container (or handle differently)
      },
    ),*/


    GetPage(
      name: '/my-projects',
      page: () {
        // Fetch the userId dynamically from Firebase Authentication
        final userId = FirebaseAuth.instance.currentUser?.uid ??
            'defaultUserId'; // Get current userId from Firebase Auth
        return MyProjectsDashboard(
          userType: '',
        );
      },
    ),

    //GetPage(name: '/my-projects', page: () => const MyProjectsDashboard()),
    GetPage(name: '/messages', page: () => const MessagesDashboard()),
    GetPage(name: '/payments', page: () => const PaymentsDashboard()),
    GetPage(name: '/rate-review', page: () => const RateReviewDashboard()),
    GetPage(name: '/notifications', page: () => const NotificationsDashboard()),
    GetPage(name: '/support', page: () => const SupportDashboard()),

    // Contractor Dashboard
    GetPage(
        name: '/contractor-dashboard',
        page: () => ContractorDashboard(),
        transition: Transition.fadeIn),
    GetPage(name: '/manage-projects', page: () => ManageProjectsScreen()),
    GetPage(name: '/material-orders', page: () => MaterialOrdersScreen()),
    GetPage(name: '/contractor-messages', page: () => MessagesScreen()),
    GetPage(name: '/contractor-payments', page: () => PaymentsScreen()),
    GetPage(name: '/contractor-reviews', page: () => RatingsReviewsScreen()),

    // Architect Dashboard
    GetPage(
        name: '/architect-dashboard',
        page: () => ArchitectDashboard(),
        transition: Transition.fadeIn),
    GetPage(name: '/architect-messages', page: () => ArchitectMessagesScreen()),
    GetPage(name: '/consult-homeowners', page: () => ConsultHomeownersScreen()),
    GetPage(
        name: '/review-contractor-tasks',
        page: () => ReviewContractorTasksScreen()),
    GetPage(name: '/send-feedback', page: () => SendFeedbackScreen()),
    GetPage(name: '/view-project-plans', page: () => ViewProjectPlansScreen()),

    // Vendor Dashboard
    GetPage(
        name: '/vendor-dashboard',
        page: () => VendorDashboard(),
        transition: Transition.fadeIn),
    GetPage(name: '/vendor-orders', page: () => VendorOrdersScreen()),
    GetPage(name: '/vendor-payments', page: () => VendorInvoicesScreen()),
    GetPage(name: '/manage-products', page: () => ManageProductsScreen()),
    GetPage(name: '/vendor-invoices', page: () => VendorInvoicesScreen()),
    GetPage(name: '/vendor-messages', page: () => VendorMessages()),
    GetPage(name: '/vendor-reviews', page: () => ReviewVendorTasksScreen()),

    // New Vendor Screens
    GetPage(name: '/vendor-analytics', page: () => VendorAnalyticsScreen()),
    GetPage(
        name: '/vendor-notifications', page: () => VendorNotificationsScreen()),
    GetPage(name: '/vendor-support', page: () => VendorSupportScreen()),
  ];
}
