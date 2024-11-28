import 'package:flutter/material.dart';
import '../models/feedback.dart' as feedback;
import '../services/feedback_service.dart';

class FeedbackDisplayWidget extends StatelessWidget {
  final String volunteerId;
  final String activityId;

  FeedbackDisplayWidget({
    required this.volunteerId,
    required this.activityId,
  });

  final FeedbackService _feedbackService = FeedbackService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<feedback.Feedback?>(
      future: _feedbackService.getFeedbackForActivityByVolunteer(
        volunteerId: volunteerId,
        activityId: activityId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final feedback = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feedback comment
              Text(
                'Feedback:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feedback.comment ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 12),

              // Star rating display
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < feedback.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${_formatDate(feedback.date)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper function to format the date into a more readable format
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
