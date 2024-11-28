enum ActivityStatus { active, completed, canceled }

class Activity {
  final String id; // UUID
  final String title;
  final String description;
  final DateTime date; // Date of the activity
  final String location;
  final String category;
  final int maxVolunteers; // Maximum number of volunteers
  final ActivityStatus status; // Status of the activity
  final String creatorId; // ID of the admin who created the activity
  final DateTime creationDate; // Date the activity was created
  final DateTime lastUpdateDate; // Date the activity was last updated

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.maxVolunteers,
    required this.status,
    required this.creatorId,
    required this.creationDate,
    required this.lastUpdateDate,
  });

  // Convert Activity object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'category': category,
      'maxVolunteers': maxVolunteers,
      'status': status.name, // Store enum as string
      'creatorId': creatorId,
      'creationDate': creationDate.toIso8601String(),
      'lastUpdateDate': lastUpdateDate.toIso8601String(),
    };
  }

  // Create Activity object from Firestore map
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date']),
      location: map['location'] as String,
      category: map['category'] as String,
      maxVolunteers: map['maxVolunteers'] as int,
      status: ActivityStatus.values.firstWhere((e) => e.name == map['status']),
      creatorId: map['creatorId'] as String,
      creationDate: DateTime.parse(map['creationDate']),
      lastUpdateDate: DateTime.parse(map['lastUpdateDate']),
    );
  }
}
