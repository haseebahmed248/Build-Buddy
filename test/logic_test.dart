import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:buildbuddy/Controllers/authControllers.dart';
import 'package:buildbuddy/Services/auth/authService.dart';
import 'package:buildbuddy/Models/userModels.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

i
@GenerateMocks([AuthService, FirebaseAuth, User])
void main() {
  late AuthController authController;
  late MockAuthService mockAuthService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    when(mockUser.uid).thenReturn('test-user-id');
    when(mockUser.emailVerified).thenReturn(false);

    authController = AuthController();
    authController._authService = mockAuthService;
    authController._auth = mockFirebaseAuth;

    Get.reset();
    Get.testMode = true; // Turn on test mode for GetX
  });

  group('AuthController Tests', () {
    test('Verify no null checks needed in updateEmailVerificationStatus', () async {
      // Arrange
      final testUserData = UserData(
        uid: 'test-user-id',
        email: 'test@example.com',
        role: UserRole.contractor,
        emailVerified: false,
        provider: 'email',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        status: 'active',
      );
      authController.currentUser.value = testUserData;

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.reload()).thenAnswer((_) async => {});

      // Act
      await authController.updateEmailVerificationStatus();

      // Assert
      // Verify that the method was called with non-null parameters
      verify(mockAuthService.updateEmailVerificationStatus(
        'test-user-id',
        false,
        UserRole.contractor,
      )).called(1);

      // Check if currentUser was updated correctly
      expect(authController.currentUser.value?.emailVerified, isFalse);
      expect(authController.isEmailVerified, isFalse);
    });

    test('updateEmailVerificationStatus with verified email', () async {
      // Arrange
      final testUserData = UserData(
        uid: 'test-user-id',
        email: 'test@example.com',
        role: UserRole.contractor,
        emailVerified: false,
        provider: 'email',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        status: 'active',
      );
      authController.currentUser.value = testUserData;

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.reload()).thenAnswer((_) async => {});
      when(mockUser.emailVerified).thenReturn(true);

      // Act
      await authController.updateEmailVerificationStatus();

      // Assert
      verify(mockAuthService.updateEmailVerificationStatus(
        'test-user-id',
        true,
        UserRole.contractor,
      )).called(1);

      expect(authController.currentUser.value?.emailVerified, isTrue);
      expect(authController.isEmailVerified, isTrue);

      // Verify snackbar was shown for email verification
      verify(Get.snackbar(
        'Email Verified',
        'Your email has been verified',
        snackPosition: anyNamed('snackPosition'),
        backgroundColor: anyNamed('backgroundColor'),
        colorText: anyNamed('colorText'),
      )).called(1);
    });
  });
}