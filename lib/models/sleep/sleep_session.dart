import 'package:cloud_firestore/cloud_firestore.dart';

class SleepSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isNight;

  SleepSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isNight,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isNight': isNight,
    };
  }

  factory SleepSession.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SleepSession(
      id: doc.id,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      isNight: data['isNight'] ?? false,
    );
  }
}