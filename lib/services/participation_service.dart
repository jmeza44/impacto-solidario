import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/activity.dart';
import '../models/participation.dart';
import '../models/participation_history.dart';

class ParticipationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a volunteer for an activity
  Future<void> registerForActivity({
    required String volunteerId,
    required String activityId,
  }) async {
    try {
      // Generate a new participation ID
      String participationId = _firestore.collection('participations').doc().id;

      // Create a new participation object with initial status as REGISTERED
      Participation newParticipation = Participation(
        id: participationId,
        volunteerId: volunteerId,
        activityId: activityId,
        attendanceStatus: AttendanceStatus.registered,
        registrationDate: DateTime.now(),
      );

      // Add the participation record to Firestore
      await _firestore
          .collection('participations')
          .doc(participationId)
          .set(newParticipation.toMap());
    } catch (e) {
      throw Exception("Failed to register for activity: $e");
    }
  }

  // Confirm attendance of a volunteer for an activity
  Future<void> confirmAttendance({
    required String volunteerId,
    required String activityId,
    required AttendanceStatus status,
  }) async {
    try {
      // Find the participation record
      QuerySnapshot participationSnapshot = await _firestore
          .collection('participations')
          .where('volunteerId', isEqualTo: volunteerId)
          .where('activityId', isEqualTo: activityId)
          .get();

      if (participationSnapshot.docs.isEmpty) {
        throw Exception(
            "No participation found for this volunteer and activity");
      }

      // Get the participation ID
      String participationId = participationSnapshot.docs.first.id;

      // Update the attendance status
      await _firestore
          .collection('participations')
          .doc(participationId)
          .update({
        'attendanceStatus': status.name,
      });
    } catch (e) {
      throw Exception("Failed to confirm attendance: $e");
    }
  }

  // Get a volunteer's participation history
  Future<List<Participation>> getVolunteerParticipations(
      String volunteerId) async {
    try {
      // Fetch all participation records for the given volunteer
      QuerySnapshot participationSnapshot = await _firestore
          .collection('participations')
          .where('volunteerId', isEqualTo: volunteerId)
          .get();

      List<Participation> history = participationSnapshot.docs
          .map((doc) =>
              Participation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return history;
    } catch (e) {
      throw Exception("Failed to fetch participation history: $e");
    }
  }

  // Query participations for a specific user and filter by category
  Future<List<Activity>> getParticipatedActivities(String volunteerId) async {
    try {
      // Query participations based on volunteerId
      QuerySnapshot participationSnapshot = await _firestore
          .collection('participations')
          .where('volunteerId', isEqualTo: volunteerId)
          .where('attendanceStatus', isEqualTo: AttendanceStatus.attended.name)
          .get();

      // Extract activityIds from the participation records
      List<String> activityIds = participationSnapshot.docs
          .map((doc) => doc['activityId'] as String)
          .toList();

      // Now, query the activities collection using the activityIds
      Query activityQuery = _firestore.collection('activities');

      QuerySnapshot activitySnapshot = await activityQuery
          .where(FieldPath.documentId, whereIn: activityIds)
          .get();

      // Map the activity data into Activity objects
      List<Activity> activities = activitySnapshot.docs
          .map((doc) => Activity.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return activities;
    } catch (e) {
      throw Exception("Failed to fetch participated activities: $e");
    }
  }

  // Get all participants for a specific activity
  Future<List<Participation>> getActivityParticipants(String activityId) async {
    try {
      // Fetch all participation records for the given activity
      QuerySnapshot participationSnapshot = await _firestore
          .collection('participations')
          .where('activityId', isEqualTo: activityId)
          .get();

      List<Participation> participants = participationSnapshot.docs
          .map((doc) =>
              Participation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return participants;
    } catch (e) {
      throw Exception("Failed to fetch activity participants: $e");
    }
  }
}
