enum UserStage { pregnancy, postpartum }

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
  final double? birthHeight; // in cm
  final double? birthWeight; // in kg
  final String? deliveryType; // e.g., Normal, C-Section
  final String? feedingType; // e.g., Breastfed, Formula, Mixed

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
  final String name; // Parent name
  final ParentRole role;
  final UserStage stage;
  final PregnancyDetails? pregnancyDetails;
  final BabyDetails? babyDetails;

  UserModel({
    required this.id,
    required this.name,
    this.role = ParentRole.mother, // Default to mother
    required this.stage,
    this.pregnancyDetails,
    this.babyDetails,
  });

  bool get isPregnancy => stage == UserStage.pregnancy;
  bool get isPostpartum => stage == UserStage.postpartum;
}
