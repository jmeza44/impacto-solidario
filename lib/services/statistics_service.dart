import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/global_statistics.dart';
import '../models/user.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get global statistics
  Future<GlobalStatistics> getGlobalStatistics() async {
    try {
      // Get the total number of volunteers
      QuerySnapshot volunteersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.volunteer.name)
          .get();
      int totalVolunteers = volunteersSnapshot.docs.length;

      // Get the total number of activities
      QuerySnapshot activitiesSnapshot =
          await _firestore.collection('activities').get();
      int totalActivities = activitiesSnapshot.docs.length;

      // Get total service hours by summing up participation hours from 'participations' collection
      QuerySnapshot participationsSnapshot =
          await _firestore.collection('participations').get();
      double totalServiceHours =
          participationsSnapshot.docs.fold(0.0, (double sum, doc) {
        double hours = (doc['participationHours'] as num?)?.toDouble() ?? 0.0;
        return sum + hours;
      });

      // Create and return GlobalStatistics
      return GlobalStatistics(
        id: 'global', // A constant ID for the global statistics
        totalVolunteers: totalVolunteers,
        totalActivities: totalActivities,
        totalServiceHours: totalServiceHours,
      );
    } catch (e) {
      throw Exception("Failed to get global statistics: $e");
    }
  }

  // Get statistics for a specific volunteer
  Future<VolunteerStatistics> getVolunteerStatistics(String volunteerId) async {
    try {
      // Get all participations of the volunteer
      QuerySnapshot participationsSnapshot = await _firestore
          .collection('participations')
          .where('volunteerId', isEqualTo: volunteerId)
          .get();

      // Calculate total service hours for the volunteer
      double totalServiceHours =
          participationsSnapshot.docs.fold(0.0, (double sum, doc) {
        double hours = (doc['participationHours'] as num?)?.toDouble() ?? 0.0;
        return sum + hours;
      });

      // Get the total number of activities the volunteer participated in
      int totalActivities = participationsSnapshot.docs.length;

      // Create and return VolunteerStatistics
      return VolunteerStatistics(
        volunteerId: volunteerId,
        totalActivities: totalActivities,
        totalServiceHours: totalServiceHours,
      );
    } catch (e) {
      throw Exception("Failed to get volunteer statistics: $e");
    }
  }
}

class VolunteerStatistics {
  final String volunteerId;
  final int totalActivities;
  final double totalServiceHours;

  VolunteerStatistics({
    required this.volunteerId,
    required this.totalActivities,
    required this.totalServiceHours,
  });

  // Convert VolunteerStatistics object to map
  Map<String, dynamic> toMap() {
    return {
      'volunteerId': volunteerId,
      'totalActivities': totalActivities,
      'totalServiceHours': totalServiceHours,
    };
  }

  // Create VolunteerStatistics object from map
  factory VolunteerStatistics.fromMap(Map<String, dynamic> map) {
    return VolunteerStatistics(
      volunteerId: map['volunteerId'] as String,
      totalActivities: map['totalActivities'] as int,
      totalServiceHours: (map['totalServiceHours'] as num).toDouble(),
    );
  }
}
