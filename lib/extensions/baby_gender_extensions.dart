import '../models/user_model.dart';

extension BabyGenderWHO on BabyGender {
  String get whoKey {
    switch (this) {
      case BabyGender.boy:
        return 'male';
      case BabyGender.girl:
        return 'female';
      case BabyGender.preferNotToSay:
        throw Exception(
          'WHO growth standards require a known gender',
        );
    }
  }
}
