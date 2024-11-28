class ParticipationHistory {
  final String id; // UUID
  final String volunteerId; // Relation to User
  final String activityId; // Relation to Activity
  final double participationHours;

  ParticipationHistory({
    required this.id,
    required this.volunteerId,
    required this.activityId,
    required this.participationHours,
  });

  // Convert ParticipationHistory object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'activityId': activityId,
      'participationHours': participationHours,
    };
  }

  // Create ParticipationHistory object from Firestore map
  factory ParticipationHistory.fromMap(Map<String, dynamic> map) {
    return ParticipationHistory(
      id: map['id'] as String,
      volunteerId: map['volunteerId'] as String,
      activityId: map['activityId'] as String,
      participationHours: (map['participationHours'] as num).toDouble(),
    );
  }
}
