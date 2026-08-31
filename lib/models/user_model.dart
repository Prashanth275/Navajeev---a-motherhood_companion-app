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

class PartnerDetails {
  final String name;
  final String email;
  final ParentRole role;

  PartnerDetails({
    required this.name,
    required this.email,
    required this.role,
  });

  factory PartnerDetails.fromJson(Map<String, dynamic> json) {
    ParentRole parsedRole;
    try {
      parsedRole = ParentRole.values.byName(json['role'] ?? 'partner');
    } catch (_) {
      parsedRole = ParentRole.partner;
    }

    return PartnerDetails(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: parsedRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
    };
  }
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
  final PartnerDetails? partnerDetails;

  UserModel({
    required this.id,
    required this.name,
    this.role = ParentRole.mother,
    required this.stage,
    this.activeBabyId,
    this.pregnancyDetails,
    this.babyDetails,
    this.partnerDetails,
  });

  bool get isPregnancy => stage == UserStage.pregnancy;
  bool get isPostpartum => stage == UserStage.postpartum;

  DateTime? get babyDob => babyDetails?.dateOfBirth;
}
