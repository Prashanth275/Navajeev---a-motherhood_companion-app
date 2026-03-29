import 'package:cloud_firestore/cloud_firestore.dart';

class WellbeingEntry {
  final String id;
  final DateTime date;
  final int mood;
  final int energy;
  final int stress;
  final int sleepQuality;
  final String notes;
  final String stage;

  WellbeingEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.energy,
    required this.stress,
    required this.sleepQuality,
    required this.notes,
    required this.stage,
  });

  factory WellbeingEntry.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    return WellbeingEntry(
      id: id,
      date: (map['date'] as Timestamp).toDate(),
      mood: map['mood'] ?? 3,
      energy: map['energy'] ?? 3,
      stress: map['stress'] ?? 3,
      sleepQuality: map['sleepQuality'] ?? 3,
      notes: map['notes'] ?? '',
      stage: map['stage'] ?? 'pregnancy',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'mood': mood,
      'energy': energy,
      'stress': stress,
      'sleepQuality': sleepQuality,
      'notes': notes,
      'stage': stage,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}