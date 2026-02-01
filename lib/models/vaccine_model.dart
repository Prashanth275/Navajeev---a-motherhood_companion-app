enum VaccineStatus { upcoming, due, overdue, done }

class Vaccine {
  final String id;
  final String name;
  final String milestone; // e.g. "At Birth", "6 Weeks"
  final int targetDaysFromBirth;

  final String? description;
  final String? protection;
  final String? route;
  final List<String>? sideEffects;
  final String? care;

  // FACTS (stored)
  final DateTime? actualDate;
  final String? notes;

  const Vaccine({
    required this.id,
    required this.name,
    required this.milestone,
    required this.targetDaysFromBirth,
    this.description,
    this.protection,
    this.route,
    this.sideEffects,
    this.care,
    this.actualDate,
    this.notes,
  });

  // 🔹 COMPUTED: Due date (NOT stored)
  DateTime getDueDate(DateTime babyDob) {
    return babyDob.add(Duration(days: targetDaysFromBirth));
  }

  // 🔹 COMPUTED: Status (NOT stored)
  VaccineStatus getStatus(DateTime babyDob) {
    if (actualDate != null) return VaccineStatus.done;

    final dueDate = getDueDate(babyDob);
    final today = DateTime.now();

    if (today.isBefore(dueDate)) {
      return VaccineStatus.upcoming;
    }

    final diff = today.difference(dueDate).inDays;
    if (diff <= 7) {
      return VaccineStatus.due;
    }

    return VaccineStatus.overdue;
  }

  // 🔥 Firestore serialization (FACTS ONLY)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'milestone': milestone,
      'targetDaysFromBirth': targetDaysFromBirth,
      'description': description,
      'protection': protection,
      'route': route,
      'sideEffects': sideEffects,
      'care': care,
      'actualDate': actualDate?.toIso8601String(),
      'notes': notes,
    };
  }

  // 🔥 Firestore → Model
  factory Vaccine.fromFirestore(String id, Map<String, dynamic> data) {
    return Vaccine(
      id: id,
      name: data['name'],
      milestone: data['milestone'],
      targetDaysFromBirth: data['targetDaysFromBirth'],
      description: data['description'],
      protection: data['protection'],
      route: data['route'],
      sideEffects: data['sideEffects'] != null
          ? List<String>.from(data['sideEffects'])
          : null,
      care: data['care'],
      actualDate: data['actualDate'] != null
          ? DateTime.parse(data['actualDate'])
          : null,
      notes: data['notes'],
    );
  }

  // 🔁 Copy with updates
  Vaccine copyWith({
    DateTime? actualDate,
    String? notes,
  }) {
    return Vaccine(
      id: id,
      name: name,
      milestone: milestone,
      targetDaysFromBirth: targetDaysFromBirth,
      description: description,
      protection: protection,
      route: route,
      sideEffects: sideEffects,
      care: care,
      actualDate: actualDate ?? this.actualDate,
      notes: notes ?? this.notes,
    );
  }
}
