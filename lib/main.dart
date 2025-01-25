import 'package:flutter/material.dart';
import 'package:buildbuddy/Routes/app_routes.dart';
import 'package:buildbuddy/Core/Theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize AuthController using GetX
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BuildBuddy',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: AppRoutes.getPages,
    );
  }
}


















