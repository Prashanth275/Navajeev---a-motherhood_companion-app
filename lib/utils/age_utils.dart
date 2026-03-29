class AgeUtils {
  static DateTime _normalize(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  static int ageInDays({
    required DateTime dob,
    required DateTime onDate,
  }) {
    final birth = _normalize(dob);
    final check = _normalize(onDate);
    return check.difference(birth).inDays;
  }

  static int ageInWeeks({
    required DateTime dob,
    required DateTime onDate,
  }) {
    return (ageInDays(dob: dob, onDate: onDate) / 7).floor();
  }
  static int ageInMonths({
    required DateTime dob,
    required DateTime onDate,
  }) {
    return ((ageInDays(dob: dob, onDate: onDate)) / 30.4375).floor();
  }
}
