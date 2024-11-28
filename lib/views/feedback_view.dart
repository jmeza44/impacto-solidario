import 'package:flutter/material.dart';

import '../services/feedback_service.dart';
import '../services/shared_preferences_service.dart';

class FeedbackView extends StatefulWidget {
  final String activityId;

  const FeedbackView({super.key, required this.activityId});

  @override
  _FeedbackViewState createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  int _rating = 1;
  String? _comment;
  final _feedbackService = FeedbackService();
  final _sharedPreferencesService = SharedPreferencesService();

  // Submit feedback to Firestore
  void _submitFeedback() async {
    try {
      final userSession = await _sharedPreferencesService.getUserSession();
      String volunteerId = userSession['userId'] ?? '';

      if (volunteerId.isEmpty) {
        throw Exception('No user session found');
      }

      await _feedbackService.submitFeedback(
        volunteerId: volunteerId,
        activityId: widget.activityId,
        rating: _rating,
        comment: _comment,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por tu retroalimentación!')),
      );

      // Optionally navigate back to previous screen or activity details
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar retroalimentación: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retroalimentación de Actividad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Activity summary (this would typically come from a service)
            const Text(
              'Resumen de la actividad realizada:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Descripción de la actividad aquí'),
            // Replace with actual data

            const SizedBox(height: 20),

            // Rating (1-5 stars)
            const Text('Calificación (1 a 5 estrellas):'),
            Slider(
              value: _rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value.toInt();
                });
              },
            ),

            const SizedBox(height: 20),

            // Comment input
            const Text('Comentario (opcional):'),
            TextField(
              onChanged: (value) {
                setState(() {
                  _comment = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Escribe tu comentario aquí...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text('Enviar Retroalimentación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
