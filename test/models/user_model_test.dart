import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thepg/models/user_model.dart';
import 'package:thepg/services/user_service.dart';

// Mock classes
class MockUserService extends Mock implements UserService {}

void main() {
  group('UserModel Tests', () {
    late MockUserService mockUserService;

    setUp(() {
      mockUserService = MockUserService();
    });

    test('UserModel should be created with valid data', () {
      final user = UserModel(
        id: '1',
        email: 'test@test.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        userType: 'CUSTOMER',
      );

      expect(user.id, '1');
      expect(user.email, 'test@test.com');
      expect(user.firstName, 'John');
      expect(user.fullName, 'John Doe');
    });

    test('UserModel.fromJson should parse JSON correctly', () {
      final json = {
        'id': '1',
        'email': 'test@test.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'phoneNumber': '+1234567890',
        'userType': 'CUSTOMER',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '1');
      expect(user.email, 'test@test.com');
    });

    test('UserModel.toJson should return valid JSON', () {
      final user = UserModel(
        id: '1',
        email: 'test@test.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        userType: 'CUSTOMER',
      );

      final json = user.toJson();

      expect(json['id'], '1');
      expect(json['email'], 'test@test.com');
    });

    test('UserModel equality should work correctly', () {
      final user1 = UserModel(
        id: '1',
        email: 'test@test.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        userType: 'CUSTOMER',
      );

      final user2 = UserModel(
        id: '1',
        email: 'test@test.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        userType: 'CUSTOMER',
      );

      expect(user1, user2);
    });
  });
}
