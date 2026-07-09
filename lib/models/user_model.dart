enum UserStage { onboarding, pregnancy, postpartum }

enum ParentRole { mother, partner, caregiver }

enum BabyGender { boy, girl, preferNotToSay }

class PregnancyDetails {
  final DateTime expectedDueDate;
  final bool enableNotifications;

  PregnancyDetails({
    required this.expectedDueDate,
    this.enableNotifications = true,
  });
}

class BabyDetails {
  final String name;
  final DateTime dateOfBirth;
  final BabyGender gender;
  final double? birthHeight;
  final double? birthWeight;
  final String? deliveryType;
  final String? feedingType;

  BabyDetails({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.birthHeight,
    this.birthWeight,
    this.deliveryType,
    this.feedingType,
  });
}

class UserModel {
  final String id;
  final String name;
  final ParentRole role;
  final UserStage stage;

  /// NEW (for new schema)
  final String? activeBabyId;

  /// Optional details
  final PregnancyDetails? pregnancyDetails;
  final BabyDetails? babyDetails;

  UserModel({
    required this.id,
    required this.name,
    this.role = ParentRole.mother,
    required this.stage,
    this.activeBabyId,
    this.pregnancyDetails,
    this.babyDetails,
  });

  // Derived helpers
  bool get isPregnancy => stage == UserStage.pregnancy;
  bool get isPostpartum => stage == UserStage.postpartum;

  DateTime? get babyDob => babyDetails?.dateOfBirth;
}
