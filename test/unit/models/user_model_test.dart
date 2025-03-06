/*
import 'package:flutter_test/flutter_test.dart';
import 'package:buildbuddy/Models/userModels.dart';

void main() {
  test('UserModel should serialize from JSON correctly', () {
    final json = {
      'email': 'test@example.com',
      'displayName': 'Test User',
      'photoURL': 'test_url',
      'phoneNumber': '123456789',
      'emailVerified': true,
      'provider': 'password',
      'createdAt': DateTime.now().toIso8601String(),
      'lastLogin': DateTime.now().toIso8601String(),
      'status': 'active'
    };
    final user = UserData.fromJson('1', UserRole.admin, json);
    expect(user.email, equals('test@example.com'));
    expect(user.displayName, equals('Test User'));
    expect(user.status, equals('active'));
  });
}
*/


/*import 'package:flutter_test/flutter_test.dart';
import 'package:buildbuddy/Models/userModels.dart';

void main() {
  test('UserModel should serialize from JSON correctly', () {
    final json = {
      'email': 'test@example.com',
      'displayName': 'Test User',
      'photoURL': 'test_url',
      'phoneNumber': '123456789',
      'emailVerified': true,
      'provider': 'password',
      'createdAt': DateTime.now().toIso8601String(),
      'lastLogin': DateTime.now().toIso8601String(),
      'status': 'active'
    };
    final user = UserData.fromJson('1', UserRole.admin, json);
    expect(user.email, equals('test@example.com'));
    expect(user.displayName, equals('Test User'));
    expect(user.status, equals('active'));
  });

  test('UserModel copyWith should update fields correctly', () {
    final user = UserData(
      uid: '1',
      email: 'test@example.com',
      role: UserRole.contractor,
      emailVerified: false,
      provider: 'password',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    final updatedUser = user.copyWith(displayName: 'Updated Name', emailVerified: true);
    expect(updatedUser.displayName, equals('Updated Name'));
    expect(updatedUser.emailVerified, isTrue);
  });

  test('UserModel name should extract name from email if displayName is null', () {
    final user = UserData(
      uid: '1',
      email: 'test@example.com',
      role: UserRole.vendor,
      emailVerified: true,
      provider: 'google',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    expect(user.name, equals('test'));
  });

  test('UserModel should return correct role permissions', () {
    final user = UserData(
      uid: '1',
      email: 'admin@example.com',
      role: UserRole.admin,
      emailVerified: true,
      provider: 'google',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    expect(user.isAdmin, isTrue);
    expect(user.isHomeowner, isFalse);
  });
}*/


/*
import 'package:flutter_test/flutter_test.dart';
import 'package:buildbuddy/Models/userModels.dart';

void main() {
  test('UserModel should serialize from JSON correctly', () {
    final json = {
      'email': 'test@example.com',
      'displayName': 'Test User',
      'photoURL': 'test_url',
      'phoneNumber': '123456789',
      'emailVerified': true,
      'provider': 'password',
      'createdAt': DateTime.now().toIso8601String(),
      'lastLogin': DateTime.now().toIso8601String(),
      'status': 'active'
    };
    final user = UserData.fromJson('1', UserRole.admin, json);
    expect(user.email, equals('test@example.com'));
    expect(user.displayName, equals('Test User'));
    expect(user.status, equals('active'));
  });

  test('UserModel copyWith should update fields correctly', () {
    final user = UserData(
      uid: '1',
      email: 'test@example.com',
      role: UserRole.contractor,
      emailVerified: false,
      provider: 'password',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    final updatedUser = user.copyWith(displayName: 'Updated Name', emailVerified: true);
    expect(updatedUser.displayName, equals('Updated Name'));
    expect(updatedUser.emailVerified, isTrue);
  });

  test('UserModel name should extract name from email if displayName is null', () {
    final user = UserData(
      uid: '1',
      email: 'test@example.com',
      role: UserRole.vendor,
      emailVerified: true,
      provider: 'google',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    expect(user.name, equals('test'));
  });
}*/
