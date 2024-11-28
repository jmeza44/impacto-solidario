enum AttendanceStatus { registered, attended, absent }

class Participation {
  final String id; // UUID
  final String volunteerId; // Relation to User
  final String activityId; // Relation to Activity
  final AttendanceStatus attendanceStatus;
  final DateTime registrationDate; // When the participation was registered
  final double? participationHours; // Optional, calculated after the activity

  Participation({
    required this.id,
    required this.volunteerId,
    required this.activityId,
    required this.attendanceStatus,
    required this.registrationDate,
    this.participationHours,
  });

  // Convert Participation object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'activityId': activityId,
      'attendanceStatus': attendanceStatus.name, // Store as String
      'registrationDate': registrationDate.toIso8601String(),
      'participationHours': participationHours,
    };
  }

  // Create Participation object from Firestore map
  factory Participation.fromMap(Map<String, dynamic> map) {
    return Participation(
      id: map['id'] as String,
      volunteerId: map['volunteerId'] as String,
      activityId: map['activityId'] as String,
      attendanceStatus: AttendanceStatus.values
          .firstWhere((e) => e.name == map['attendanceStatus']),
      registrationDate: DateTime.parse(map['registrationDate']),
      participationHours: (map['participationHours'] ?? 0 as num?)?.toDouble(),
    );
  }
}
