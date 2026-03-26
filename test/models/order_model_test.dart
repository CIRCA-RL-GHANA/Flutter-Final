import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thepg/models/order_model.dart';

void main() {
  group('OrderModel Tests', () {
    test('OrderModel should be created with valid data', () {
      final order = OrderModel(
        id: 'order1',
        customerId: 'cust1',
        orderType: 'DELIVERY',
        orderStatus: 'PENDING',
        pickupAddress: '123 Main St',
        dropoffAddress: '456 Oak Ave',
        baseFare: 10.0,
        totalFare: 15.0,
      );

      expect(order.id, 'order1');
      expect(order.orderStatus, 'PENDING');
      expect(order.orderType, 'DELIVERY');
    });

    test('OrderModel.fromJson should parse JSON correctly', () {
      final json = {
        'id': 'order1',
        'customerId': 'cust1',
        'orderType': 'DELIVERY',
        'orderStatus': 'PENDING',
        'pickupAddress': '123 Main St',
        'dropoffAddress': '456 Oak Ave',
        'baseFare': 10.0,
        'totalFare': 15.0,
      };

      final order = OrderModel.fromJson(json);

      expect(order.id, 'order1');
      expect(order.orderStatus, 'PENDING');
    });

    test('OrderModel.toJson should return valid JSON', () {
      final order = OrderModel(
        id: 'order1',
        customerId: 'cust1',
        orderType: 'DELIVERY',
        orderStatus: 'PENDING',
        pickupAddress: '123 Main St',
        dropoffAddress: '456 Oak Ave',
        baseFare: 10.0,
        totalFare: 15.0,
      );

      final json = order.toJson();

      expect(json['id'], 'order1');
      expect(json['orderStatus'], 'PENDING');
    });

    test('OrderModel should track status changes', () {
      final order = OrderModel(
        id: 'order1',
        customerId: 'cust1',
        orderType: 'DELIVERY',
        orderStatus: 'PENDING',
        pickupAddress: '123 Main St',
        dropoffAddress: '456 Oak Ave',
        baseFare: 10.0,
        totalFare: 15.0,
      );

      final updatedOrder = order.copyWith(orderStatus: 'IN_TRANSIT');

      expect(order.orderStatus, 'PENDING');
      expect(updatedOrder.orderStatus, 'IN_TRANSIT');
    });

    test('OrderModel calculated fare should be correct', () {
      final order = OrderModel(
        id: 'order1',
        customerId: 'cust1',
        orderType: 'DELIVERY',
        orderStatus: 'PENDING',
        pickupAddress: '123 Main St',
        dropoffAddress: '456 Oak Ave',
        baseFare: 10.0,
        totalFare: 15.0,
      );

      expect(order.totalFare, greaterThanOrEqualTo(order.baseFare));
    });
  });
}
