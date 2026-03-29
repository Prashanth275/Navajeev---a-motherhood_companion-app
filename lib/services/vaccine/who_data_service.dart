import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:navajeev_m/models/who_entry.dart';
import 'package:navajeev_m/models/who_metric.dart';

class WhoDataService {
  static final Map<String, List<WhoEntry>> _cache = {};
  static Future<List<WhoEntry>> load({
    required String genderKey,
    required WhoMetric metric,
  }) async {
    final gender = genderKey.replaceAll('/', '');

    final cacheKey = '$gender-${metric.name}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final path = _path(gender, metric);

    debugPrint('WHO ASSET PATH => $path');

    final raw = await rootBundle.loadString(path);
    final List decoded = json.decode(raw);

    final entries = decoded
        .map((e) => WhoEntry.fromJson(e))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    _cache[cacheKey] = entries;
    return entries;
  }

  static String _path(String gender, WhoMetric metric) {
    final base = 'who_growth/$gender/';

    if (metric == WhoMetric.weightForAge) {
      return '${base}weight_for_age.json';
    }
    if (metric == WhoMetric.lengthForAge) {
      return '${base}length_for_age.json';
    }
    if (metric == WhoMetric.weightForLength) {
      return '${base}weight_for_length.json';
    }
    if (metric == WhoMetric.headCircumferenceForAge) {
      return '${base}hc_for_age.json';
    }

    throw Exception('Unknown WhoMetric: $metric');
  }
}