import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupFirebaseAuthMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register a mock Firebase instance
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase already initialized in tests.");
  }
}
