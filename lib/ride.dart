import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String finalPoint;
  final int review;
  final int price;
  final String startPoint;
  final Timestamp startTime;
  final Timestamp endTime;
  final int distance;

  Ride(
      {required this.finalPoint,
      required this.review,
      required this.price,
      required this.startPoint,
      required this.startTime,
      required this.endTime,
      required this.distance});

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
        finalPoint: map['finalPoint'],
        review: map['review'],
        price: map['price'],
        startPoint: map['startPoint'],
        startTime: map['startTime'],
        endTime: map['endTime'],
        distance: map['distance']);
  }
}
