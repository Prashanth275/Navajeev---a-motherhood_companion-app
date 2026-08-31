import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navajeev_m/services/growth/growth_analyzer.dart';


class GrowthRecord {
  final String id;
  final DateTime checkInDate;

  /// Snapshot value
  final int ageInDays;

  //Metrics
  final double? weightKg;
  final double? lengthCm;
  final double? headCircumferenceCm;

  // Z-Scores
  final double? zWeightForAge;
  final double? zLengthForAge;
  final double? zWeightForLength;
  final double? zHeadCircumferenceForAge;

  final GrowthStatus? weightStatus;
  final GrowthStatus? lengthStatus;
  final GrowthStatus? proportionalityStatus;
  final GrowthStatus? headCircumferenceStatus;

  final GrowthStatus overallStatus;
  final List<String> concerns;


  GrowthRecord({
    required this.id,
    required this.checkInDate,
    required this.ageInDays,
    this.weightKg,
    this.lengthCm,
    this.headCircumferenceCm,
    this.zWeightForAge,
    this.zLengthForAge,
    this.zWeightForLength,
    this.zHeadCircumferenceForAge,
    this.weightStatus,
    this.lengthStatus,
    this.proportionalityStatus,
    this.headCircumferenceStatus,
    required this.overallStatus,
    required this.concerns,

  });

  // Firestore serialization

  Map<String, dynamic> toFirestore() {
    return {
      'check_in_date': Timestamp.fromDate(checkInDate),
      'age_in_days': ageInDays,
      'metrics': {
        'weight_kg': weightKg,
        'length_cm': lengthCm,
        'head_circumference_cm': headCircumferenceCm,
      },
      'z_scores': {
        'weight_for_age': zWeightForAge,
        'length_for_age': zLengthForAge,
        'weight_for_length': zWeightForLength,
        'head_circumference_for_age': zHeadCircumferenceForAge,
      },
      'status': {
        'weight': weightStatus?.name,
        'length': lengthStatus?.name,
        'proportionality': proportionalityStatus?.name,
        'head_circumference': headCircumferenceStatus?.name,
      },
      'overall_status': overallStatus.name,
      'created_at': FieldValue.serverTimestamp(),
      'concerns': concerns,

    };
  }

  static GrowthRecord fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    final metrics = data['metrics'] as Map<String, dynamic>;
    final z = data['z_scores'] as Map<String, dynamic>;
    final s = data['status'] as Map<String, dynamic>;

    return GrowthRecord(
      id: id,
      checkInDate: (data['check_in_date'] as Timestamp).toDate(),
      ageInDays: data['age_in_days'],
      weightKg: (metrics['weight_kg'] as num?)?.toDouble(),
      lengthCm: (metrics['length_cm'] as num?)?.toDouble(),
      headCircumferenceCm:
      (metrics['head_circumference_cm'] as num?)?.toDouble(),
      zWeightForAge: (z['weight_for_age'] as num?)?.toDouble(),
      zLengthForAge: (z['length_for_age'] as num?)?.toDouble(),
      zWeightForLength: (z['weight_for_length'] as num?)?.toDouble(),
      zHeadCircumferenceForAge:
      (z['head_circumference_for_age'] as num?)?.toDouble(),
      weightStatus: s['weight'] != null
          ? GrowthStatus.values.byName(s['weight'])
          : null,
      lengthStatus: s['length'] != null
          ? GrowthStatus.values.byName(s['length'])
          : null,
      proportionalityStatus: s['proportionality'] != null
          ? GrowthStatus.values.byName(s['proportionality'])
          : null,
      headCircumferenceStatus: s['head_circumference'] != null
          ? GrowthStatus.values.byName(s['head_circumference'])
          : null,
      overallStatus: GrowthStatus.values.byName(data['overall_status']),
      concerns: List<String>.from(data['concerns'] ?? []),

    );
  }
}
