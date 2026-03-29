class WhoEntry {
  final double x;
  final double l;
  final double m;
  final double s;

  WhoEntry({
    required this.x,
    required this.l,
    required this.m,
    required this.s,
  });

  factory WhoEntry.fromJson(Map<String, dynamic> json) {

    return WhoEntry(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      l: (json['l'] as num?)?.toDouble() ?? 1.0,
      m: (json['m'] as num?)?.toDouble() ?? 0.0,
      s: (json['s'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

