class OrderModel {
  final String id;
  final String customerId;
  final String orderType;
  final String orderStatus;
  final String pickupAddress;
  final String dropoffAddress;
  final double baseFare;
  final double totalFare;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.orderType,
    required this.orderStatus,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.baseFare,
    required this.totalFare,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        orderType: json['orderType'] as String,
        orderStatus: json['orderStatus'] as String,
        pickupAddress: json['pickupAddress'] as String,
        dropoffAddress: json['dropoffAddress'] as String,
        baseFare: (json['baseFare'] as num).toDouble(),
        totalFare: (json['totalFare'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'orderType': orderType,
        'orderStatus': orderStatus,
        'pickupAddress': pickupAddress,
        'dropoffAddress': dropoffAddress,
        'baseFare': baseFare,
        'totalFare': totalFare,
      };

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? orderType,
    String? orderStatus,
    String? pickupAddress,
    String? dropoffAddress,
    double? baseFare,
    double? totalFare,
  }) =>
      OrderModel(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        orderType: orderType ?? this.orderType,
        orderStatus: orderStatus ?? this.orderStatus,
        pickupAddress: pickupAddress ?? this.pickupAddress,
        dropoffAddress: dropoffAddress ?? this.dropoffAddress,
        baseFare: baseFare ?? this.baseFare,
        totalFare: totalFare ?? this.totalFare,
      );
}
