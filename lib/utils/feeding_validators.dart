import '../models/feeding/feeding_enum.dart';

class FeedingValidators {
  static String? validateDuration(
      String? value,
      FeedingType type,
      ) {
    if (type == FeedingType.breast) {
      if (value == null || value.trim().isEmpty) {
        return "Enter duration";
      }

      final number = int.tryParse(value);
      if (number == null || number <= 0) {
        return "Enter valid duration";
      }
    }

    return null;
  }

  static String? validateQuantity(
      String? value,
      FeedingType type,
      ) {
    if (type != FeedingType.breast) {
      if (value == null || value.trim().isEmpty) {
        return "Enter quantity";
      }

      final number = double.tryParse(value);
      if (number == null || number <= 0) {
        return "Enter valid quantity";
      }
    }

    return null;
  }

  static String? validateFoodName(
      String? value,
      FeedingType type,
      ) {
    if (type == FeedingType.solid) {
      if (value == null || value.trim().isEmpty) {
        return "Enter food name";
      }
    }

    return null;
  }

  static String? validateBottleType(
      BottleType? bottleType,
      FeedingType type,
      ) {
    if (type == FeedingType.bottle && bottleType == null) {
      return "Select bottle type";
    }
    return null;
  }

  static String? validateBreastSide(
      BreastSide? breastSide,
      FeedingType type,
      ) {
    if (type == FeedingType.breast && breastSide == null) {
      return "Select breast side";
    }
    return null;
  }
}