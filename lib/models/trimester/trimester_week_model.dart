class TrimesterWeekModel {
  final int weekNumber;
  final int trimester;
  final double babySizeCm;
  final String fruitName;
  final List<String> symptoms;
  final List<String> tips;
  final String? importantNote;

  TrimesterWeekModel({
    required this.weekNumber,
    required this.trimester,
    required this.babySizeCm,
    required this.fruitName,
    required this.symptoms,
    required this.tips,
    this.importantNote,
  });

  factory TrimesterWeekModel.fromMap(Map<String, dynamic> map) {
    return TrimesterWeekModel(
      weekNumber: map['weekNumber'] ?? 1,
      trimester: map['trimester'] ?? 1,
      babySizeCm: (map['babySizeCm'] as num?)?.toDouble() ?? 0.0,
      fruitName: map['fruitName'] ?? "Fruit",
      symptoms: List<String>.from(map['symptoms'] ?? []),
      tips: List<String>.from(map['tips'] ?? []),
      importantNote: map['important'] as String?,
    );
  }
}