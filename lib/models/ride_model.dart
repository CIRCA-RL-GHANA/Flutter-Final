class RideModel {
  final String id;
  final String passengerId;
  final String? driverId;
  final String rideType;
  final String status;
  final String pickupLocation;
  final String dropoffLocation;
  final double estimatedFare;

  const RideModel({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.rideType,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.estimatedFare,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) => RideModel(
        id: json['id'] as String,
        passengerId: json['passengerId'] as String,
        driverId: json['driverId'] as String?,
        rideType: json['rideType'] as String,
        status: json['status'] as String,
        pickupLocation: json['pickupLocation'] as String,
        dropoffLocation: json['dropoffLocation'] as String,
        estimatedFare: (json['estimatedFare'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'passengerId': passengerId,
        'driverId': driverId,
        'rideType': rideType,
        'status': status,
        'pickupLocation': pickupLocation,
        'dropoffLocation': dropoffLocation,
        'estimatedFare': estimatedFare,
      };

  RideModel copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    String? rideType,
    String? status,
    String? pickupLocation,
    String? dropoffLocation,
    double? estimatedFare,
  }) =>
      RideModel(
        id: id ?? this.id,
        passengerId: passengerId ?? this.passengerId,
        driverId: driverId ?? this.driverId,
        rideType: rideType ?? this.rideType,
        status: status ?? this.status,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        dropoffLocation: dropoffLocation ?? this.dropoffLocation,
        estimatedFare: estimatedFare ?? this.estimatedFare,
      );
}
