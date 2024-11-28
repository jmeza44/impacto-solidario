import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/feedback.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit feedback for an activity
  Future<void> submitFeedback({
    required String volunteerId,
    required String activityId,
    required int rating,
    String? comment,
  }) async {
    try {
      // Generate a new feedback ID
      String feedbackId = _firestore.collection('feedbacks').doc().id;

      // Create a new Feedback object
      Feedback feedback = Feedback(
        id: feedbackId,
        volunteerId: volunteerId,
        activityId: activityId,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
      );

      // Save the feedback in Firestore
      await _firestore
          .collection('feedbacks')
          .doc(feedbackId)
          .set(feedback.toMap());
    } catch (e) {
      throw Exception("Failed to submit feedback: $e");
    }
  }

  // Get feedback for a specific activity
  Future<List<Feedback>> getFeedbackForActivity(String activityId) async {
    try {
      // Fetch all feedbacks for the given activity
      QuerySnapshot feedbackSnapshot = await _firestore
          .collection('feedbacks')
          .where('activityId', isEqualTo: activityId)
          .get();

      // Convert Firestore documents to Feedback objects
      List<Feedback> feedbackList = feedbackSnapshot.docs
          .map((doc) => Feedback.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return feedbackList;
    } catch (e) {
      throw Exception("Failed to get feedback for activity: $e");
    }
  }

  Future<Feedback?> getFeedbackForActivityByVolunteer({
    required String volunteerId,
    required String activityId,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('feedbacks')
          .where('volunteerId', isEqualTo: volunteerId)
          .where('activityId', isEqualTo: activityId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      DocumentSnapshot feedbackDoc = querySnapshot.docs.first;

      Feedback feedback =
          Feedback.fromMap(feedbackDoc.data() as Map<String, dynamic>);

      return feedback;
    } catch (e) {
      throw Exception("Failed to get feedback: $e");
    }
  }
}
