import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thepg/models/ride_model.dart';

void main() {
  group('RideModel Tests', () {
    test('RideModel should be created with valid data', () {
      final ride = RideModel(
        id: 'ride1',
        passengerId: 'pass1',
        rideType: 'ECONOMY',
        status: 'REQUESTED',
        pickupLocation: '123 Main St',
        dropoffLocation: '456 Oak Ave',
        estimatedFare: 12.50,
      );

      expect(ride.id, 'ride1');
      expect(ride.rideType, 'ECONOMY');
      expect(ride.status, 'REQUESTED');
    });

    test('RideModel.fromJson should parse JSON correctly', () {
      final json = {
        'id': 'ride1',
        'passengerId': 'pass1',
        'rideType': 'ECONOMY',
        'status': 'REQUESTED',
        'pickupLocation': '123 Main St',
        'dropoffLocation': '456 Oak Ave',
        'estimatedFare': 12.50,
      };

      final ride = RideModel.fromJson(json);

      expect(ride.id, 'ride1');
      expect(ride.rideType, 'ECONOMY');
    });

    test('RideModel should support status transitions', () {
      final ride = RideModel(
        id: 'ride1',
        passengerId: 'pass1',
        rideType: 'ECONOMY',
        status: 'REQUESTED',
        pickupLocation: '123 Main St',
        dropoffLocation: '456 Oak Ave',
        estimatedFare: 12.50,
      );

      final acceptedRide = ride.copyWith(status: 'ACCEPTED');

      expect(ride.status, 'REQUESTED');
      expect(acceptedRide.status, 'ACCEPTED');
    });

    test('RideModel should handle null driverId', () {
      final ride = RideModel(
        id: 'ride1',
        passengerId: 'pass1',
        driverId: null,
        rideType: 'ECONOMY',
        status: 'REQUESTED',
        pickupLocation: '123 Main St',
        dropoffLocation: '456 Oak Ave',
        estimatedFare: 12.50,
      );

      expect(ride.driverId, isNull);
    });
  });
}
