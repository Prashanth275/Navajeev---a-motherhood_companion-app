enum AppointmentType { checkup, specialist, scan, dental, urgent }

class Appointment {
  final String id;
  final String doctorName;
  final String hospitalName;
  final DateTime scheduledAt;
  final AppointmentType type;
  final String reason;
  final bool isCompleted;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.hospitalName,
    required this.scheduledAt,
    required this.type,
    required this.reason,
    this.isCompleted = false,
  });

  factory Appointment.fromFirestore(String id, Map<String, dynamic> data) {
    return Appointment(
      id: id,
      doctorName: data['doctorName'] ?? '',
      hospitalName: data['hospitalName'] ?? '',
      scheduledAt: DateTime.parse(data['scheduledAt']),
      type: AppointmentType.values.byName(data['type'] ?? 'checkup'),
      reason: data['reason'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'doctorName': doctorName,
    'hospitalName': hospitalName,
    'scheduledAt': scheduledAt.toIso8601String(),
    'type': type.name,
    'reason': reason,
    'isCompleted': isCompleted,
  };
}