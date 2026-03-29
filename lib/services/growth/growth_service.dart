import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navajeev_m/models/who_metric.dart';
import '../../extensions/baby_gender_extensions.dart';
import '../../models/growth_record_model.dart';
import '../../models/user_model.dart';
import '../../models/who_entry.dart';
import '../../utils/age_utils.dart';
import 'growth_analyzer.dart';
import '../vaccine/who_data_service.dart';

class GrowthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addGrowthRecord({
    required String babyId,
    required BabyDetails baby,
    required DateTime checkInDate,
    required double weightKg,
    required double lengthCm,
    double? headCircumferenceCm,
  }) async {

// VALIDATIONS
  if (
  checkInDate.isAfter(DateTime.now())) {
    throw Exception('Check-in date cannot be in the future');
  }

  if (checkInDate.isBefore(baby.dateOfBirth)) {
    throw Exception('Check-in date cannot be before date of birth');
  }

  if (weightKg <= 0 || weightKg > 30) {
    throw Exception('Invalid weight value');
  }

  if (lengthCm <= 30 || lengthCm > 120) {
    throw Exception('Invalid length value');
  }

  if (headCircumferenceCm != null &&
      (headCircumferenceCm < 20 || headCircumferenceCm > 60)) {
    throw Exception('Invalid head circumference value');
  }

    final ageDays = AgeUtils.ageInDays(
      dob: baby.dateOfBirth,
      onDate: checkInDate,
    );

    final genderKey = baby.gender.whoKey;
    final wfa = await _lookup(
      genderKey,
      WhoMetric.weightForAge,
      ageDays.toDouble(),
    );

    final lfa = await _lookup(
      genderKey,
      WhoMetric.lengthForAge,
      ageDays.toDouble(),
    );

    final wfl = (lengthCm >= 45 && lengthCm <= 110)
        ? await _lookup(
      genderKey,
      WhoMetric.weightForLength,
      lengthCm,
    )
        : null;


    final hcfa = headCircumferenceCm != null
        ? await _lookup(
      genderKey,
      WhoMetric.headCircumferenceForAge,
      ageDays.toDouble(),
    )
        : null;

    // Z-scores
  final zWfa = GrowthAnalyzer.zScoreLms(
    value: weightKg,
    l: wfa.l,
    m: wfa.m,
    s: wfa.s,
  );

  final zLfa = GrowthAnalyzer.zScoreLms(
    value: lengthCm,
    l: lfa.l,
    m: lfa.m,
    s: lfa.s,
  );

  final zWfl = wfl != null
      ? GrowthAnalyzer.zScoreLms(
    value: weightKg,
    l: wfl.l,
    m: wfl.m,
    s: wfl.s,
  )
      : null;

  final zHcfa = hcfa != null && headCircumferenceCm != null
      ? GrowthAnalyzer.zScoreLms(
    value: headCircumferenceCm,
    l: hcfa.l,
    m: hcfa.m,
    s: hcfa.s,
  )
      : null;


  // Status
    final weightStatus = GrowthAnalyzer.classify(zWfa);
    final lengthStatus = GrowthAnalyzer.classify(zLfa);
    final proportionalityStatus =
    zWfl != null ? GrowthAnalyzer.classify(zWfl) : GrowthStatus.normal;

    final hcStatus =
    zHcfa != null ? GrowthAnalyzer.classify(zHcfa) : null;

    //Overall status
  final overallResult = GrowthAnalyzer.overallStatusWithConcerns(
    weightStatus: weightStatus,
    lengthStatus: lengthStatus,
    proportionalityStatus: proportionalityStatus,
    headStatus: hcStatus,
  );


  // Build record
    final record = GrowthRecord(
      id: '',
      checkInDate: checkInDate,
      ageInDays: ageDays,
      weightKg: weightKg,
      lengthCm: lengthCm,
      headCircumferenceCm: headCircumferenceCm,
      zWeightForAge: zWfa,
      zLengthForAge: zLfa,
      zWeightForLength: zWfl,
      zHeadCircumferenceForAge: zHcfa,
      weightStatus: weightStatus,
      lengthStatus: lengthStatus,
      proportionalityStatus: proportionalityStatus,
      headCircumferenceStatus: hcStatus,
      overallStatus: overallResult.overall,
      concerns: overallResult.concerns,
    );

    //Save to Firestore
    await _db
        .collection('babies')
        .doc(babyId)
        .collection('growth_records')
        .add(record.toFirestore());
  }

  Future<WhoEntry> _lookup(

      String gender,
      WhoMetric metric,
      double x,
      ) async {
    final data =
    await WhoDataService.load(genderKey: gender, metric: metric);
    if (data.isEmpty) {
      throw Exception('WHO data missing for $gender $metric');
    }

    WhoEntry closest = data.first;
    for (final e in data) {
      if ((e.x - x).abs() < (closest.x - x).abs()) {
        closest = e;
      }
    }
    return closest;
  }
}
