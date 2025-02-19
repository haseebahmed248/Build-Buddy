import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

// ✅ Create Mock Classes for Dependencies
@GenerateMocks([FirebaseAuth, GoogleSignIn, DatabaseReference, UserCredential])
void setupMockAuthService() {}
