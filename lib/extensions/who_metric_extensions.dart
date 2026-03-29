import 'package:navajeev_m/models/who_metric.dart';

extension WhoMetricFileName on WhoMetric {
  String get fileName {
    switch (this) {
      case WhoMetric.weightForAge:
        return 'weight_for_age';
      case WhoMetric.lengthForAge:
        return 'length_for_age';
      case WhoMetric.weightForLength:
        return 'weight_for_length';
      case WhoMetric.headCircumferenceForAge:
        return 'hc_for_age';
    }
  }
}

