import 'package:cloud_firestore/cloud_firestore.dart';
import 'feeding_enum.dart';

class Feeding {
  final String id;
  final FeedingType type;

  final BottleType? bottleType;
  final BreastSide? breastSide;

  final double? quantity;
  final int? duration;

  final String? foodName;
  final String? notes;

  final DateTime timestamp;

  Feeding({
    required this.id,
    required this.type,
    this.bottleType,
    this.breastSide,
    this.quantity,
    this.duration,
    this.foodName,
    this.notes,
    required this.timestamp,
  });

  // FROM FIRESTORE

  factory Feeding.fromMap(String id, Map<String, dynamic> map) {
    return Feeding(
      id: id,
      type: _parseFeedingType(map['type']),

      bottleType: _parseBottleType(map['bottleType']),
      breastSide: _parseBreastSide(map['breastSide']),

      quantity: (map['quantity'] as num?)?.toDouble(),
      duration: map['duration'] as int?,

      foodName: map['foodName'] as String?,
      notes: map['notes'] as String?,

      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  // TO FIRESTORE

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };

    if (bottleType != null) {
      data['bottleType'] = bottleType!.name;
    }

    if (breastSide != null) {
      data['breastSide'] = breastSide!.name;
    }

    if (quantity != null) {
      data['quantity'] = quantity;
    }

    if (duration != null) {
      data['duration'] = duration;
    }

    if (foodName != null && foodName!.isNotEmpty) {
      data['foodName'] = foodName;
    }

    if (notes != null && notes!.isNotEmpty) {
      data['notes'] = notes;
    }

    return data;
  }
  // SAFE ENUM PARSERS

  static FeedingType _parseFeedingType(dynamic value) {
    try {
      return FeedingType.values
          .firstWhere((e) => e.name == value);
    } catch (_) {
      return FeedingType.breast;
    }
  }

  static BottleType? _parseBottleType(dynamic value) {
    if (value == null) return null;
    try {
      return BottleType.values
          .firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  static BreastSide? _parseBreastSide(dynamic value) {
    if (value == null) return null;
    try {
      return BreastSide.values
          .firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}