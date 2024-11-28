class Feedback {
  final String id; // UUID
  final String volunteerId; // Relation to User
  final String activityId; // Relation to Activity
  final int rating; // 1 to 5 stars, for example
  final String? comment; // Optional
  final DateTime date; // Date of feedback submission

  Feedback({
    required this.id,
    required this.volunteerId,
    required this.activityId,
    required this.rating,
    this.comment,
    required this.date,
  });

  // Convert Feedback object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'activityId': activityId,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  // Create Feedback object from Firestore map
  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      id: map['id'] as String,
      volunteerId: map['volunteerId'] as String,
      activityId: map['activityId'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      date: DateTime.parse(map['date']),
    );
  }
}
