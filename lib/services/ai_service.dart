import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  final String baseUrl = "http://10.41.84.24:8000";

  static const Duration _timeout = Duration(seconds: 30);

  Future<Map<String, dynamic>> getInsight({
    required String module,
    int? babyAgeWeeks,
    required Map<String, dynamic> data,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/ai/insight'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'module': module,
        if (babyAgeWeeks != null) 'baby_age_weeks': babyAgeWeeks,
        'data': data,
      }),
    )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Server error ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> getRecommendation({
    int? babyAgeWeeks,
    String? sleepPattern,
    String? feedingPattern,
    String? moodTrend,
    int? pregnancyWeek,
    String? topConcern,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/ai/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (babyAgeWeeks != null) 'baby_age_weeks': babyAgeWeeks,
        if (sleepPattern != null) 'sleep_pattern': sleepPattern,
        if (feedingPattern != null) 'feeding_pattern': feedingPattern,
        if (moodTrend != null) 'mood_trend': moodTrend,
        if (pregnancyWeek != null) 'pregnancy_week': pregnancyWeek,
        if (topConcern != null) 'top_concern': topConcern,
      }),
    )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Server error ${response.statusCode}');
    }
  }
}
final aiService = AiService();
