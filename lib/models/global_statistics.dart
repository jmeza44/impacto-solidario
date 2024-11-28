class GlobalStatistics {
  final String id; // UUID
  final int totalVolunteers;
  final int totalActivities;
  final double totalServiceHours;

  GlobalStatistics({
    required this.id,
    required this.totalVolunteers,
    required this.totalActivities,
    required this.totalServiceHours,
  });

  // Convert GlobalStatistics object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalVolunteers': totalVolunteers,
      'totalActivities': totalActivities,
      'totalServiceHours': totalServiceHours,
    };
  }

  // Create GlobalStatistics object from Firestore map
  factory GlobalStatistics.fromMap(Map<String, dynamic> map) {
    return GlobalStatistics(
      id: map['id'] as String,
      totalVolunteers: map['totalVolunteers'] as int,
      totalActivities: map['totalActivities'] as int,
      totalServiceHours: (map['totalServiceHours'] as num).toDouble(),
    );
  }
}
