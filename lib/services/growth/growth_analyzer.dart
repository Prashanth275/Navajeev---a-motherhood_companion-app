import 'dart:math' as math;

enum GrowthStatus { normal, aboveNormal, belowNormal }
class OverallResult {
  final GrowthStatus overall;
  final List<String> concerns;

  OverallResult({
    required this.overall,
    required this.concerns,
  });
}


extension GrowthStatusLabel on GrowthStatus {
  String get label {
    switch (this) {
      case GrowthStatus.normal:
        return 'Normal growth';
      case GrowthStatus.aboveNormal:
        return 'Above normal range';
      case GrowthStatus.belowNormal:
        return 'Below normal range';
    }
  }
}

class GrowthAnalyzer {
  static double zScoreLms({
    required double value,
    required double l,
    required double m,
    required double s,
  }) {
    if (value <= 0 || m <= 0 || s <= 0) {
      return double.nan;
    }

    if (l == 0) {
      return math.log(value / m) / s;
    }

    try {
      return (math.pow(value / m, l) - 1) / (l * s);
    } catch (_) {
      return double.nan;
    }
  }

  static double valueAtZ({
    required double z,
    required double l,
    required double m,
    required double s,
  }) {
    if (m <= 0 || s <= 0) return double.nan;

    if (l == 0) {
      return m * math.exp(s * z);
    }

    final base = 1 + (l * s * z);
    if (base <= 0) return double.nan;

    try {
      final value = m * math.pow(base, 1 / l);
      return (value.isNaN || value.isInfinite)
          ? double.nan
          : value;
    } catch (_) {
      return double.nan;
    }
  }

  static GrowthStatus classify(double z) {
    if (z.isNaN) return GrowthStatus.normal;
    if (z < -2) return GrowthStatus.belowNormal;
    if (z > 2) return GrowthStatus.aboveNormal;
    return GrowthStatus.normal;
  }

  static OverallResult overallStatusWithConcerns({
    required GrowthStatus? weightStatus,
    required GrowthStatus? lengthStatus,
    required GrowthStatus? proportionalityStatus,
    GrowthStatus? headStatus,
  }) {
    final List<String> concerns = [];
    final List<GrowthStatus> allStatuses = [
      if (weightStatus != null) weightStatus,
      if (lengthStatus != null) lengthStatus,
      if (proportionalityStatus != null) proportionalityStatus,
      if (headStatus != null) headStatus,
    ];

    // Collect concerns
    if (weightStatus != null) {
      if (weightStatus == GrowthStatus.belowNormal) {
        concerns.add("Weight below expected range");
      } else if (weightStatus == GrowthStatus.aboveNormal) {
        concerns.add("Weight above expected range");
      }
    }

    if (lengthStatus != null) {
      if (lengthStatus == GrowthStatus.belowNormal) {
        concerns.add("Height below expected range");
      } else if (lengthStatus == GrowthStatus.aboveNormal) {
        concerns.add("Height above expected range");
      }
    }

    if (proportionalityStatus != null) {
      if (proportionalityStatus == GrowthStatus.belowNormal) {
        concerns.add("Weight-for-length below expected range");
      } else if (proportionalityStatus == GrowthStatus.aboveNormal) {
        concerns.add("Weight-for-length above expected range");
      }
    }

    if (headStatus != null) {
      if (headStatus == GrowthStatus.belowNormal) {
        concerns.add("Head circumference below expected range");
      } else if (headStatus == GrowthStatus.aboveNormal) {
        concerns.add("Head circumference above expected range");
      }
    }

    GrowthStatus overall;
    if (allStatuses.contains(GrowthStatus.belowNormal)) {
      overall = GrowthStatus.belowNormal;
    } else if (allStatuses.contains(GrowthStatus.aboveNormal)) {
      overall = GrowthStatus.aboveNormal;
    } else {
      overall = GrowthStatus.normal;
    }

    return OverallResult(
      overall: overall,
      concerns: concerns,
    );
  }
}
