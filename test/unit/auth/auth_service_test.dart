/*
import 'package:buildbuddy/Services/auth/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:buildbuddy/Models/userModels.dart';
import '../../auth_service_test.mocks.mocks.dart';

void main() {
  late MockFirebaseAuthMock mockFirebaseAuth;
  late MockGoogleSignInMock mockGoogleSignIn;
  late MockDatabaseReferenceMock mockDatabaseReference;
  late AuthService authService;
  late MockUserCredentialMock mockUserCredential;
  late MockUserMock mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuthMock();
    mockGoogleSignIn = MockGoogleSignInMock();
    mockDatabaseReference = MockDatabaseReferenceMock();
    authService = AuthService(
      auth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      database: mockDatabaseReference,
    );
    mockUserCredential = MockUserCredentialMock();
    mockUser = MockUserMock();
  });

  group('AuthService - signInWithEmailAndPassword', () {
    test('Successful Login - Valid Credentials', () async {
      // Arrange
      final credentials = UserCredentials(
        email: 'valid@example.com',
        password: 'validPassword123',
      );

      when<Future<UserCredential>>(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Future.value(mockUserCredential));
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('some-uid');
      when<DatabaseReference>(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async {
        final mockDataSnapshot = MockDataSnapshotMock();
        when(mockDataSnapshot.value).thenReturn({
          'emailVerified': true,
          'role': 'user', // Changed to match the mock data provided
          'status': 'active',
        });
        when(mockDataSnapshot.exists).thenReturn(true);
        return mockDataSnapshot;
      });

      // Act
      final response = await authService.signInWithEmailAndPassword(credentials);

      // Debug logging
      debugPrint('Response Success: ${response.isSuccess}');
      debugPrint('Response Message: ${response.message}');
      debugPrint('Response UserData: ${response.userData}');

      // Assert
      expect(response.isSuccess, isTrue);
      expect(response.message, contains('Login successful'));
      expect(response.userData, isNotNull);
      expect(response.userData?.emailVerified, isTrue);
      expect(response.userData?.role, equals(UserRole.homeowner)); // Changed to match the mock data provided
    });

    test('Failed Login - Incorrect Password', () async {
      // Arrange
      final credentials = UserCredentials(
        email: 'valid@example.com',
        password: 'wrongPassword',
      );

      when<Future<UserCredential>>(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'wrong-password', message: 'Wrong password.'));

      // Act
      final response = await authService.signInWithEmailAndPassword(credentials);

      // Assert
      expect(response.isSuccess, isFalse);
      expect(response.message, contains('Invalid password'));
      expect(response.userData, isNull);
    });

    test('Failed Login - User Not Found', () async {
      // Arrange
      final credentials = UserCredentials(
        email: 'nonexistent@example.com',
        password: 'password',
      );

      when<Future<UserCredential>>(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found', message: 'No user found for that email.'));

      // Act
      final response = await authService.signInWithEmailAndPassword(credentials);

      // Assert
      expect(response.isSuccess, isFalse);
      expect(response.message, contains('No account found'));
      expect(response.userData, isNull);
    });

    test('Failed Login - Empty Email', () async {
      // Arrange
      final credentials = UserCredentials(
        email: '',
        password: 'password',
      );

      // Act
      final response = await authService.signInWithEmailAndPassword(credentials);

      // Assert
      expect(response.isSuccess, isFalse);
      expect(response.message, contains('Please provide both email and password'));
    });

    test('Failed Login - Email Not Verified', () async {
      // Arrange
      final credentials = UserCredentials(
        email: 'notverified@example.com',
        password: 'password',
      );

      when<Future<UserCredential>>(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Future.value(mockUserCredential));
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('some-uid');
      when<DatabaseReference>(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async {
        final mockDataSnapshot = MockDataSnapshotMock();
        when(mockDataSnapshot.value).thenReturn({
          'emailVerified': false,
          'role': 'contractor', // Assuming contractor requires email verification
        });
        when(mockDataSnapshot.exists).thenReturn(true);
        return mockDataSnapshot;
      });

      // Act
      final response = await authService.signInWithEmailAndPassword(credentials);

      // Assert

      expect(response.isSuccess, isFalse);
      expect(response.message, contains('Please verify your email before logging in'));
    });
  });

  group('AuthService - registerUser', () {
    test('Register User - Successful Registration', () async {
      // Arrange
      final registerData = RegisterUserData(
        email: 'newuser@example.com',
        password: 'newPassword123',
        role: UserRole.contractor,
      );

      when<Future<UserCredential>>(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('new-uid');
      when<DatabaseReference>(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.set(any)).thenAnswer((_) async => {});

      // Act
      final response = await authService.registerUser(registerData);

      // Assert
      expect(response.isSuccess, isTrue);
      expect(response.message, contains('Registration successful'));
      expect(response.userData, isNotNull);
    });

    test('Register User - Email Already In Use', () async {
      // Arrange
      final registerData = RegisterUserData(
        email: 'existing@example.com',
        password: 'newPassword123',
        role: UserRole.contractor,
      );

      when<Future<UserCredential>>(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use', message: 'Email already in use'));

      // Act
      final response = await authService.registerUser(registerData);

      // Assert
      expect(response.isSuccess, isFalse);
      expect(response.message, contains('This email is already registered'));
      expect(response.userData, isNull);
    });

    test('Register User - Invalid Data', () async {
      // Arrange
      final registerData = RegisterUserData(
        email: '', // Empty email
        password: 'short', // Too short password
        role: UserRole.contractor,
      );

      // Act
      final response = await authService.registerUser(registerData);

      // Assert
      expect(response.isSuccess, isFalse);
      expect(response.message, contains('Please fill in all required fields correctly'));
      expect(response.userData, isNull);
    });
  });

}
*/
/*
void main() {
  late MockFirebaseAuthMock mockFirebaseAuth;
  late MockGoogleSignInMock mockGoogleSignIn;
  late MockDatabaseReferenceMock mockDatabaseReference;
  late AuthService authService;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuthMock();
    mockGoogleSignIn = MockGoogleSignInMock();
    mockDatabaseReference = MockDatabaseReferenceMock();
    authService = AuthService(
      auth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      database: mockDatabaseReference,
    );
  });

  group('AuthService - signInWithEmailAndPassword', () {
    test('Successful Login - Valid Credentials', () async {
      // Arrange
      final credentials = UserCredentials(
        email: 'valid@example.com',
        password: 'validPassword123',
      );
      final mockUser = MockUserMock();
      final mockUserCredential = MockUserCredentialMock();

      // Correct the return type to match Future<UserCredential>
      when<Future<UserCredential>>(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Future.value(mockUserCredential));

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('some-uid');
      when<DatabaseReference>(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async {
        final mockDataSnapshot = MockDataSnapshotMock();
        when(mockDataSnapshot.value).thenReturn({
          'emailVerified': true, // Ensure this matches your verification logic
          'role': 'user',
          'status': 'active', // Assuming active status means verified
        });
        when(mockDataSnapshot.exists).thenReturn(true);
        return mockDataSnapshot;
      });

      // Act
      final response = await authService.signInWithEmailAndPassword(credentials);

      // Debug logging
      debugPrint('Response Success: ${response.isSuccess}');
      debugPrint('Response Message: ${response.message}');
      debugPrint('Response UserData: ${response.userData}');

      // Assert
      expect(response.isSuccess, isTrue);
      expect(response.message, contains('Login successful'));
      expect(response.userData, isNotNull);
      expect(response.userData?.emailVerified, isTrue);
      expect(response.userData?.role, equals(UserRole.homeowner));
    });

    // Other test cases...
  });

  // Other test groups...
}*/

