import '../../models/trimester/trimester_week_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class TrimesterRepository {

  // WEEK CALCULATION

  int calculateCurrentWeek(DateTime dueDate) {
    final now = DateTime.now();

    final pregnancyStartDate =
    dueDate.subtract(const Duration(days: 280));

    final daysPassed =
        now.difference(pregnancyStartDate).inDays;

    int week = (daysPassed / 7).floor();

    if (week < 1) week = 1;
    if (week > 40) week = 40;

    return week;
  }

  int mapWeekToTrimester(int week) {
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  // FRUIT MILESTONES

  static const Map<int, String> _fruitMap = {
    4: "Poppy Seed",
    6: "Lentil",
    8: "Raspberry",
    10: "Strawberry",
    12: "Lime",
    14: "Peach",
    16: "Avocado",
    18: "Bell Pepper",
    20: "Banana",
    24: "Corn",
    28: "Eggplant",
    32: "Coconut",
    36: "Papaya",
    40: "Watermelon",
  };

  static final List<int> _sortedMilestones =
  _fruitMap.keys.toList()..sort();

  String _getFruitForWeek(int week) {
    String currentFruit = "Fruit";

    for (final milestone in _sortedMilestones) {
      if (week >= milestone) {
        currentFruit = _fruitMap[milestone]!;
      } else {
        break;
      }
    }

    return currentFruit;
  }

  // JSON DATA STORAGE

  static final Map<int, double> _sizeMap = {};
  static final Map<int, List<String>> _symptomMap = {};
  static final Map<int, List<String>> _tipsMap = {};
  static final Map<int, String?> _importantMap = {};

  static bool _isLoaded = false;


  Future<void> _loadSizeData() async {
    if (_isLoaded) return;

    final jsonString = await rootBundle
        .loadString('assets/size_data/trimester_weeks.json');

    final List<dynamic> jsonData = json.decode(jsonString);

    for (final item in jsonData) {

      final int week = (item['weekNumber'] ?? 1) as int;

      _sizeMap[week] =
          (item['babySizeCm'] as num?)?.toDouble() ?? 0.0;

      _symptomMap[week] =
      List<String>.from(item['symptoms'] ?? []);

      _tipsMap[week] =
      List<String>.from(item['tips'] ?? []);

      _importantMap[week] =
      item['important'] as String?;
    }

    _isLoaded = true;
  }

  double _getSizeForWeek(int week) {
    return _sizeMap[week] ?? 0.0;
  }

  Future<TrimesterWeekModel> getWeekData(int week) async {
    await _loadSizeData();

    final trimester = mapWeekToTrimester(week);
    final fruitName = _getFruitForWeek(week);
    final babySize = _getSizeForWeek(week);
    final symptoms = _symptomMap[week] ?? [];
    final tips = _tipsMap[week] ?? [];
    final important = _importantMap[week];

    return TrimesterWeekModel(
      weekNumber: week,
      trimester: trimester,
      babySizeCm: babySize,
      fruitName: fruitName,
      symptoms: symptoms,
      tips: tips,
      importantNote: important,
    );
  }
}